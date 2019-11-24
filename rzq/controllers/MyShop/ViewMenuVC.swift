//
//  ViewMenuVC.swift
//  rzq
//
//  Created by Zaid Khaled on 11/1/19.
//  Copyright © 2019 technzone. All rights reserved.
//

import UIKit

class ViewMenuVC: BaseVC, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var ivHandle: UIImageView!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var lblItems: MyUILabel!
    
    @IBOutlet weak var lblTotalPrice: MyUILabel!
    
    var items = [ShopMenuItem]()
    
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
        
        
        self.calculateTotal()
        
        if (self.isArabic()) {
            self.ivHandle.image = UIImage(named: "ic_back_arabic")
        }
    }
    
    
    func calculateTotal() {
        var totalItems = 0
        var totalPrice = 0.0
        
        for item in self.items {
            totalItems = totalItems + (item.count ?? 0)
            let doubleQuantity = Double(item.count ?? 0)
            let itemPrice = doubleQuantity * (item.price ?? 0.0)
            totalPrice = totalPrice + itemPrice
        }
        
        UIView.transition(with: self.lblItems,
                          duration: 0.25,
                          options: .transitionFlipFromBottom,
                          animations: { [weak self] in
                            self?.lblItems.text = "\(totalItems)"
            }, completion: nil)
        
        let formattedTotalPrice = String(format: "%.2f", totalPrice)
        UIView.transition(with: self.lblTotalPrice,
                          duration: 0.25,
                          options: .transitionFlipFromBottom,
                          animations: { [weak self] in
                            self?.lblTotalPrice.text = "\(formattedTotalPrice) \("currency".localized)"
            }, completion: nil)
    }
    
    
    //tableview delegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 108.0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ViewMenuCell = tableView.dequeueReusableCell(withIdentifier: "ViewMenuCell", for: indexPath as IndexPath) as! ViewMenuCell
        
        let item = self.items[indexPath.row]
        
        cell.lblItemName.text = item.name ?? ""
        cell.lblQuantity.text = "\(item.count ?? 0)"
        cell.lblPrice.text = "\(item.price ?? 0.0) \("currency".localized)"
        let doubleQuantity = Double(item.count ?? 0)
        let doublePrice = item.price ?? 0.0
        cell.lblTotal.text = "\(doubleQuantity * doublePrice) \("currency".localized)"
        
        return cell
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}
