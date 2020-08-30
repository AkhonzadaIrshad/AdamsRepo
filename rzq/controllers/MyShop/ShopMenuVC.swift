//
//  ShopMenuVC.swift
//  rzq
//
//  Created by Zaid Khaled on 10/21/19.
//  Copyright © 2019 technzone. All rights reserved.
//

import UIKit

protocol ShopMenuDelegate {
    func onDone(items: [ShopMenuItem],total : Double)
}
class ShopMenuVC: BaseVC, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout,
UITableViewDelegate, UITableViewDataSource, CheckOutDoneDelegate {
    
    
    @IBOutlet weak var ivHandle: UIImageView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var lblItemsCount: MyUILabel!
    
    @IBOutlet weak var lblItemsPrice: MyUILabel!
    
    @IBOutlet weak var ivCheckOut: UIImageView!
    
    var items = [ShopMenuItem]()
    var selectedItems = [ShopMenuItem]()
    var categories = [ShopMenuDatum]()
    
    var selectedCategory : ShopMenuDatum?
    
    var shopId : Int?
    
    var delegate : ShopMenuDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.lblItemsCount.text = "0"
        self.lblItemsPrice.text = "0.00 \("currency".localized)"
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.tableView.estimatedRowHeight = 145.0
        self.tableView.rowHeight = UITableView.automaticDimension
        
        // Do any additional setup after loading the view.
        
        self.loadShopMenu()
        
        if (self.isArabic()) {
            self.ivHandle.image = UIImage(named: "ic_back_arabic")
            self.ivCheckOut.image = UIImage(named: "ic_arrow_login_white_arabic")
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //   self.loadShopMenu()
    }
    
    func loadShopMenu() {
        self.showLoading()
        ApiService.getMenuByShopId(Authorization: DataManager.loadUser().data?.accessToken ?? "", id: self.shopId ?? 0) { (response) in
            self.hideLoading()
            self.categories.removeAll()
            self.categories.append(contentsOf: response.shopMenuData ?? [ShopMenuDatum]())
            self.loadSelectedItems()
            self.collectionView.reloadData()
            
            if (self.categories.count == 0) {
                self.showBanner(title: "alert".localized, message: "no_menu".localized, style: UIColor.INFO)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.navigationController?.popViewController(animated: true)
                }
            } else {
                self.categories[0].isChecked = true
                self.items.removeAll()
                self.items.append(contentsOf: response.shopMenuData?[0].shopMenuItems ?? [ShopMenuItem]())
                self.tableView.reloadData()
            }
        }
    }
    
    func loadSelectedItems() {
        for category in self.categories {
            for catItem in category.shopMenuItems ?? [ShopMenuItem]() {
                for item in self.selectedItems {
                    if ((item.price == catItem.price) && (item.name == catItem.name)) {
                        if (item.quantity ?? 0 > 0) {
                            catItem.quantity = item.quantity
                        }else {
                            catItem.quantity = item.count
                        }
                        
                    }
                }
            }
        }
        self.calculateTotal()
    }
    
    
    //collection delegates
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let label = UILabel(frame: CGRect.zero)
        label.text = self.categories[indexPath.row].name ?? ""
        label.sizeToFit()
        return CGSize(width: label.bounds.width + 20, height: 45.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        for cat in self.categories {
            cat.isChecked = false
        }
        self.categories[indexPath.row].isChecked = true
        self.selectedCategory = self.categories[indexPath.row]
        self.collectionView.reloadData()
        
        self.items.removeAll()
        self.items.append(contentsOf: self.categories[indexPath.row].shopMenuItems ?? [ShopMenuItem]())
        self.tableView.reloadData()
        
        if (self.items.count == 0) {
            self.tableView.setEmptyView(title: "no_menu_items".localized, message: "no_menu_items_desc".localized, image: "bg_no_data")
        }else {
            self.tableView.restore()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: ShopMenuTabCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ShopMenuTabCell", for: indexPath as IndexPath) as! ShopMenuTabCell
        
        let category = self.categories[indexPath.row]
        
        cell.lblTitle.text = category.name ?? ""
        
        if (category.isChecked ?? false) {
            cell.viewIndicator.isHidden = false
        }else {
            cell.viewIndicator.isHidden = true
        }
        return cell
        
    }
    
    
    //tableview delegate
    
    //       func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    //           return 118.0
    //       }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ShopMenuItemCell = tableView.dequeueReusableCell(withIdentifier: "ShopMenuItemCell", for: indexPath as IndexPath) as! ShopMenuItemCell
        
        let item = self.items[indexPath.row]
        
        let url = URL(string: "\(Constants.IMAGE_URL)\(item.imageName ?? "")")
        cell.ivLogo.kf.setImage(with: url)
        
        cell.lblTitle.text = item.name ?? ""
        cell.lblDescription.text = item.shopMenuItemDescription ?? ""
        cell.lblPrice.text = "\(item.price ?? 0.0) \("currency".localized)"
        
        
        cell.valueChanged = {
            item.quantity = cell.selectedValue ?? 0
            self.calculateTotal()
        }
        
        cell.onEnlarge = {
            var images = [String]()
            //  let str = message.media.mediaData?() as? String ?? ""
            let str = item.imageName ?? ""
            images.append(str)
            DispatchQueue.main.async {
                if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ImageSliderVC") as? ImageSliderVC
                {
                    vc.orderImages = images
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
        
        cell.viewStepper.value = Double(item.quantity ?? 0)
        
        return cell
    }
    
    
    func calculateTotal() {
        var totalItems = 0
        var totalPrice = 0.0
        
        for category in self.categories {
            for item in category.shopMenuItems ?? [ShopMenuItem]() {
                totalItems = totalItems + (item.quantity ?? 0)
                let doubleQuantity = Double(item.quantity ?? 0)
                let itemPrice = doubleQuantity * (item.price ?? 0.0)
                totalPrice = totalPrice + itemPrice
            }
        }
        
        UIView.transition(with: self.lblItemsCount,
                          duration: 0.25,
                          options: .transitionFlipFromBottom,
                          animations: { [weak self] in
                            self?.lblItemsCount.text = "\(totalItems)"
            }, completion: nil)
        
        let formattedTotalPrice = String(format: "%.2f", totalPrice)
        UIView.transition(with: self.lblItemsPrice,
                          duration: 0.25,
                          options: .transitionFlipFromBottom,
                          animations: { [weak self] in
                            self?.lblItemsPrice.text = "\(formattedTotalPrice) \("currency".localized)"
            }, completion: nil)
    }
    
    
    func getTotal() -> Double {
        var totalItems = 0
        var totalPrice = 0.0
        
        for category in self.categories {
            for item in category.shopMenuItems ?? [ShopMenuItem]() {
                var itemQuantity = item.quantity ?? 0
                if (itemQuantity == 0) {
                    itemQuantity = item.count ?? 0
                }
                totalItems = totalItems + (itemQuantity)
                let doubleQuantity = Double(itemQuantity)
                let itemPrice = doubleQuantity * (item.price ?? 0.0)
                totalPrice = totalPrice + itemPrice
            }
        }
        return totalPrice
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //go to delivery step 1
        
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func checkOutAction(_ sender: Any) {
        if (self.getSelectedItems().count > 0) {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc : ShopCheckoutVC = storyboard.instantiateViewController(withIdentifier: "ShopCheckoutVC") as! ShopCheckoutVC
            vc.items = self.getSelectedItems()
            vc.delegate = self
            self.navigationController?.pushViewController(vc, animated: true)
        }else {
            self.showBanner(title: "alert".localized, message: "add_items_first".localized, style: UIColor.INFO)
        }
    }
    
    func onDone(selectedItems: [ShopMenuItem]) {
        self.delegate?.onDone(items: selectedItems, total: self.getTotal())
        self.navigationController?.popViewController(animated: true)
    }
    
    func getSelectedItems() -> [ShopMenuItem] {
        var selectedItems = [ShopMenuItem]()
        for category in self.categories {
            for item in category.shopMenuItems ?? [ShopMenuItem]() {
                if (item.quantity ?? 0 > 0) {
                    selectedItems.append(item)
                }
            }
        }
        return selectedItems
    }
    
}
