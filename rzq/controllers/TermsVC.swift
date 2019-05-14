//
//  TermsVC.swift
//  rzq
//
//  Created by Zaid najjar on 4/16/19.
//  Copyright © 2019 technzone. All rights reserved.
//

import UIKit

class TermsVC: BaseVC {

    @IBOutlet weak var tvContent: MyUITextView!
    
    @IBOutlet weak var ivHandle: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if (self.isArabic()) {
            self.tvContent.text = App.shared.config?.configString?.arabicTermsAndConditions ?? ""
            self.ivHandle.image = UIImage(named: "ic_back_arabic")
        }else {
           self.tvContent.text = App.shared.config?.configString?.englishTermsAndConditions ?? ""
        }
        
    }
   
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
