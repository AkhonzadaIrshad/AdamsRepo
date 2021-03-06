//
//  MenuViewController.swift
//  rzq
//
//  Created by Zaid najjar on 3/31/19.
//  Copyright © 2019 technzone. All rights reserved.
//

import UIKit
import Kingfisher
import Cosmos

protocol SlideMenuDelegate {
    func slideMenuItemSelectedAtIndex(_ index : Int32)
}

class MenuViewController: BaseVC {
    
    @IBOutlet var btnCloseMenuOverlay : UIButton!
    
    @IBOutlet weak var ivProfile: UIImageView!
    
    @IBOutlet weak var lblName: MyUILabel!
    
    @IBOutlet weak var lblWorkingOrders: MyUILabel!
    
    @IBOutlet weak var lblMobile: MyUILabel!
    
    @IBOutlet weak var lblNotifications: MyUILabel!
    
    @IBOutlet weak var moodSwitch: UISwitch!
    
    @IBOutlet weak var lblAppVersion: MyUILabel!
    
    @IBOutlet weak var topViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var makeOrderLabel: MyUILabel!
    @IBOutlet weak var lblBalance: UILabel!
    
    @IBOutlet weak var makeOrderView: UIView!
    @IBOutlet weak var lblDue: UILabel!
    
    @IBOutlet weak var makeOrderSwitch: UISwitch!
    @IBOutlet weak var lblEarnings: UILabel!
    
    @IBOutlet weak var viewMyShops: UIView!
        
    @IBOutlet weak var viewMood: UIView!
    
    @IBOutlet weak var ivSelect1: UIImageView!
    @IBOutlet weak var ivSelect2: UIImageView!
    @IBOutlet weak var ivSelectNew: UIImageView!
    @IBOutlet weak var ivSelect3: UIImageView!
    @IBOutlet weak var ivSelect4: UIImageView!
    @IBOutlet weak var ivSelect5: UIImageView!

    @IBOutlet weak var ivSelect9: UIImageView!
    @IBOutlet weak var ivSelect10: UIImageView!
    @IBOutlet weak var ivSelect11: UIImageView!
    
    @IBOutlet weak var ivSelected12: UIImageView!
    
    @IBOutlet weak var registeredShopsHeight: NSLayoutConstraint!
    
    @IBOutlet weak var registeredShopsView: UIView!
    
    @IBOutlet weak var loginView: UIView!
    
    var arrayMenuOptions = [Dictionary<String,String>]()
    
    var btnMenu : UIButton!
    
    var delegate : SlideMenuDelegate?
    
    @IBOutlet weak var ratingView: CosmosView!
    
    @IBOutlet weak var btnCounter: UIButton!
    
    @IBOutlet weak var btnWorkingOrdersCounter: UIButton!
    @IBOutlet weak var btnOrdersCounter: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let user = DataManager.loadUser()
        
        self.lblName.text = user.data?.fullName ?? ""
        self.lblMobile.text = user.data?.phoneNumber ?? ""
        self.ratingView.rating = Double(user.data?.rate ?? 0)
        
        self.lblBalance.font = UIFont(name: Constants.ARABIC_FONT_SEMIBOLD, size: 12)
        self.lblDue.font = UIFont(name: Constants.ARABIC_FONT_SEMIBOLD, size: 12)
        self.lblEarnings.font = UIFont(name: Constants.ARABIC_FONT_SEMIBOLD, size: 12)
        
        self.lblBalance.text = "\("account_balance".localized) \(user.data?.balance ?? 0.0) \("currency".localized)"
        
        
        if (self.isProvider()) {
            self.lblDue.isHidden = false
            self.lblEarnings.isHidden = false
            let balance = DataManager.loadUser().data?.earnings ?? 0.0
            let perc = App.shared.config?.configSettings?.percentage ?? 0.0
            let total = balance * perc
            let finalTotal = total / 10.0
            
            let dueAmount = user.data?.dueAmount ?? 0.0
            if (dueAmount >= 0) {
                self.lblDue.textColor = UIColor.app_green
            }else {
                self.lblDue.textColor = UIColor.app_red
            }
            self.lblDue.text = "\("due".localized) \(dueAmount) \("currency".localized)"
            
            self.lblEarnings.text = "\("earnings".localized) \(user.data?.earnings ?? 0.0) \("currency".localized)"
            
            self.lblNotifications.text = "new_notifications_driver".localized
        }else {
            self.lblDue.isHidden = true
            self.lblEarnings.isHidden = true
            self.lblNotifications.text = "new_notifications_user".localized
        }
        
