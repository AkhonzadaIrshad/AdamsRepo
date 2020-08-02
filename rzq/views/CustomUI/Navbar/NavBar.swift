//
//  NavBar.swift
//  rzq
//
//  Created by Safoine Moncef Amine on 8/2/20.
//  Copyright © 2020 technzone. All rights reserved.
//

import UIKit

class NavBar: UIView {
    
    private let nibName = "NavBar"
    
    @IBOutlet weak var lblHome: UILabel!
    @IBOutlet weak var lblOrders: UILabel!
    @IBOutlet weak var lblNotifications: UILabel!
    @IBOutlet weak var lblProfile: UILabel!
    
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
        self.localize()
    }
    
    func loadViewFromNib() -> UIView? {
        let nib = UINib(nibName: nibName, bundle: nil)
        return nib.instantiate(withOwner: self, options: nil).first as? UIView
    }
    
    
    @IBAction func btnHomeClicked(_ sender: Any) {
        print("Home")
    }
    
    @IBAction func btnOrdersClicked(_ sender: Any) {
        print("Orders")
    }
    
    @IBAction func btnNotificationsClicked(_ sender: Any) {
        print("Notifications")
    }
    @IBAction func btnProfileClicked(_ sender: Any) {
        print("Profile")
    }
    
    private func localize() {
        self.lblHome.text = "Home"
        self.lblOrders.text = "Orders"
        self.lblNotifications.text = "Notifications"
        self.lblProfile.text = "Profile"
    }
}
