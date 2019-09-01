//
//  ChatProviderSheet.swift
//  rzq
//
//  Created by Zaid Khaled on 8/25/19.
//  Copyright © 2019 technzone. All rights reserved.
//

import UIKit

protocol ProviderSheetDelegate {
    func onNavigateStore()
    func onNavigateClient()
    func onCompleteOrder()
    func onMyWay()
    func onTrackOrder()
    func onCancelOrder()
}

class ChatProviderSheet: BaseVC {

    
    @IBOutlet weak var viewNavigateStore: UIView!
    @IBOutlet weak var viewNavigateClient: UIView!
    @IBOutlet weak var viewCompleteOrder: UIView!
    @IBOutlet weak var viewOnMyWay: UIView!
    @IBOutlet weak var viewTrackOrder: UIView!
    @IBOutlet weak var viewCancelOrder: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func orderInfoAction(_ sender: Any) {
        
    }
    
    @IBAction func navigateStoreAction(_ sender: Any) {
        
        
    }
    
    @IBAction func navigateClientAction(_ sender: Any) {
        
        
    }
    
    @IBAction func completeOrderAction(_ sender: Any) {
    }
    
    @IBAction func onMyWayAction(_ sender: Any) {
    }
    
    
    @IBAction func trackAction(_ sender: Any) {
    }
    
    @IBAction func cancelAction(_ sender: Any) {
    }
    
    
    
    
}
