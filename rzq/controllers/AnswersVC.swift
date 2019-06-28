//
//  AnswersVC.swift
//  rzq
//
//  Created by Zaid najjar on 4/28/19.
//  Copyright © 2019 technzone. All rights reserved.
//

import UIKit

class AnswersVC: BaseVC {

    @IBOutlet weak var lblQuestion: MyUILabel!
    @IBOutlet weak var lblAnswer: MyUILabel!
    
    @IBOutlet weak var ivHandle: UIImageView!
    
    var  item : FAQsDatum?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (self.isArabic()) {
            self.ivHandle.image = UIImage(named: "ic_back_arabic")
        }
        self.lblQuestion.text = item?.question ?? ""
        self.lblAnswer.text = item?.answer ?? ""
        // Do any additional setup after loading the view.
        
        if (self.isArabic()) {
            let attributedString = NSMutableAttributedString(string: item?.answer ?? "")
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 10
            attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))
            self.lblAnswer.attributedText = attributedString
        }
        
        
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
