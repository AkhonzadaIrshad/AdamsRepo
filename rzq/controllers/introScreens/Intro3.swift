//
//  Intro3.swift
//  rzq
//
//  Created by Zaid najjar on 4/8/19.
//  Copyright © 2019 technzone. All rights reserved.
//

import UIKit

class Intro3: UIViewController {

    var delegate : IntroDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func doneAction(_ sender: Any) {
        delegate?.doneAction()
    }
    
}
