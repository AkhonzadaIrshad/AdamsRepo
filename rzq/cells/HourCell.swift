//
//  HourCell.swift
//  rzq
//
//  Created by Zaid najjar on 5/15/19.
//  Copyright © 2019 technzone. All rights reserved.
//

import UIKit
import SimpleCheckbox
import DropDown

protocol HourCellDelegate {
    func didSelectFrom(cell: UITableViewCell, str : String)
    func didSelectTo(cell: UITableViewCell, str : String)
}
class HourCell: UITableViewCell {

    @IBOutlet weak var lblName: MyUILabel!
    @IBOutlet weak var lblStatus: MyUILabel!
    
    @IBOutlet weak var btnFrom: UIButton!
    @IBOutlet weak var btnTo: UIButton!
    
    @IBOutlet weak var chkAllDay: Checkbox!
    
    @IBOutlet weak var chkAdd: Checkbox!
    
    @IBOutlet weak var expandedViewHeight: NSLayoutConstraint!
    
    var delegate : HourCellDelegate?
    
    let fromDropDown = DropDown()
    lazy var FromDropDownObj: [DropDown] = {
        return [
            self.fromDropDown
        ]
    }()
    
    let toDropDown = DropDown()
    lazy var ToDropDownObj: [DropDown] = {
        return [
            self.toDropDown
        ]
    }()
    
    
    
    var isExpanded : Bool = false
    
    var onExpand : (() -> Void)? = nil
    var onAllDay : (() -> Void)? = nil
    var onFrom : (() -> Void)? = nil
    var onTo : (() -> Void)? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.chkAdd.checkmarkStyle = .tick
        self.chkAdd.checkmarkColor = UIColor.processing
        self.chkAdd.checkedBorderColor = UIColor.processing
        self.chkAdd.uncheckedBorderColor = UIColor.colorPrimary
        
        self.chkAllDay.checkmarkStyle = .tick
        self.chkAllDay.checkmarkColor = UIColor.processing
        self.chkAllDay.checkedBorderColor = UIColor.processing
        self.chkAllDay.uncheckedBorderColor = UIColor.colorPrimary
        
        self.btnFrom.backgroundColor = .clear
        self.btnFrom.layer.cornerRadius = 3
        self.btnFrom.layer.borderWidth = 1
        self.btnFrom.layer.borderColor = UIColor.black.cgColor
        
        
        self.btnTo.backgroundColor = .clear
        self.btnTo.layer.cornerRadius = 3
        self.btnTo.layer.borderWidth = 1
        self.btnTo.layer.borderColor = UIColor.black.cgColor
        
        // Initialization code
        
        self.setUpFromDropDown()
        self.setUpToDropDown()
    }
    
    func setUpFromDropDown() {
        fromDropDown.bottomOffset = CGPoint(x: 0, y: btnFrom.bounds.height)
        fromDropDown.anchorView = btnFrom
        fromDropDown.dataSource = Constants.getHoursStr()
        fromDropDown.selectRow(at: 0)
        btnFrom.setTitle(fromDropDown.selectedItem, for: .normal)
        fromDropDown.selectionAction = { [unowned self] (index, item) in
            self.fromDropDown.selectRow(at: index)
            self.btnFrom.setTitle(self.fromDropDown.selectedItem, for: .normal)
            self.delegate?.didSelectFrom(cell : self, str: self.fromDropDown.selectedItem!)
        }
    }
    
    func setUpToDropDown() {
        toDropDown.bottomOffset = CGPoint(x: 0, y: btnTo.bounds.height)
        toDropDown.anchorView = btnTo
        toDropDown.dataSource = Constants.getHoursStr()
        toDropDown.selectRow(at: 0)
        btnFrom.setTitle(toDropDown.selectedItem, for: .normal)
        toDropDown.selectionAction = { [unowned self] (index, item) in
            self.toDropDown.selectRow(at: index)
            self.btnTo.setTitle(self.toDropDown.selectedItem, for: .normal)
            self.delegate?.didSelectTo(cell : self, str: self.toDropDown.selectedItem!)
        }
    }
    

    @IBAction func fromAction(_ sender: Any) {
        fromDropDown.show()
        if let onFrom = self.onFrom {
            onFrom()
        }
    }
    
    @IBAction func toAction(_ sender: Any) {
        toDropDown.show()
        if let onTo = self.onTo {
            onTo()
        }
    }
    
    @IBAction func onAddChange(_ sender: Checkbox) {
        if let onExpand = self.onExpand {
            self.isExpanded = !self.isExpanded
            onExpand()
        }
    }
    
    @IBAction func onAllDayChange(_ sender: Checkbox) {
        if let onAllDay = self.onAllDay {
            onAllDay()
        }
    }
    
}
