//
//  AddMenuVC.swift
//  rzq
//
//  Created by Zaid Khaled on 10/20/19.
//  Copyright © 2019 technzone. All rights reserved.
//

import UIKit

class AddMenuVC: BaseVC, UITableViewDelegate, UITableViewDataSource{
    
    
    @IBOutlet weak var fieldCategory: MyUITextField!
    
    @IBOutlet weak var ivHandle: UIImageView!
    
    @IBOutlet weak var tableView: UITableView!
    
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
        ApiService.owner_getShopMenu(Authorization: self.loadUser().data?.accessToken ?? "", shopId: self.shopId ?? 0) { (response) in
            self.hideLoading()
            self.items.removeAll()
            self.items.append(contentsOf: response.shopOwnerData ?? [ShopOwnerDatum]())
            self.tableView.reloadData()
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
            vc.categoryId = item.id ?? 0
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func addCategoryAction(_ sender: Any) {
        if (self.fieldCategory.text?.count ?? 0 > 0) {
            self.showLoading()
            ApiService.owner_createMenuCategory(Authorization: self.loadUser().data?.accessToken ?? "", shopId: self.shopId ?? 0, englishName: self.fieldCategory.text ?? "", arabicName: self.fieldCategory.text ?? "", image: "") { (response) in
                self.hideLoading()
                self.loadCategories()
            }
        }else {
            self.showBanner(title: "alert".localized, message: "enter_category_name".localized, style: UIColor.INFO)
        }
    }
    
}
