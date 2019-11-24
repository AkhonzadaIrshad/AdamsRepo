//
//  MenuCategoryCell.swift
//  rzq
//
//  Created by Zaid Khaled on 10/20/19.
//  Copyright © 2019 technzone. All rights reserved.
//

import UIKit

class MenuCategoryCell: UITableViewCell {
    
    @IBOutlet weak var lblTitle: MyUILabel!
    
    var onAddItem : (() -> Void)? = nil
    var onEditName : (() -> Void)? = nil
    
    @IBAction func addItemsAction(_ sender: Any) {
        if let onAddItem = self.onAddItem {
            onAddItem()
        }
    }
    
    @IBAction func editCategoryNameAction(_ sender: Any) {
        if let onEditName = self.onEditName {
            onEditName()
        }
    }
    @IBAction func editCatAction(_ sender: Any) {
       if let onAddItem = self.onAddItem {
            onAddItem()
        }
    }
}
