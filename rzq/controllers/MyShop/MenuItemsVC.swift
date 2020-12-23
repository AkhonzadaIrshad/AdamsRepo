//
//  MenuItemsVC.swift
//  rzq
//
//  Created by Zaid Khaled on 10/20/19.
//  Copyright © 2019 technzone. All rights reserved.
//

import UIKit

class MenuItemsVC: BaseVC, UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate {
    
    
    @IBOutlet weak var ivHandle: UIImageView!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var lblTitle: MyUILabel!
    
    var categoryName: String?
    
    var items = [ShowOwnerItem]()
    var categoryId : Int?
    
    var selectedIndexPath : IndexPath?
    
    var imagePicker: UIImagePickerController!
    enum ImageSource {
        case photoLibrary
        case camera
    }
    
    func selectImageFrom(_ source: ImageSource) {
        imagePicker =  UIImagePickerController()
        imagePicker.delegate = self
        switch source {
        case .camera:
            imagePicker.sourceType = .camera
        case .photoLibrary:
            imagePicker.sourceType = .photoLibrary
        }
        present(imagePicker, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.tableView.reloadData()
        
        if (self.items.count == 0) {
            self.tableView.setEmptyView(title: "no_menu_items".localized, message: "no_menu_items_desc".localized, image: "bg_no_data")
        }else {
            self.tableView.restore()
        }
        
        if (self.isArabic()) {
            self.ivHandle.image = UIImage(named: "ic_back_arabic")
        }
        
        self.lblTitle.text = self.categoryName ?? ""
        // Do any additional setup after loading the view.
    }
    
    //tableview delegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 480.0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: MenuItemCell = tableView.dequeueReusableCell(withIdentifier: "MenuItemCell", for: indexPath as IndexPath) as! MenuItemCell
        
        let item = self.items[indexPath.row]
        
        cell.fieldEnglishTitle.text = item.englishName ?? ""
        cell.fieldArabicTitle.text = item.arabicName ?? ""
        cell.fieldEnglishDescription.text = item.englishDescription ?? ""
        cell.fieldArabicDescription.text = item.arabicDescription ?? ""
        
        
        cell.fieldPrice.text = "\(item.price ?? 0.0)"
        
        if (item.imageName?.count ?? 0 > 0) {
            let url = URL(string: "\(Constants.IMAGE_URL)\(item.imageName ?? "")")
            // cell.btnLogo.imageView?.kf.setImage(with: url)
            cell.btnLogo.kf.setImage(with: url, for: .normal)
            
        } else {
            cell.btnLogo.setImage(UIImage(named: "bg_add_image"), for: .normal)
        }
        
        cell.onEdit = {
            item.status = Constants.MENU_ITEM_UNLOCKED
            cell.unlockCell()
        }
        
        cell.onDelete = {
            self.deleteItem(itemId: item.id ?? 0, index: indexPath.row)
        }
        
        cell.onSave = {
            if (cell.fieldEnglishTitle.text?.count ?? 0 == 0 || cell.fieldArabicTitle.text?.count ?? 0 == 0) {
                self.showBanner(title: "alert".localized, message: "enter_title_first".localized, style: UIColor.INFO)
                return
            }
            if (cell.fieldPrice.text?.count ?? 0 == 0 || (Double(cell.fieldPrice.text ?? "0.0") == 0)) {
                self.showBanner(title: "alert".localized, message: "enter_price_first".localized, style: UIColor.INFO)
                return
            }
            if (cell.fieldEnglishDescription.text?.count ?? 0 == 0 || cell.fieldArabicDescription.text?.count ?? 0 == 0) {
                self.showBanner(title: "alert".localized, message: "enter_desc_first".localized, style: UIColor.INFO)
                return
            }
            if (cell.btnLogo.currentImage == UIImage(named: "bg_add_image")) {
                self.showBanner(title: "alert".localized, message: "add_item_image".localized, style: UIColor.INFO)
                return
            }
            
            if (item.id ?? 0 > 0) {
                self.updateMenuItem(itemId: item.id ?? 0 ,englishName: cell.fieldEnglishTitle.text ?? "", arabicName: cell.fieldArabicTitle.text ?? "", englishDesc: cell.fieldEnglishDescription.text ?? "", arabicDesc: cell.fieldArabicDescription.text ?? "", price: (cell.fieldPrice.text ?? "0.0").replacedArabicDigitsWithEnglish, image: ((cell.btnLogo.image(for: .normal)?.toBase64())!))
                ApiService.owner_updateoutOfStock(Authorization: DataManager.loadUser().data?.accessToken ?? "", itemId: item.id ?? 0, IsOutOfStock: cell.outOfStockSwitch.isOn) { (response) in
                    print(response)
                }
            }else {
                self.createMenuItem(englishName: cell.fieldEnglishTitle.text ?? "", arabicName: cell.fieldArabicTitle.text ?? "", englishDesc: cell.fieldEnglishDescription.text ?? "", arabicDesc: cell.fieldArabicDescription.text ?? "", price: (cell.fieldPrice.text ?? "0.0").replacedArabicDigitsWithEnglish, image: ((cell.btnLogo.image(for: .normal)?.toBase64())!))
                ApiService.owner_updateoutOfStock(Authorization: DataManager.loadUser().data?.accessToken ?? "", itemId: item.id ?? 0, IsOutOfStock: cell.outOfStockSwitch.isOn) { (response) in
                    print(response)
                }
            }
            
            item.status = Constants.MENU_ITEM_LOCKED
            cell.lockCell()
        }
        
        cell.onOutOfStock = {
            ApiService.owner_updateoutOfStock(Authorization: DataManager.loadUser().data?.accessToken ?? "", itemId: item.id ?? 0, IsOutOfStock: cell.outOfStockSwitch.isOn) { (response) in
                print(response)
            }
        }
        cell.onAddImage = {
            self.selectedIndexPath = indexPath
            self.addImageAction()
            ApiService.owner_updateoutOfStock(Authorization: DataManager.loadUser().data?.accessToken ?? "", itemId: item.id ?? 0, IsOutOfStock: cell.outOfStockSwitch.isOn) { (response) in
                print(response)
            }
        }
        
        if (item.status == Constants.MENU_ITEM_UNLOCKED) {
            cell.fieldEnglishTitle.isEnabled = true
            cell.fieldArabicTitle.isEnabled = true
            cell.fieldPrice.isEnabled = true
            cell.fieldEnglishDescription.isEditable = true
            cell.fieldArabicDescription.isEditable = true
            cell.btnLogo.isUserInteractionEnabled = true
            
            cell.btnDelete.isHidden = false
            cell.btnSave.isHidden = false
            cell.btnEdit.isHidden = true
        }else {
            cell.fieldEnglishTitle.isEnabled = false
            cell.fieldArabicTitle.isEnabled = false
            cell.fieldPrice.isEnabled = false
            cell.fieldEnglishDescription.isEditable = false
            cell.fieldArabicDescription.isEditable = false
            cell.btnLogo.isUserInteractionEnabled = false
            
            cell.btnDelete.isHidden = true
            cell.btnSave.isHidden = true
            cell.btnEdit.isHidden = false
        }
        
        return cell
    }
    
    
    func createMenuItem(englishName: String, arabicName: String, englishDesc: String, arabicDesc: String, price: String, image: String) {
        self.showLoading()
        ApiService.owner_createMenuItem(Authorization: DataManager.loadUser().data?.accessToken ?? "", menuId: self.categoryId ?? 0, englishName: englishName, arabicName: arabicName, image: image, price: price.replacedArabicDigitsWithEnglish, englishDesc: englishDesc, arabicDesc: arabicDesc) { (response) in
             
            self.hideLoading()
            
        }
    }
    
