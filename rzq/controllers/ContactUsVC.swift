//
//  ContactUsVC.swift
//  rzq
//
//  Created by Zaid najjar on 4/16/19.
//  Copyright © 2019 technzone. All rights reserved.
//

import UIKit

class ContactUsVC: BaseViewController {
    
    @IBOutlet weak var edtSubject: MyUITextField!
    
    @IBOutlet weak var edtMessage: MyUITextField!
    
    @IBOutlet weak var btnMenu: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.edtSubject.addDoneButtonOnKeyboard()
        self.edtMessage.addDoneButtonOnKeyboard()

          self.btnMenu.addTarget(self, action: #selector(BaseViewController.onSlideMenuButtonPressed(_:)), for: UIControl.Event.touchUpInside)
        
        
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func sendAction(_ sender: Any) {
        if (self.validate()) {
            self.showLoading()
            var message = ""
            message = "\(self.edtMessage.text ?? "")\n\n\("mobile: ") \(self.loadUser().data?.phoneNumber ?? "")"
            ApiService.contactUs(subject: self.edtSubject.text ?? "", body: message) { (response) in
                self.hideLoading()
                if (response.errorCode == 0) {
                    self.showBanner(title: "alert".localized, message: "message_sent_successfully".localized, style: UIColor.SUCCESS)
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
//                        self.navigationController?.popViewController(animated: true)
//                    })
                }else {
                    self.showBanner(title: "alert".localized, message: response.errorMessage ?? "", style: UIColor.INFO)
                }
            }
        }
    }
    
    func validate() -> Bool {
        if (self.edtSubject.text?.count ?? 0 == 0) {
            self.showBanner(title: "alert".localized, message: "enter_subject_first".localized, style: UIColor.INFO)
            return false
        }
        if (self.edtMessage.text?.count ?? 0 == 0) {
            self.showBanner(title: "alert".localized, message: "enter_message_first".localized, style: UIColor.INFO)
            return false
        }
        return true
    }
}
