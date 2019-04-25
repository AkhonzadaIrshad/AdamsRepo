//
//  ShopRegisterCell.swift
//  rzq
//
//  Created by Zaid najjar on 4/16/19.
//  Copyright © 2019 technzone. All rights reserved.
//

import UIKit

class ShopRegisterCell: UITableViewCell {

    @IBOutlet weak var ivLogo: CircleImage!
    
    @IBOutlet weak var lblName: MyUILabel!
    
    @IBOutlet weak var lblAddress: MyUILabel!
    
    
    
     var onCancel : (() -> Void)? = nil
    
    @IBAction func cancelRegistrationAction(_ sender: Any) {
        if let onCancel = self.onCancel {
            onCancel()
        }
    }
    
}
