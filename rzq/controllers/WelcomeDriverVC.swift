//
//  WelcomeDriverVC.swift
//  rzq
//
//  Created by Zaid Khaled on 11/20/19.
//  Copyright © 2019 technzone. All rights reserved.
//

import UIKit
import BMPlayer

class WelcomeDriverVC: BaseVC {

    
    @IBOutlet weak var playerView: BMPlayer!
    
    @IBOutlet weak var tvContent: MyUITextView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let videoUrl = URL(fileReferenceLiteralResourceName: "weldome.mp4")
        let asset = BMPlayerResource(url: videoUrl)
        self.playerView.setVideo(resource: asset)
        self.playerView.play()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func closeAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
