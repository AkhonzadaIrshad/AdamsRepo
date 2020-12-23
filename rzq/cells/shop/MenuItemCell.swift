//
//  MenuItemCell.swift
//  rzq
//
//  Created by Zaid Khaled on 10/20/19.
//  Copyright © 2019 technzone. All rights reserved.
//

import UIKit
import MultilineTextField

class MenuItemCell: UITableViewCell {
    
    @IBOutlet weak var fieldEnglishTitle: MyUITextField!
    @IBOutlet weak var fieldArabicTitle: MyUITextField!
    @IBOutlet weak var fieldPrice: MyUITextField!
    @IBOutlet weak var fieldEnglishDescription: MultilineTextField!
    @IBOutlet weak var fieldArabicDescription: MultilineTextField!
    
    @IBOutlet weak var btnLogo: UIButton!
    @IBOutlet weak var btnDelete: UIButton!
    @IBOutlet weak var btnEdit: UIButton!
    @IBOutlet weak var btnSave: UIButton!
    @IBOutlet weak var outOfStockSwitch: UISwitch!
    
    
    var onDelete : (() -> Void)? = nil
    var onEdit : (() -> Void)? = nil
    var onSave : (() -> Void)? = nil
    var onAddImage : (() -> Void)? = nil
    var onOutOfStock:(() -> Void)? = nil
    
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @IBAction func onOutOfStock(_ sender: Any) {
        if let onOutOfStock = self.onOutOfStock {
            onOutOfStock()
        }
    }
    
    @IBAction func deleteAction(_ sender: Any) {
        if let onDelete = self.onDelete {
            onDelete()
        }
    }
    
    @IBAction func editAction(_ sender: Any) {
        if let onEdit = self.onEdit {
            onEdit()
        }
    }
    
    @IBAction func saveAction(_ sender: Any) {
        if let onSave = self.onSave {
            onSave()
        }
    }
    
    @IBAction func addImageAction(_ sender: Any) {
        if let onAddImage = self.onAddImage {
            onAddImage()
        }
    }
    
    func lockCell() {
        self.fieldEnglishTitle.isEnabled = false
        self.fieldArabicTitle.isEnabled = false
        self.fieldPrice.isEnabled = false
        self.fieldEnglishDescription.isEditable = false
        self.fieldArabicDescription.isEditable = false
        self.btnLogo.isUserInteractionEnabled = false
        
        self.btnDelete.isHidden = true
        self.btnSave.isHidden = true
        self.btnEdit.isHidden = false
    }
    
    func unlockCell() {
        self.fieldEnglishTitle.isEnabled = true
        self.fieldArabicTitle.isEnabled = true
        self.fieldPrice.isEnabled = true
        self.fieldEnglishDescription.isEditable = true
        self.fieldArabicDescription.isEditable = true
        self.btnLogo.isUserInteractionEnabled = true
        
        self.btnDelete.isHidden = false
        self.btnSave.isHidden = false
        self.btnEdit.isHidden = true
    }
    
}
