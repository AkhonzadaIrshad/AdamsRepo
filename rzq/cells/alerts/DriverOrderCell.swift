//
//  DriverOrderCell.swift
//  rzq
//
//  Created by Zaid najjar on 4/3/19.
//  Copyright © 2019 technzone. All rights reserved.
//

import UIKit

class DriverOrderCell: UITableViewCell {

    @IBOutlet weak var ivLogo: UIImageView!
    
    @IBOutlet weak var lblTitle: MyUILabel!
    
    @IBOutlet weak var lblMoney: MyUILabel!
    
    @IBOutlet weak var lblTime: MyUILabel!
    
    @IBOutlet weak var lblDistance: MyUILabel!
    
    @IBOutlet weak var ivType: UIImageView!
    
    @IBOutlet weak var lblNotificationDate: MyUILabel!
    @IBOutlet weak var lblNotificationTime: MyUILabel!
    @IBOutlet weak var timeView: UIView!
    
    
    
    var onTake : (() -> Void)? = nil
    
    @IBAction func takeOrderAction(_ sender: Any) {
        if let onTake = self.onTake {
            onTake()
        }
    }
    
    
}
