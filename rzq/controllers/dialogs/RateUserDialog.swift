//
//  RateUserDialog.swift
//  rzq
//
//  Created by Zaid najjar on 4/25/19.
//  Copyright © 2019 technzone. All rights reserved.
//

import UIKit
import Cosmos

class RateUserDialog: BaseVC {

    @IBOutlet weak var ratingView: CosmosView!
    var deliveryId : Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    @IBAction func submitAction(_ sender: Any) {
        ApiService.rateUser(Authorization: self.loadUser().data?.accessToken ?? "", deliveryId: self.deliveryId ?? 0, rate: Int(self.ratingView.rating), comment: "") { (response) in
            if (response.errorCode == 0) {
                self.showBanner(title: "alert".localized, message: "thank_you_for_rating".localized, style: UIColor.SUCCESS)
                DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                    let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: self.getHomeView()) as! UINavigationController
                    self.present(vc, animated: true, completion: nil)
                })
            }else {
                self.showBanner(title: "alert".localized, message: response.errorMessage ?? "", style: UIColor.INFO)
            }
        }
    }
    
}
