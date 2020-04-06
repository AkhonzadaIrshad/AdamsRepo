//
//  MyShopsVC.swift
//  rzq
//
//  Created by Zaid Khaled on 10/19/19.
//  Copyright © 2019 technzone. All rights reserved.
//

import UIKit

class MyShopsVC: BaseVC, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var ivHandle: UIImageView!
    
    @IBOutlet weak var tableView: UITableView!
    
    var items = [ShopOwnerListDatum]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 139.0
        
        
        self.showLoading()
        ApiService.owner_getShopList(Authorization: self.loadUser().data?.accessToken ?? "") { (response) in
            self.hideLoading()
            self.items.append(contentsOf: response.shopOwnerListData ?? [ShopOwnerListDatum]())
            self.tableView.reloadData()
            
            if (self.items.count == 0) {
                self.tableView.setEmptyView(title: "no_shops".localized, message: "no_shops_desc".localized, image: "bg_no_data")
            }else {
                self.tableView.restore()
            }
            
        }
        
        if (self.isArabic()) {
            self.ivHandle.image = UIImage(named: "ic_back_arabic")
        }
        // Do any additional setup after loading the view.
    }
    
    //tableview delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: MyShopCell = tableView.dequeueReusableCell(withIdentifier: "MyShopCell", for: indexPath as IndexPath) as! MyShopCell
        
        let item = self.items[indexPath.row]
        
        if (item.images?.count ?? 0 > 0) {
            let url = URL(string: "\(Constants.IMAGE_URL)\(item.images?[0] ?? "")")
            cell.ivLogo.kf.setImage(with: url)
        }else {
            cell.ivLogo.image = UIImage(named: "ic_place_shopping_mall")
        }
        

        let name = item.englishName ?? ""
        if (self.isArabic()) {
            cell.lblName.text = item.arabicName ?? ""
        }
        cell.lblName.text = name
        
        cell.lblOrdersCount.text = item.address ?? ""
        
        cell.onShowOrders = {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc : MyShopPendingOrdersVC = storyboard.instantiateViewController(withIdentifier: "MyShopPendingOrdersVC") as! MyShopPendingOrdersVC
            vc.shopId = item.id ?? 0
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        cell.onEdit = {
            if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "EditShopVC") as? EditShopVC
            {
                vc.shop = ShopData(nearbyDriversCount: 0, id: item.id ?? 0, name: name, address: item.address ?? "", latitude: item.latitude ?? 0.0, longitude: item.longitude ?? 0.0, phoneNumber: item.phoneNumber ?? "", workingHours: item.workingHours ?? "", images: item.images ?? [String](), rate: item.rate ?? 0.0, type: item.type!, ownerId: self.loadUser().data?.userID ?? "", googlePlaceId: item.googlePlaceID ?? "", openNow: item.isOpen ?? false)
                vc.latitude = UserDefaults.standard.value(forKey: Constants.LAST_LATITUDE) as? Double ?? 0.0
                vc.longitude = UserDefaults.standard.value(forKey: Constants.LAST_LONGITUDE) as? Double ?? 0.0
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}
