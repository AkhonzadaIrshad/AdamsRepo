//
//  MyShopPendingOrdersVC.swift
//  rzq
//
//  Created by Zaid Khaled on 10/20/19.
//  Copyright © 2019 technzone. All rights reserved.
//

import UIKit

class MyShopPendingOrdersVC: BaseVC {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    var shopId : Int?
    
    @IBOutlet weak var ivHandle: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (self.isArabic()) {
            self.ivHandle.image = UIImage(named: "ic_back_arabic")
        }
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
