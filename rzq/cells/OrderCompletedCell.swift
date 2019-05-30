//
//  OrderCompletedCell.swift
//  rzq
//
//  Created by Zaid najjar on 5/9/19.
//  Copyright © 2019 technzone. All rights reserved.
//

import UIKit

class OrderCompletedCell: UITableViewCell {

    @IBOutlet weak var lblTitle: MyUILabel!
    @IBOutlet weak var lblDesc: MyUILabel!
    @IBOutlet weak var btnRate: MyUIButton!
    
    var onRate : (() -> Void)? = nil
    
    @IBAction func rateAction(_ sender: Any) {
        if let onRate = self.onRate {
            onRate()
        }
    }
    
    
}
