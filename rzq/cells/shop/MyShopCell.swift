//
//  MyShopCell.swift
//  rzq
//
//  Created by Zaid Khaled on 10/20/19.
//  Copyright © 2019 technzone. All rights reserved.
//

import UIKit

class MyShopCell: UITableViewCell {
    
    @IBOutlet weak var ivLogo: CircleImage!
    
    @IBOutlet weak var lblName: MyUILabel!
    
    @IBOutlet weak var lblOrdersCount: MyUILabel!
    
    var onShowOrders : (() -> Void)? = nil
    var onEdit : (() -> Void)? = nil
    
    @IBAction func showOrdersAction(_ sender: Any) {
        if let onShowOrders = self.onShowOrders {
            onShowOrders()
        }
    }
    
    
    @IBAction func editShopAction(_ sender: Any) {
        if let onEdit = self.onEdit {
            onEdit()
        }
    }
    
    
}
