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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (self.isArabic()) {
            self.ivHandle.image = UIImage(named: "bg_circular_arabic")
        }
    }
    
    @IBAction func doneAction(_ sender: Any) {
        delegate?.doneAction()
    }
    
}
