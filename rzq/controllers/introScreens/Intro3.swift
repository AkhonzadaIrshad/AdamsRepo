//
//  Intro3.swift
//  rzq
//
//  Created by Zaid najjar on 4/8/19.
//  Copyright © 2019 technzone. All rights reserved.
//

import UIKit

class Intro3: BaseVC {

    var delegate : IntroDelegate?
    
    @IBOutlet weak var ivHandle: UIImageView!
    
    @IBOutlet weak var ivHandle2: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        if (self.isArabic()) {
             self.ivHandle2.image = UIImage(named: "intro3_indicator_arabic")
            self.ivHandle.image = UIImage(named: "bg_circular_arabic")
        }
    }
    
    @IBAction func doneAction(_ sender: Any) {
        delegate?.doneAction()
    }
    
}
