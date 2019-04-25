//
//  DriverBidCell.swift
//  rzq
//
//  Created by Zaid najjar on 4/3/19.
//  Copyright © 2019 technzone. All rights reserved.
//

import UIKit

class DriverBidCell: UITableViewCell {

   
    @IBOutlet weak var ivLogo: UIImageView!
    
    @IBOutlet weak var lblTitle: MyUILabel!
    
    @IBOutlet weak var lblMoney: MyUILabel!
    
    @IBOutlet weak var lblTime: MyUILabel!
    
    @IBOutlet weak var lblDistance: MyUILabel!
    
    var onCheck : (() -> Void)? = nil
    
    @IBAction func checkOfferAction(_ sender: Any) {
        if let onCheck = self.onCheck {
            onCheck()
        }
    }
    

}
