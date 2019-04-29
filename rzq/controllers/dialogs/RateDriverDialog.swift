//
//  RateDriverDialog.swift
//  rzq
//
//  Created by Zaid najjar on 4/29/19.
//  Copyright © 2019 technzone. All rights reserved.
//

import UIKit
import Cosmos
import MultilineTextField

class RateDriverDialog: BaseVC {

   
    @IBOutlet weak var ratingView: CosmosView!
    @IBOutlet weak var edtComments: MultilineTextField!
    
    var deliveryId : Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        edtComments.placeholder = "feedback_comments".localized
        edtComments.placeholderColor = UIColor.lightGray
        edtComments.isPlaceholderScrollEnabled = true
        
    }
    
    @IBAction func submitAction(_ sender: Any) {
        ApiService.rateDriver(Authorization: self.loadUser().data?.accessToken ?? "", deliveryId: self.deliveryId ?? 0, rate: Int(self.ratingView.rating), comment: self.edtComments.text ?? "") { (response) in
            if (response.errorCode == 0) {
                self.showBanner(title: "alert".localized, message: "thank_you_for_rating".localized, style: UIColor.SUCCESS)
                self.dismiss(animated: true, completion: nil)
            }else {
                self.showBanner(title: "alert".localized, message: response.errorMessage ?? "", style: UIColor.INFO)
            }
        }
    }
    
}