    func updateMenuItem(itemId: Int,englishName: String, arabicName: String, englishDesc: String, arabicDesc: String, price: String, image: String) {
        self.showLoading()
        ApiService.owner_updateMenuItem(Authorization: DataManager.loadUser().data?.accessToken ?? "", itemId: itemId, englishName: englishName, arabicName: arabicName, image: image, price: price.replacedArabicDigitsWithEnglish, englishDesc: englishDesc, arabicDesc: arabicDesc) { (response) in
            self.hideLoading()
        }
    }
    
    func deleteItem(itemId: Int, index: Int) {
        self.showAlert(title: "alert".localized, message: "confirm_delete_menu_item".localized, actionTitle: "delete".localized, cancelTitle: "cancel".localized, actionHandler: {
            self.showLoading()
            ApiService.owner_deleteMenuItem(Authorization: DataManager.loadUser().data?.accessToken ?? "", itemId: itemId) { (response) in
                self.hideLoading()
                self.items.remove(at: index)
                if (self.items.count == 0) {
                    self.tableView.setEmptyView(title: "no_menu_items".localized, message: "no_menu_items_desc".localized, image: "bg_no_data")
                }else {
                    self.tableView.restore()
                }
                self.tableView.reloadData()
            }
            
        })
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func addItemAction(_ sender: Any) {
        let emptyMenuItem = ShowOwnerItem(id: 0, arabicName: "", englishName: "", imageName: "", price: 0.0, arabicDescription: "", englishDescription: "")
        emptyMenuItem.status = Constants.MENU_ITEM_UNLOCKED
        self.items.insert(emptyMenuItem, at: 0)
        if (self.items.count == 0) {
            self.tableView.setEmptyView(title: "no_menu_items".localized, message: "no_menu_items_desc".localized, image: "bg_no_data")
        }else {
            self.tableView.restore()
        }
        self.tableView.reloadData()
    }
    
    @IBAction func addItmAction(_ sender: Any) {
        let emptyMenuItem = ShowOwnerItem(id: 0, arabicName: "", englishName: "", imageName: "", price: 0.0, arabicDescription: "", englishDescription: "")
        emptyMenuItem.status = Constants.MENU_ITEM_UNLOCKED
        self.items.insert(emptyMenuItem, at: 0)
        if (self.items.count == 0) {
            self.tableView.setEmptyView(title: "no_menu_items".localized, message: "no_menu_items_desc".localized, image: "bg_no_data")
        }else {
            self.tableView.restore()
        }
        self.tableView.reloadData()
    }
    
    
    @IBAction func doneAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func addImageAction() {
        self.showAlert(title: "add_image_pic_title".localized, message: "add_salon_pic_message".localized, actionTitle: "camera".localized, cancelTitle: "gallery".localized, actionHandler: {
            //camera
            guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
                self.selectImageFrom(.photoLibrary)
                return
            }
            self.selectImageFrom(.camera)
        }) {
            //gallery
            self.imagePicker =  UIImagePickerController()
            self.imagePicker.delegate = self
            self.imagePicker.sourceType = .photoLibrary
            self.present(self.imagePicker, animated: true, completion: nil)
        }
    }
    
}
extension MenuItemsVC: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imagePicker.dismiss(animated: true, completion: nil)
        guard let selectedImage = info[.originalImage] as? UIImage else {
            print("Image not found!")
            return
        }
        
        if let cell = tableView.cellForRow(at: selectedIndexPath ?? IndexPath(row: 0, section: 0)) as? MenuItemCell {
            cell.btnLogo.setImage(selectedImage, for: .normal)
            // self.tableView.reloadData()
        }
        
    }
}
