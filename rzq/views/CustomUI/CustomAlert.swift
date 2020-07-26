//
//  CustomAlert.swift
//  rzq
//
//  Created by Safoine Moncef Amine on 7/26/20.
//  Copyright © 2020 technzone. All rights reserved.
//

import UIKit

class CustomAlert: UIView {
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var btnOK: UIButton!
    
    let nibName = "CustomAlert"
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    func commonInit() {
        guard let view = loadViewFromNib() else { return }
        view.frame = self.bounds
        self.addSubview(view)
    }
    
    func loadViewFromNib() -> UIView? {
        let nib = UINib(nibName: nibName, bundle: nil)
        return nib.instantiate(withOwner: self, options: nil).first as? UIView
    }
    
    @IBAction func btnOK_Clicked(_ sender: Any) {
        self.isHidden = true
    }
    
    func configureAsStep1() {
        self.title.text = "steps.popup.title".localized
        self.lblDescription.text = "step1.popup.description".localized
    }
    
    func configureAsStep2() {
        self.title.text = "steps.popup.title".localized
        self.lblDescription.text = "step2.popup.description".localized
    }
}