        let urlStr = user.data?.profilePicture ?? ""
        if (urlStr.count > 0) {
            let url = URL(string: "\(Constants.IMAGE_URL)\(user.data?.profilePicture ?? "")")
            self.ivProfile.kf.setImage(with: url)
        }
        
        let dispalyMakeOrderButton = UserDefaults.standard.bool(forKey: "dispalyMakeOerderButton")
        self.makeOrderSwitch.isOn = dispalyMakeOrderButton

        if (self.isProvider()) {
            self.viewMood.isHidden = false
            self.topViewHeight.constant = 275.0
            self.makeOrderView.isHidden = false
            if (DataManager.loadUser().data?.isOnline ?? false) {
                self.moodSwitch.isOn = true
            }else {
                self.moodSwitch.isOn = false
            }
            lblWorkingOrders.text = "working_orders".localized
            lblWorkingOrders.textColor = UIColor.black
            self.registeredShopsHeight.constant = 50
            self.registeredShopsView.isHidden = false
        } else {
            self.topViewHeight.constant = 175.0
            self.makeOrderView.isHidden = true
            self.viewMood.isHidden = true
            lblWorkingOrders.text = "register_as_driver".localized
            lblWorkingOrders.textColor = UIColor.processing
            self.registeredShopsHeight.constant = 0
            self.registeredShopsView.isHidden = true
        }
        
