//
//  TermsVC.swift
//  rzq
//
//  Created by Zaid najjar on 4/16/19.
//  Copyright © 2019 technzone. All rights reserved.
//

import UIKit

class TermsVC: BaseViewController {

    @IBOutlet weak var tvContent: MyUITextView!
    
    @IBOutlet weak var btnMenu: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

          self.btnMenu.addTarget(self, action: #selector(BaseViewController.onSlideMenuButtonPressed(_:)), for: UIControl.Event.touchUpInside)
        
        if (self.isArabic()) {
            self.tvContent.text = App.shared.config?.configString?.arabicTermsAndConditions ?? ""
        }else {
           self.tvContent.text = App.shared.config?.configString?.englishTermsAndConditions ?? ""
        }
        
    }
   
    
}
