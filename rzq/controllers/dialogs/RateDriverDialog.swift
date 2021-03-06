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

protocol RateDriverDelegate {
    func reloadFromRateDriver()
}
class RateDriverDialog: BaseVC {
    
    
    @IBOutlet weak var ratingView: CosmosView!
    @IBOutlet weak var edtComments: MultilineTextField!
    
    var deliveryId : Int?
    var delegate : RateDriverDelegate?
    var notificationId : Int?
    var hideCancel: Bool?
    
    @IBOutlet weak var btnCancel: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        edtComments.placeholder = "feedback_comments".localized
        edtComments.placeholderColor = UIColor.lightGray
        edtComments.isPlaceholderScrollEnabled = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (self.hideCancel ?? false) {
            self.btnCancel.isHidden = true
        }
        
    }
    
    @IBAction func submitAction(_ sender: Any) {
        ApiService.rateDriver(Authorization: DataManager.loadUser().data?.accessToken ?? "", deliveryId: self.deliveryId ?? 0, rate: Int(self.ratingView.rating), comment: self.edtComments.text ?? "") { (response) in
            if (response.errorCode == 0) {
                self.showBanner(title: "alert".localized, message: "thank_you_for_rating".localized, style: UIColor.SUCCESS)
            }else {
                self.showBanner(title: "alert".localized, message: response.errorMessage ?? "", style: UIColor.INFO)
            }
            ApiService.deleteNotification(Authorization: DataManager.loadUser().data?.accessToken ?? "", id: self.notificationId ?? 0, completion: { (response) in
                self.delegate?.reloadFromRateDriver()
                self.dismiss(animated: true, completion: nil)
            })
        }
    }
    
    @IBAction func dismissAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
