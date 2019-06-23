//
//  Intro2.swift
//  rzq
//
//  Created by Zaid najjar on 4/8/19.
//  Copyright © 2019 technzone. All rights reserved.
//

import UIKit

class Intro2: BaseVC {

    var delegate : IntroDelegate?
    
    @IBOutlet weak var ivhandle: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        if (self.isArabic()) {
            self.ivhandle.image = UIImage(named: "intro2_indicator_arabic")
        }
        // Do any additional setup after loading the view.
    }
    
    @IBAction func skipAction(_ sender: Any) {
        delegate?.doneAction()
    }
    
    @IBAction func nextAction(_ sender: Any) {
        delegate?.nextAction(index: 2)
    }
    
}
