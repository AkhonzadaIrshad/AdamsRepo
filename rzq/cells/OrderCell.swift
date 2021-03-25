//
//  OrderCell.swift
//  rzq
//
//  Created by Zaid najjar on 4/3/19.
//  Copyright © 2019 technzone. All rights reserved.
//

import UIKit

class OrderCell: UITableViewCell {

    @IBOutlet weak var ivLogo: UIImageView!
    
    @IBOutlet weak var lblTitle: MyUILabel!
    
    @IBOutlet weak var lblDeliveryDate: MyUILabel!
    
    @IBOutlet weak var lblOrderNumber: MyUILabel!
    
    @IBOutlet weak var lblFrom: MyUILabel!
    
    @IBOutlet weak var lblTo: MyUILabel!
    
    @IBOutlet weak var lblOrderStatus: MyUILabel!
    
    @IBOutlet weak var viewTrack: CardView!
    
    @IBOutlet weak var viewChat: CardView!
    
    @IBOutlet weak var statusColorView: UIView!
    
    @IBOutlet weak var btnReorder: MyUIButton!
    
    @IBOutlet weak var messagedReadImageView: UIImageView!
    
    var onTrack : (() -> Void)? = nil
    var onChat : (() -> Void)? = nil
    var onReorder : (() -> Void)? = nil
    
    @IBAction func trackAction(_ sender: Any) {
        if let onTrack = self.onTrack {
            onTrack()
        }
    }
    
    @IBAction func chatAction(_ sender: Any) {
        if let onChat = self.onChat {
            onChat()
        }
    }
    
    @IBAction func reorderAction(_ sender: Any) {
        if let onReorder = self.onReorder {
            onReorder()
        }
    }
    
    
}
