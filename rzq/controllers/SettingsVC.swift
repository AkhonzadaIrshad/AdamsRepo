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

class SettingsVC: BaseViewController {

    
    @IBOutlet weak var englishButton: UIButton!
    @IBOutlet weak var englishCheckbox: UIImageView!
    
    @IBOutlet weak var arabicCheckbox: UIImageView!
    
    @IBOutlet weak var arabicButton: UIButton!
    
    @IBOutlet weak var btnMenu: UIButton!
    
    @IBOutlet weak var notificationSwitch: UISwitch!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

          self.btnMenu.addTarget(self, action: #selector(BaseViewController.onSlideMenuButtonPressed(_:)), for: UIControl.Event.touchUpInside)
        
        // Do any additional setup after loading the view.
        if MOLHLanguage.isArabic() {
            arabicCheckbox.image = UIImage(named: "ic_checked")
            englishCheckbox.image = UIImage(named: "ic_unchecked_orange")
            
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
                MOLHLanguage.setAppleLAnguageTo("en")
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
            MOLHLanguage.setAppleLAnguageTo("ar")
            self.updateFCM()
        })
        
    }
   
    func updateFCM() {
        MOLH.reset()
    }
    

}
