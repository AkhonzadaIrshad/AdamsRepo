//
//  MyShopOrderCell.swift
//  rzq
//
//  Created by Zaid Khaled on 10/20/19.
//  Copyright © 2019 technzone. All rights reserved.
//

import UIKit

class MyShopOrderCell: UITableViewCell {

    @IBOutlet weak var ivLogo: CircleImage!
    
    @IBOutlet weak var lblOrderNo: MyUILabel!
    
    @IBOutlet weak var lblDate: MyUILabel!
    
    @IBOutlet weak var lblTime: MyUILabel!
    
    @IBOutlet weak var lblStatus: MyUILabel!
    
    @IBOutlet weak var lblOrderDetails: MyUILabel!
    
    @IBOutlet weak var btnItems: MyUIButton!
    
    var onViewItems : (() -> Void)? = nil
    
    @IBAction func itemsAction(_ sender: Any) {
        if let onViewItems = self.onViewItems {
            onViewItems()
        }
    }
    
}
