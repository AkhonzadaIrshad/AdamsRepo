//
//  MandIUpdateDialog.swift
//  rzq
//
//  Created by Zaid Khaled on 6/28/19.
//  Copyright © 2019 technzone. All rights reserved.
//

import UIKit

class MandIUpdateDialog: UIViewController {
    
    
    var dialogTitleStr : String?
    var dialogDescStr : String?
    
    @IBOutlet weak var dialogTitle: UILabel!
    @IBOutlet weak var desc: UILabel!
    
    @IBOutlet weak var btnClose: UIButton!
    
    @IBOutlet weak var btnUpdate: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dialogTitle.text = dialogTitleStr
        self.desc.text = dialogDescStr
        
        self.btnClose.setTitle("close_title_btn".localized, for: .normal)
        self.btnUpdate.setTitle("update_title_btn".localized, for: .normal)
        // Do any additional setup after loading the view.
    }
    
    @IBAction func closeAction(_ sender: Any) {
        self.dismiss(animated: true) {
            exit(0)
        }
    }
    
    @IBAction func updateAction(_ sender: Any) {
        //open store
        self.openAppStore()
    }
    
    
    func openAppStore() {
        if let url = URL(string: "itms-apps://itunes.apple.com/app/id1459027070"),
            UIApplication.shared.canOpenURL(url){
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:]) { (opened) in
                    
                }
            } else {
                UIApplication.shared.openURL(NSURL(string: "itms://itunes.apple.com/de/app/x-gift/id1459027070?mt=8&uo=4")! as URL)
            }
        } else {
            UIApplication.shared.openURL(NSURL(string: "itms://itunes.apple.com/de/app/x-gift/id1459027070?mt=8&uo=4")! as URL)
        }
        
    }
    
    
    
    
    
}
