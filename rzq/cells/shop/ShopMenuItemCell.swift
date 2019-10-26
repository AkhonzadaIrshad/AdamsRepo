//
//  ShopMenuItemCell.swift
//  rzq
//
//  Created by Zaid Khaled on 10/21/19.
//  Copyright © 2019 technzone. All rights reserved.
//

import UIKit
import ValueStepper

class ShopMenuItemCell: UITableViewCell {

    
    @IBOutlet weak var ivLogo: CircleImage!
    
    @IBOutlet weak var lblTitle: MyUILabel!
    @IBOutlet weak var lblPrice: MyUILabel!
    
    @IBOutlet weak var lblDescription: UILabel!
    
    @IBOutlet weak var viewStepper: ValueStepper!
    
     var valueChanged : (() -> Void)? = nil
     var selectedValue : Int?
    
    @IBAction func stepperValueChanged(_ sender: ValueStepper) {
        if let valueChanged = self.valueChanged {
            self.selectedValue = Int(self.viewStepper.value)
                   valueChanged()
        }
    }
    
}
