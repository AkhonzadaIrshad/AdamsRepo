//
//  ContactUsVC.swift
//  rzq
//
//  Created by Zaid najjar on 4/16/19.
//  Copyright © 2019 technzone. All rights reserved.
//

import UIKit

class ContactUsVC: BaseVC {
    
    @IBOutlet weak var edtSubject: MyUITextField!
    
    @IBOutlet weak var edtMessage: MyUITextField!
    
    @IBOutlet weak var edtMobile: MyUITextField!
    
    @IBOutlet weak var ivHandle: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.edtSubject.addDoneButtonOnKeyboard()
        self.edtMessage.addDoneButtonOnKeyboard()
        
        if (self.isArabic()) {
            self.ivHandle.image = UIImage(named: "ic_back_arabic")
        }
        
        self.edtMobile.text = self.loadUser().data?.phoneNumber ?? ""
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func sendAction(_ sender: Any) {
        if (self.validate()) {
            self.showLoading()
            var message = ""
            message = "\(self.edtMessage.text ?? "")\n\n\("mobile: ") \(self.edtMobile.text?.replacedArabicDigitsWithEnglish ?? "")"
            ApiService.contactUs(subject: self.edtSubject.text ?? "", body: message) { (response) in
                self.hideLoading()
                if (response.errorCode == 0) {
                    self.showBanner(title: "alert".localized, message: "message_sent_successfully".localized, style: UIColor.SUCCESS)
                    self.edtSubject.text = ""
                    self.edtMessage.text = ""
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
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
