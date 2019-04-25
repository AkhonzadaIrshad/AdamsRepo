//
//  Intro1.swift
//  rzq
//
//  Created by Zaid najjar on 4/8/19.
//  Copyright © 2019 technzone. All rights reserved.
//

import UIKit

class Intro1: UIViewController {

    var delegate : IntroDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func skipAction(_ sender: Any) {
        delegate?.doneAction()
    }
    
    @IBAction func nextAction(_ sender: Any) {
        delegate?.nextAction(index: 1)
    }
    
}
