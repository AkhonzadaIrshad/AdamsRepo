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
    
    @IBOutlet weak var fieldTitle: MyUITextField!
    
    @IBOutlet weak var fieldPrice: MyUITextField!
    
    @IBOutlet weak var fieldDescription: MultilineTextField!
    
    @IBOutlet weak var btnLogo: UIButton!
    
    @IBOutlet weak var btnDelete: UIButton!
    
    @IBOutlet weak var btnEdit: UIButton!
    
    @IBOutlet weak var btnSave: UIButton!
    
    
    var onDelete : (() -> Void)? = nil
    var onEdit : (() -> Void)? = nil
    var onSave : (() -> Void)? = nil
    var onAddImage : (() -> Void)? = nil
    
    
    override class func awakeFromNib() {
        super.awakeFromNib()
        
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
        self.fieldTitle.isEnabled = false
        self.fieldPrice.isEnabled = false
        self.fieldPrice.isEnabled = false
        self.btnLogo.isUserInteractionEnabled = false
        
        self.btnDelete.isHidden = true
        self.btnSave.isHidden = true
        self.btnEdit.isHidden = false
    }
    func unlockCell() {
        self.fieldTitle.isEnabled = true
        self.fieldPrice.isEnabled = true
        self.fieldPrice.isEnabled = true
        self.btnLogo.isUserInteractionEnabled = true
        
        self.btnDelete.isHidden = false
        self.btnSave.isHidden = false
        self.btnEdit.isHidden = true
    }
}
