//
//  MyShopPendingOrdersVC.swift
//  rzq
//
//  Created by Zaid Khaled on 10/20/19.
//  Copyright © 2019 technzone. All rights reserved.
//

import UIKit

class MyShopPendingOrdersVC: BaseVC, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var ivHandle: UIImageView!
    
    var shopId : Int?
    var items = [ShopOrdersDatum]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (self.isArabic()) {
            self.ivHandle.image = UIImage(named: "ic_back_arabic")
        }
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 139.0
        
        self.showLoading()
        ApiService.getShopOrders(Authorization: self.loadUser().data?.accessToken ?? "", shopId: self.shopId ?? 0) { (response) in
            self.hideLoading()
            self.items.append(contentsOf: response.shopOrderData?.shopOrdersData ?? [ShopOrdersDatum]())
            self.tableView.reloadData()
            
            if (self.items.count == 0) {
                self.tableView.setEmptyView(title: "no_shop_orders".localized, message: "no_shop_orders_desc".localized, image: "bg_no_data")
            }else {
                self.tableView.restore()
            }
        }
        // Do any additional setup after loading the view.
    }
    
    
    //tableview delegate
    //       func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    //           return 108.0
    //       }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: MyShopOrderCell = tableView.dequeueReusableCell(withIdentifier: "MyShopOrderCell", for: indexPath as IndexPath) as! MyShopOrderCell
        
        let item = self.items[indexPath.row]
        
        cell.lblOrderNo.text = "\(Constants.ORDER_NUMBER_PREFIX)\(item.id ?? 0)"
        cell.lblDate.text = self.convertDate(isoDate: item.createdDate ?? "")
        cell.lblTime.text = item.createdTime ?? ""
        cell.lblStatus.text = item.statusString ?? ""
        cell.lblOrderDetails.text = item.shopOrdersDatumDescription ?? ""
        
        if (item.image?.count ?? 0 > 0) {
            let url = URL(string: "\(Constants.IMAGE_URL)\(item.image ?? "")")
            cell.ivLogo.kf.setImage(with: url)
        }
        
        if (item.items?.count ?? 0 > 0) {
            cell.btnItems.isHidden = false
        }else {
            cell.btnItems.isHidden = true
        }
        
        cell.onViewItems = {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc : ViewMenuVC = storyboard.instantiateViewController(withIdentifier: "ViewMenuVC") as! ViewMenuVC
            vc.items = item.items ?? [ShopMenuItem]()
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        return cell
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
