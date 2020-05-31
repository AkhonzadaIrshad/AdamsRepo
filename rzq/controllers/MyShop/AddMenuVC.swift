//
//  AddMenuVC.swift
//  rzq
//
//  Created by Zaid Khaled on 10/20/19.
//  Copyright © 2019 technzone. All rights reserved.
//

import UIKit
import FittedSheets

class AddMenuVC: BaseVC, UITableViewDelegate, UITableViewDataSource, CategoryNameSheetDelegate {
    
    
    @IBOutlet weak var fieldEnglishCategory: MyUITextField!
    @IBOutlet weak var fieldArabicCategory: MyUITextField!
    
    @IBOutlet weak var ivHandle: UIImageView!
    
    @IBOutlet weak var tableView: UITableView!
    
    var sheetController : SheetViewController?
    
    var shopId : Int?
    
    var items = [ShopOwnerDatum]()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        if (self.isArabic()) {
            self.ivHandle.image = UIImage(named: "ic_back_arabic")
        }
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.loadCategories()
    }
    
    func loadCategories() {
        self.showLoading()
        ApiService.owner_getShopMenu(Authorization: DataManager.loadUser().data?.accessToken ?? "", shopId: self.shopId ?? 0) { (response) in
            self.hideLoading()
            self.items.removeAll()
            self.items.append(contentsOf: response.shopOwnerData ?? [ShopOwnerDatum]())
            self.tableView.reloadData()
            
            if (self.items.count == 0) {
                self.tableView.setEmptyView(title: "no_menu_categories".localized, message: "no_menu_categories_desc".localized, image: "bg_no_data")
            }else {
                self.tableView.restore()
            }
        }
    }
    
    
    //tableview delegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 62.0
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: MenuCategoryCell = tableView.dequeueReusableCell(withIdentifier: "MenuCategoryCell", for: indexPath as IndexPath) as! MenuCategoryCell
        
        let item = self.items[indexPath.row]
        
        if (self.isArabic()) {
            cell.lblTitle.text = item.arabicName ?? ""
        }else {
            cell.lblTitle.text = item.englishName ?? ""
        }
        
        cell.onAddItem = {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc : MenuItemsVC = storyboard.instantiateViewController(withIdentifier: "MenuItemsVC") as! MenuItemsVC
            vc.items.append(contentsOf: item.showOwnerItems ?? [ShowOwnerItem]())
            vc.items.reverse()
            vc.categoryId = item.id ?? 0
            if (self.isArabic()) {
                vc.categoryName = item.arabicName ?? ""
            }else {
                vc.categoryName = item.englishName ?? ""
            }
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        cell.onEditName = {
            self.showCategoryNameSheet(cat: item)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
//    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
//           return true
//       }
//
//       func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//           if (editingStyle == .delete) {
//               self.deleteMenu(index: indexPath.row)
//           }
//       }
//
//
//       func deleteMenu(index: Int) {
//           self.showAlert(title: "alert".localized, message: "confirm_delete_menu_category".localized, actionTitle: "delete".localized, cancelTitle: "cancel".localized, actionHandler: {
//            self.showLoading()
//            ApiService.owner_dele
//                     self.items.remove(at: index)
//                     self.tableView.reloadData()
//                 })
//       }
    
    func showCategoryNameSheet(cat: ShopOwnerDatum) {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "UpdateCategoryNameSheet") as! UpdateCategoryNameSheet
        sheetController = SheetViewController(controller: controller, sizes: [.fixed(250)])
        sheetController?.handleColor = UIColor.colorPrimary
        controller.delegate = self
        controller.cat = cat
        self.present(sheetController!, animated: false, completion: nil)
    }
    
    func onSubmit(cat: ShopOwnerDatum, englishName: String, arabicName: String) {
        self.showLoading()
        ApiService.owner_updateMenuCategory(Authorization: DataManager.loadUser().data?.accessToken ?? "", menuId: cat.id ?? 0, englishName: englishName, arabicName: arabicName, image: cat.imageName ?? "") { (response) in
            self.hideLoading()
            self.sheetController?.closeSheet()
            self.loadCategories()
        }
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func addCategoryAction(_ sender: Any) {
        if (self.fieldEnglishCategory.text?.count ?? 0 > 0 && self.fieldArabicCategory.text?.count ?? 0 > 0) {
            self.showLoading()
            ApiService.owner_createMenuCategory(Authorization: DataManager.loadUser().data?.accessToken ?? "", shopId: self.shopId ?? 0, englishName: self.fieldEnglishCategory.text ?? "", arabicName: self.fieldArabicCategory.text ?? "", image: "") { (response) in
                self.hideLoading()
                self.loadCategories()
            }
        }else {
            self.showBanner(title: "alert".localized, message: "enter_category_name".localized, style: UIColor.INFO)
        }
    }
    
    @IBAction func addCatAction(_ sender: Any) {
        if (self.fieldEnglishCategory.text?.count ?? 0 > 0 && self.fieldArabicCategory.text?.count ?? 0 > 0) {
            self.showLoading()
            ApiService.owner_createMenuCategory(Authorization: DataManager.loadUser().data?.accessToken ?? "", shopId: self.shopId ?? 0, englishName: self.fieldEnglishCategory.text ?? "", arabicName: self.fieldArabicCategory.text ?? "", image: "") { (response) in
                self.hideLoading()
                self.loadCategories()
            }
        }else {
            self.showBanner(title: "alert".localized, message: "enter_category_name".localized, style: UIColor.INFO)
        }
    }
    
    
}
