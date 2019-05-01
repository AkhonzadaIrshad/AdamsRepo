//
//  TermsPushVC.swift
//  rzq
//
//  Created by Zaid najjar on 5/1/19.
//  Copyright © 2019 technzone. All rights reserved.
//

import UIKit

class TermsPushVC: BaseVC {

    @IBOutlet weak var tvContent: MyUITextView!
    
    @IBOutlet weak var ivHandle: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (self.isArabic()) {
            self.tvContent.text = App.shared.config?.configString?.arabicTermsAndConditions ?? ""
        }else {
            self.tvContent.text = App.shared.config?.configString?.englishTermsAndConditions ?? ""
        }
        
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
