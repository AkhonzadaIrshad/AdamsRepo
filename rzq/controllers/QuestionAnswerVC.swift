//
//  QuestionAnswerVC.swift
//  rzq
//
//  Created by Zaid najjar on 4/16/19.
//  Copyright © 2019 technzone. All rights reserved.
//

import UIKit

class QuestionAnswerVC: BaseVC {

    var faq : FAQsDatum?
    
    @IBOutlet weak var lblQuestion: MyUILabel!
    
    @IBOutlet weak var lblAnswer: MyUILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.lblQuestion.text = self.faq?.answer ?? ""
        self.lblAnswer.text = self.faq?.question ?? ""

        if (self.isArabic()) {
            let attributedString = NSMutableAttributedString(string: self.faq?.answer ?? "")
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 30
            attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))
            self.lblAnswer.attributedText = attributedString
        }
        // Do any additional setup after loading the view.
    }
    


}
