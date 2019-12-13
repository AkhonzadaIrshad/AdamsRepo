//
//  LanguageVC.swift
//  rzq
//
//  Created by Zaid najjar on 3/31/19.
//  Copyright © 2019 technzone. All rights reserved.
//

import UIKit
import MOLH

class LanguageVC: BaseVC {

    
    @IBOutlet weak var ivHandle: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (self.isArabic()) {
            self.ivHandle.image = UIImage(named: "bg_language_buttons_arabic")
        }
    }
    
    @IBAction func arabicAction(_ sender: Any) {
        UserDefaults.standard.setValue(true, forKey: Constants.DID_CHOOSE_LANGUAGE)
        MOLH.setLanguageTo("ar")
       // MOLHLanguage.setAppleLAnguageTo("ar")
        MOLH.reset()
    }
    
    @IBAction func englishAction(_ sender: Any) {
        UserDefaults.standard.setValue(true, forKey: Constants.DID_CHOOSE_LANGUAGE)
        MOLH.setLanguageTo("en")
      //  MOLHLanguage.setAppleLAnguageTo("en")
        MOLH.reset()
    }
    
    
}
