//
//  SendingOrderVC.swift
//  rzq
//
//  Created by Zaid najjar on 4/30/19.
//  Copyright © 2019 technzone. All rights reserved.
//

import UIKit
import SwiftyGif

class SendingOrderVC: BaseVC {

    @IBOutlet weak var gif: UIImageView!
    
    @IBOutlet weak var lblTitle: MyUILabel!
    
    @IBOutlet weak var lblDesc: MyUILabel!
    
    var type : Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let gif = UIImage(gifName: "pending.gif")
        self.gif.setGifImage(gif)
        
         if (type == 2){
            self.lblTitle.text = "waiting_provider_bids".localized
            self.lblDesc.text = "waiting_provider_bids_desc".localized
        }
        
    }
    
    func goToNotifications() {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NotificationsNavigationController") as! UINavigationController
        App.shared.notificationSegmentIndex = 1
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func openOrdersAction(_ sender: Any) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "OrdersNavigationController") as! UINavigationController
        self.present(vc, animated: true, completion: nil)
    }
    
}
