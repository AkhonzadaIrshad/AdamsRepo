//
//  ShopCheckoutCell.swift
//  rzq
//
//  Created by Zaid Khaled on 10/21/19.
//  Copyright © 2019 technzone. All rights reserved.
//

import UIKit
import ValueStepper

class ShopCheckoutCell: UITableViewCell {
    
    @IBOutlet weak var lblTitle: MyUILabel!
    @IBOutlet weak var viewStepper: ValueStepper!
    
    @IBOutlet weak var lblItemPrice: MyUILabel!
    @IBOutlet weak var lblTotalPrice: MyUILabel!
    
    var valueChanged : (() -> Void)? = nil
    var onDelete : (() -> Void)? = nil
    var selectedValue : Int?
    
    @IBAction func stepperValueChanged(_ sender: ValueStepper) {
        if (self.viewStepper.value > 0) {
            if let valueChanged = self.valueChanged {
                self.selectedValue = Int(self.viewStepper.value)
                valueChanged()
            }
        }else {
            if let onDelete = self.onDelete {
                onDelete()
            }
        }
    }
    
    @IBAction func deleteAction(_ sender: Any) {
        if let onDelete = self.onDelete {
            onDelete()
        }
    }
    
    
}