        if (DataManager.loadUser().data?.userID?.count ?? 0 > 0) {
            ivProfile.isHidden = false
            lblName.isHidden = false
            lblMobile.isHidden = false
            ratingView.isHidden = false
            lblBalance.isHidden = false
            if (self.isProvider()) {
                lblDue.isHidden = false
            }
            loginView.isHidden  = true
        }else {
            ivProfile.isHidden = true
            lblName.isHidden = true
            lblMobile.isHidden = true
            ratingView.isHidden = true
            lblBalance.isHidden = true
            lblDue.isHidden = true
            loginView.isHidden  = false
        }
        if ((DataManager.loadUser().data?.roles?.contains(find: "ShopOwner"))!) {
            self.viewMyShops.isHidden = false
        }else {
            self.viewMyShops.isHidden = true
        }
    }
    
    
    func handleNotificationCounter() {
        let count = UserDefaults.standard.value(forKey: Constants.NOTIFICATION_COUNT) as? Int ?? 0
        if (count > 0){
            self.btnCounter.isHidden = false
            // self.btnCounter.setTitle("\(count)", for: .normal)
        }else {
            self.btnCounter.isHidden = true
        }
    }
    
    func handleOrdersCounter() {
        let count = UserDefaults.standard.value(forKey: Constants.ORDERS_COUNT) as? Int ?? 0
        if (count > 0){
            self.btnOrdersCounter.isHidden = false
            // self.btnCounter.setTitle("\(count)", for: .normal)
        }else {
            self.btnOrdersCounter.isHidden = true
        }
    }
    
    func handleWorkingOrdersCounter() {
        if (self.isProvider()) {
            let count = UserDefaults.standard.value(forKey: Constants.WORKING_ORDERS_COUNT) as? Int ?? 0
            if (count > 0){
                self.btnWorkingOrdersCounter.isHidden = false
                // self.btnCounter.setTitle("\(count)", for: .normal)
            }else {
                self.btnWorkingOrdersCounter.isHidden = true
            }
        }else {
            self.btnWorkingOrdersCounter.isHidden = true
        }
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.validateSelectedTag(tag : self.selectedTag)
    }
    
    func validateSelectedTag(tag : Int) {
        self.selectedTag = tag
        self.ivSelect1.isHidden = true
        self.ivSelectNew.isHidden = true
        self.ivSelect2.isHidden = true
        self.ivSelect3.isHidden = true
        self.ivSelect4.isHidden = true
        self.ivSelect5.isHidden = true
        //        self.ivSelect6.isHidden = true
        //        self.ivSelect7.isHidden = true
        //        self.lvSelect8.isHidden = true
        self.ivSelect9.isHidden = true
        self.ivSelect10.isHidden = true
        self.ivSelect11.isHidden = true
        self.ivSelected12.isHidden = true
        switch tag {
        case 1:
            self.ivSelect1.isHidden = false
            break
        case 2:
            self.ivSelect2.isHidden = false
            break
        case 3:
            self.ivSelect3.isHidden = false
            break
        case 4:
            self.ivSelect4.isHidden = false
            break
        case 5:
            self.ivSelect5.isHidden = false
            break
            //        case 6:
            //            self.ivSelect6.isHidden = false
            //            break
            //        case 7:
            //            self.ivSelect7.isHidden = false
            //            break
            //        case 8:
            //            self.lvSelect8.isHidden = false
        //            break
        case 9:
            self.ivSelect9.isHidden = false
            break
        case 10:
            self.ivSelect10.isHidden = false
            break
        case 11:
            self.ivSelect11.isHidden = false
            break
        case 99:
            self.ivSelectNew.isHidden = false
            break
        case 101:
            self.ivSelected12.isHidden = false
            break
        default:
            self.ivSelect1.isHidden = false
            break
        }
    }
    
    @IBAction func onMakeOrder(_ sender: UISwitch) {
        if sender.isOn {
            UserDefaults.standard.set(true, forKey: "dispalyMakeOerderButton")
        } else {
            UserDefaults.standard.set(false, forKey: "dispalyMakeOerderButton")
        }
    }
    
    @IBAction func switchAction(_ sender: UISwitch) {
        self.showLoading()
        if (sender.isOn) {
            ApiService.goOnline(Authorization: DataManager.loadUser().data?.accessToken ?? "") { (response) in
                self.hideLoading()
                let loadedUserData = DataManager.loadUser().data
                let dataClass = DataClass(accessToken: loadedUserData?.accessToken ?? "",
                                          phoneNumber: loadedUserData?.phoneNumber ?? "",
                                          username: loadedUserData?.username ?? "",
                                          fullName: loadedUserData?.fullName ?? "",
                                          userID: loadedUserData?.userID ?? "",
                                          dateOfBirth: loadedUserData?.dateOfBirth ?? "",
                                          profilePicture: loadedUserData?.profilePicture ?? "",
                                          email: loadedUserData?.email ?? "",
                                          gender: loadedUserData?.gender ?? 1,
                                          rate: loadedUserData?.rate ?? 0,
                                          roles: loadedUserData?.roles ?? "",
                                          isOnline: true,
                                          exceededDueAmount: loadedUserData?.exceededDueAmount ?? false,
                                          dueAmount: loadedUserData?.dueAmount ?? 0.0,
                                          earnings: loadedUserData?.earnings ?? 0.0,
                                          balance: loadedUserData?.balance ?? 0.0, isVerified: loadedUserData?.isVerified)
                let verifyResponse = VerifyResponse(data: dataClass, errorCode: 0, errorMessage: "")
                let newUser = self.getRealmUser(userProfile: verifyResponse)
                self.updateUser(newUser)
                self.moodSwitch.isOn = true
            }
        }else {
            ApiService.goOffline(Authorization: DataManager.loadUser().data?.accessToken ?? "") { (response) in
                self.hideLoading()
                let loadedUserData = DataManager.loadUser().data
                let dataClass = DataClass(accessToken: loadedUserData?.accessToken ?? "",
                                          phoneNumber: loadedUserData?.phoneNumber ?? "",
                                          username: loadedUserData?.username ?? "",
                                          fullName: loadedUserData?.fullName ?? "",
                                          userID: loadedUserData?.userID ?? "",
                                          dateOfBirth: loadedUserData?.dateOfBirth ?? "",
                                          profilePicture: loadedUserData?.profilePicture ?? "",
                                          email: loadedUserData?.email ?? "",
                                          gender: loadedUserData?.gender ?? 1,
                                          rate: loadedUserData?.rate ?? 0,
                                          roles: loadedUserData?.roles ?? "",
                                          isOnline: false,
                                          exceededDueAmount: loadedUserData?.exceededDueAmount ?? false,
                                          dueAmount: loadedUserData?.dueAmount ?? 0.0,
                                          earnings: loadedUserData?.earnings ?? 0.0,
                                          balance: loadedUserData?.balance ?? 0.0, isVerified: loadedUserData?.isVerified)
                let verifyResponse = VerifyResponse(data: dataClass, errorCode: 0, errorMessage: "")
                let newUser = self.getRealmUser(userProfile: verifyResponse)
                self.updateUser(newUser)
                self.moodSwitch.isOn = false
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.handleNotificationCounter()
        self.handleOrdersCounter()
        self.handleWorkingOrdersCounter()
        
        let user = DataManager.loadUser()
        let dueAmount = user.data?.dueAmount ?? 0.0
        if (dueAmount >= 0) {
            self.lblDue.textColor = UIColor.app_green
        }else {
            self.lblDue.textColor = UIColor.app_red
        }
        self.lblDue.text = "\("due".localized) \(dueAmount) \("currency".localized)"
    }
    
    @IBAction func onCloseMenuClick(_ button:UIButton!) {
        btnMenu.tag = 0
        
        if (self.delegate != nil) {
            var index = Int32(button.tag)
            if(button == self.btnCloseMenuOverlay){
                index = -1
            }
            delegate?.slideMenuItemSelectedAtIndex(index)
        }
        
        //        UIView.animate(withDuration: 0.3, animations: { () -> Void in
        //            self.view.frame = CGRect(x: -UIScreen.main.bounds.size.width, y: 0, width: UIScreen.main.bounds.size.width,height: UIScreen.main.bounds.size.height)
        //            self.view.layoutIfNeeded()
        //            self.view.backgroundColor = UIColor.clear
        //        }, completion: { (finished) -> Void in
        //            self.view.removeFromSuperview()
        //            self.removeFromParent()
        //        })
        self.closeMenu()
    }
    
    func closeMenu() {
        //        UIView.animate(withDuration: 0.3, animations: { () -> Void in
        //            self.view.frame = CGRect(x: -UIScreen.main.bounds.size.width, y: 0, width: UIScreen.main.bounds.size.width,height: UIScreen.main.bounds.size.height)
        //            self.view.layoutIfNeeded()
        //            self.view.backgroundColor = UIColor.clear
        //        }, completion: { (finished) -> Void in
        //            self.view.removeFromSuperview()
        //            self.removeFromParent()
        //        })
        if (self.isArabic()) {
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                self.view.frame = CGRect(x: UIScreen.main.bounds.size.width, y: 0, width: UIScreen.main.bounds.size.width,height: UIScreen.main.bounds.size.height)
                self.view.layoutIfNeeded()
                self.view.backgroundColor = UIColor.clear
            }, completion: { (finished) -> Void in
                self.view.removeFromSuperview()
                self.removeFromParent()
            })
        }else {
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                self.view.frame = CGRect(x: -UIScreen.main.bounds.size.width, y: 0, width: UIScreen.main.bounds.size.width,height: UIScreen.main.bounds.size.height)
                self.view.layoutIfNeeded()
                self.view.backgroundColor = UIColor.clear
            }, completion: { (finished) -> Void in
                self.view.removeFromSuperview()
                self.removeFromParent()
            })
        }
    }
    
    
    @IBAction func exploreAction(_ sender: Any) {
        self.selectedTag = 1
        self.validateSelectedTag(tag: self.selectedTag)
        delegate?.slideMenuItemSelectedAtIndex(1)
    }
    
    @IBAction func workingOrdersAction(_ sender: Any) {
        if (!self.isLoggedIn()) {
            return
        }
        if (self.isProvider()) {
            self.selectedTag = 99
            self.validateSelectedTag(tag: self.selectedTag)
            delegate?.slideMenuItemSelectedAtIndex(99)
        }else {
            self.selectedTag = 99
            self.validateSelectedTag(tag: self.selectedTag)
            delegate?.slideMenuItemSelectedAtIndex(105)
        }
        
    }
    
    @IBAction func ordersAction(_ sender: Any) {
        if (!self.isLoggedIn()) {
            return
        }
        self.selectedTag = 2
        self.validateSelectedTag(tag: self.selectedTag)
        delegate?.slideMenuItemSelectedAtIndex(2)
    }
    
    @IBAction func notificationsAction(_ sender: Any) {
        if (!self.isLoggedIn()) {
            return
        }
        self.selectedTag = 3
        self.validateSelectedTag(tag: self.selectedTag)
        delegate?.slideMenuItemSelectedAtIndex(3)
    }
    
    
    @IBAction func suggestShopAction(_ sender: Any) {
        delegate?.slideMenuItemSelectedAtIndex(-1)
        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SuggestShopVC") as? SuggestShopVC
        {
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    
    
    @IBAction func settingsAction(_ sender: Any) {
        // self.selectedTag = 4
        // self.validateSelectedTag(tag: self.selectedTag)
        delegate?.slideMenuItemSelectedAtIndex(-1)
        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SettingsVC") as? SettingsVC
        {
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func registeredShopsAction(_ sender: Any) {
        if (!self.isLoggedIn()) {
            return
        }
        self.selectedTag = 5
        self.validateSelectedTag(tag: self.selectedTag)
        delegate?.slideMenuItemSelectedAtIndex(5)
    }
    
    @IBAction func FAQsAction(_ sender: Any) {
        self.selectedTag = 6
        self.validateSelectedTag(tag: self.selectedTag)
        delegate?.slideMenuItemSelectedAtIndex(6)
    }
    
    @IBAction func termsAction(_ sender: Any) {
        self.selectedTag = 7
        self.validateSelectedTag(tag: self.selectedTag)
        delegate?.slideMenuItemSelectedAtIndex(7)
    }
    
    @IBAction func aboutUsAction(_ sender: Any) {
        self.selectedTag = 8
        self.validateSelectedTag(tag: self.selectedTag)
        delegate?.slideMenuItemSelectedAtIndex(8)
    }
    
    @IBAction func contactUsAction(_ sender: Any) {
        self.selectedTag = 9
        self.validateSelectedTag(tag: self.selectedTag)
        delegate?.slideMenuItemSelectedAtIndex(9)
    }
    
    @IBAction func rateAction(_ sender: Any) {
        self.selectedTag = 10
        self.validateSelectedTag(tag: self.selectedTag)
        delegate?.slideMenuItemSelectedAtIndex(10)
    }
    
    
    @IBAction func shareAction(_ sender: Any) {
        self.selectedTag = 11
        self.validateSelectedTag(tag: self.selectedTag)
        delegate?.slideMenuItemSelectedAtIndex(11)
    }
    
    @IBAction func profileAction(_ sender: Any) {
        //        self.closeMenu()
        //        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ProfileVC") as? ProfileVC
        //        {
        //            self.navigationController?.pushViewController(vc, animated: true)
        //        }
        delegate?.slideMenuItemSelectedAtIndex(12)
    }
    
    @IBAction func loginAction(_ sender: Any) {
        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginVC") as? LoginVC
        {
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    @IBAction func myShopsAction(_ sender: Any) {
        self.selectedTag = 101
        self.validateSelectedTag(tag: self.selectedTag)
        delegate?.slideMenuItemSelectedAtIndex(101)
    }
    
    
    
}
