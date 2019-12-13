//
//  SettingsVC.swift
//  rzq
//
//  Created by Zaid najjar on 4/16/19.
//  Copyright © 2019 technzone. All rights reserved.
//

import UIKit
import MOLH
import Alamofire
import SVProgressHUD
import Firebase

class SettingsVC: BaseVC {

    
    @IBOutlet weak var englishButton: UIButton!
    @IBOutlet weak var englishCheckbox: UIImageView!
    
    @IBOutlet weak var arabicCheckbox: UIImageView!
    
    @IBOutlet weak var arabicButton: UIButton!
    
    @IBOutlet weak var notificationSwitch: UISwitch!
    
    @IBOutlet weak var ivHandle: UIImageView!
    
    @IBOutlet weak var ivIndicator1: UIImageView!
    @IBOutlet weak var ivIndicator2: UIImageView!
    @IBOutlet weak var ivIndicator3: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        if MOLHLanguage.isArabic() {
            arabicCheckbox.image = UIImage(named: "ic_checked")
            englishCheckbox.image = UIImage(named: "ic_unchecked_orange")
            self.ivHandle.image = UIImage(named: "ic_back_arabic")
            self.ivIndicator1.image = UIImage(named: "ic_indicator_arabic")
            self.ivIndicator2.image = UIImage(named: "ic_indicator_arabic")
            self.ivIndicator3.image = UIImage(named: "ic_indicator_arabic")
        }else {
            englishCheckbox.image = UIImage(named: "ic_checked")
            arabicCheckbox.image = UIImage(named: "ic_unchecked_orange")
        }
        
        let notificationFlag = UserDefaults.standard.value(forKey: Constants.IS_NOTIFICATION_ACTIVE) as? Bool ?? true
        
        if (notificationFlag) {
            self.notificationSwitch.isOn = true
        }else {
            self.notificationSwitch.isOn = false
        }
        
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func notificationSwitchValueChanged(_ sender: Any) {
        UserDefaults.standard.set(self.notificationSwitch.isOn, forKey: Constants.IS_NOTIFICATION_ACTIVE)
    }
    
    
    @IBAction func englishValueSelected(_ sender: UIButton) {
        
        if MOLHLanguage.isArabic() {
            
            self.showAlert(title: "alert".localized, message: "app_restart".localized, actionTitle: "yes".localized, cancelTitle: "no".localized, actionHandler: {
                self.englishCheckbox.image = UIImage(named: "ic_checkbox_selected")
                self.arabicCheckbox.image = UIImage(named: "ic_checkbox")
                
                let defaults = UserDefaults.standard
                defaults.set(true, forKey: "DID_SELECT_LANG")
                MOLH.setLanguageTo("en")
              //  MOLHLanguage.setAppleLAnguageTo("en")
                self.updateFCM()
            })
            
        }
    }
    
    
    @IBAction func arabicValueSelected(_ sender: Any) {
        
        if MOLHLanguage.isArabic() {
            return
        }
        self.showAlert(title: "alert".localized, message: "app_restart".localized, actionTitle: "yes".localized, cancelTitle: "no".localized, actionHandler: {
            self.arabicCheckbox.image = UIImage(named: "ic_checkbox_selected")
            self.englishCheckbox.image = UIImage(named: "ic_checkbox")
            
            let defaults = UserDefaults.standard
            defaults.set(true, forKey: "DID_SELECT_LANG")
            MOLH.setLanguageTo("ar")
           // MOLHLanguage.setAppleLAnguageTo("ar")
            self.updateFCM()
        })
        
    }
   
    func updateFCM() {
        MOLH.reset()
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func faqsAction(_ sender: Any) {
        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FAQsVC") as? FAQsVC
        {
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    
    @IBAction func termsAction(_ sender: Any) {
        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TermsVC") as? TermsVC
        {
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    
    @IBAction func aboutUsAction(_ sender: Any) {
        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AboutUsVC") as? AboutUsVC
        {
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    
}
