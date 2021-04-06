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
    @IBOutlet weak var containerMessageView: UIView!
    @IBOutlet weak var okContainer: RoundedView!
    
    let nibName = "CustomAlert"
    var onOk: (() -> Void)? = nil

    
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
        if let onOk = self.onOk {
            onOk()
        }
    }
    @IBAction func onOwnThisShop(_ sender: Any) {
        self.isHidden = true
        if let onOk = self.onOk {
            onOk()
        }
    }
    
    func configureAsStep1() {
        okContainer.isHidden = false
        containerMessageView.isHidden = true
        self.title.text = "steps.popup.title".localized
        self.lblDescription.text = "step1.popup.description".localized
        if UserDefaults.standard.bool(forKey: "step1AlreadyShowed") {
            self.isHidden = true
        } else {
            UserDefaults.standard.set(true, forKey: "step1AlreadyShowed")
        }
    }
    
    func configureAsStep2() {
        okContainer.isHidden = false
        containerMessageView.isHidden = true
        self.title.text = "steps.popup.title".localized
        self.lblDescription.text = "step2.popup.description".localized
        if UserDefaults.standard.bool(forKey: "step2AlreadyShowed") {
            self.isHidden = true
        } else {
            UserDefaults.standard.set(true, forKey: "step2AlreadyShowed")
        }
    }
    
    func ownThisShop() {
        okContainer.isHidden = true
        containerMessageView.isHidden = false
        self.isHidden = false
        self.title.text = "غير مسجل؟💬"
lblDescription.text = "😏هذا المتجر مو مسجل بالتطبيق بس لاتحاتي تقدر تطلب منه ونوصلك منه"
    }
}
