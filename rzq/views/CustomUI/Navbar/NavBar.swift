//
//  NavBar.swift
//  rzq
//
//  Created by Safoine Moncef Amine on 8/2/20.
//  Copyright © 2020 technzone. All rights reserved.
//

import UIKit

protocol NavBarDelegate {
    func goToHomeScreen()
    func goToOrdersScreen()
    func goToNotificationsScreen()
    func goToProfileScreen()
}

class NavBar: UIView {
    
    private let nibName = "NavBar"
    
    @IBOutlet weak var lblHome: UILabel!
    @IBOutlet weak var lblOrders: UILabel!
    @IBOutlet weak var lblNotifications: UILabel!
    @IBOutlet weak var lblProfile: UILabel!
    @IBOutlet weak var ordersCounterIcon: UIImageView!
    @IBOutlet weak var notificationsCounterIcon: UIImageView!
    
    var delegate: NavBarDelegate!
    
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
        self.refreshCounters()
    }
    
    func refreshCounters() {
        self.handleOrdersCounter()
        self.handleNotificationCounter()
    }
    private func handleNotificationCounter() {
        let count = UserDefaults.standard.value(forKey: Constants.NOTIFICATION_COUNT) as? Int ?? 0
        if (count > 0){
            self.notificationsCounterIcon.isHidden = false
            // self.btnCounter.setTitle("\(count)", for: .normal)
        }else {
            self.notificationsCounterIcon.isHidden = true
        }
    }
    
    private func handleOrdersCounter() {
        let count = UserDefaults.standard.value(forKey: Constants.ORDERS_COUNT) as? Int ?? 0
        if (count > 0){
            self.ordersCounterIcon.isHidden = false
            // self.btnCounter.setTitle("\(count)", for: .normal)
        }else {
            self.ordersCounterIcon.isHidden = true
        }
    }
    
    func loadViewFromNib() -> UIView? {
        let nib = UINib(nibName: nibName, bundle: nil)
        return nib.instantiate(withOwner: self, options: nil).first as? UIView
    }
    
    
    @IBAction func btnHomeClicked(_ sender: Any) {
        delegate.goToHomeScreen()
    }
    
    @IBAction func btnOrdersClicked(_ sender: Any) {
        delegate.goToOrdersScreen()
    }
    
    @IBAction func btnNotificationsClicked(_ sender: Any) {
        delegate.goToNotificationsScreen()
    }
    @IBAction func btnProfileClicked(_ sender: Any) {
        delegate.goToProfileScreen()
    }
    
    private func localize() {
        self.lblHome.text = "navbar.home".localized
        self.lblOrders.text = "navbar.orders".localized
        self.lblNotifications.text = "navbar.notifications".localized
        self.lblProfile.text = "navbar.profile".localized
    }
}
