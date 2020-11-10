//
//  PendingOrderCell.swift
//  rzq
//
//  Created by Zaid najjar on 4/17/19.
//  Copyright © 2019 technzone. All rights reserved.
//

import UIKit
import Cosmos

class PendingOrderCell: UICollectionViewCell {
    
    @IBOutlet weak var ivLogo: CircleImage!
    
    @IBOutlet weak var lblDriverName: MyUILabel!
    
    @IBOutlet weak var ratingView: CosmosView!
    
    @IBOutlet weak var lblDistance: MyUILabel!
    
    @IBOutlet weak var lblPrice: MyUILabel!
    
    @IBOutlet weak var lblTime: MyUILabel!
    
    @IBOutlet weak var lblPayment: MyUILabel!
    
    @IBOutlet weak var ivDot: UIImageView!
    
    var onChat : (() -> Void)? = nil
    var onTrack: (() -> Void)? = nil
    
    @IBAction func chatAction(_ sender: Any) {
        if let onChat = self.onChat {
            onChat()
        }
    }
    
    @IBAction func trackAction(_ sender: Any) {
        if let onTrack = self.onTrack {
            onTrack()
        }
    }
}
