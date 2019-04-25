//
//  QuestionAnswerVC.swift
//  rzq
//
//  Created by Zaid najjar on 4/16/19.
//  Copyright © 2019 technzone. All rights reserved.
//

import UIKit

class QuestionAnswerVC: UIViewController {

    var faq : FAQsDatum?
    
    @IBOutlet weak var lblQuestion: MyUILabel!
    
    @IBOutlet weak var lblAnswer: MyUILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.lblQuestion.text = self.faq?.answer ?? ""
        self.lblAnswer.text = self.faq?.question ?? ""

        // Do any additional setup after loading the view.
    }
    


}
