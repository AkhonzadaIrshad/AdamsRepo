//
//  SelectServiceCell.swift
//  rzq
//
//  Created by Zaid najjar on 5/25/19.
//  Copyright © 2019 technzone. All rights reserved.
//

import UIKit
import SimpleCheckbox

class SelectServiceCell: UITableViewCell {

    @IBOutlet weak var ivLogo: CircleImage!
    
    @IBOutlet weak var lblName: MyUILabel!
    
    @IBOutlet weak var chkSelected: Checkbox!
    var onSelect : (() -> Void)? = nil
    
     var isChecked : Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.chkSelected.checkmarkStyle = .tick
        self.chkSelected.checkmarkColor = UIColor.processing
        self.chkSelected.checkedBorderColor = UIColor.processing
        self.chkSelected.uncheckedBorderColor = UIColor.colorPrimary
    }

    
    @IBAction func onSelect(_ sender: Checkbox) {
        if let onSelect = self.onSelect {
            self.isChecked = !self.isChecked
            onSelect()
        }
    }
    

}
