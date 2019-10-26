//
//  BaseViewController.swift
//  rzq
//
//  Created by Zaid najjar on 3/31/19.
//  Copyright © 2019 technzone. All rights reserved.
//

import UIKit
import MOLH
import RealmSwift
import BRYXBanner
import SVProgressHUD

class BaseViewController: UIViewController, SlideMenuDelegate {
    var selectedTag = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.storeTagValue()
    }
    
    func storeTagValue() {
        guard let topViewController : UIViewController = self.navigationController?.topViewController else {
            return
        }
        let vcName = topViewController.restorationIdentifier
        switch vcName {
        case "HomeMapVC":
            selectedTag = 1
            break
        case "HomeListVC":
            selectedTag = 1
            break
        case "WorkingOrdersVC":
            selectedTag = 99
            break
        case "RegisterAsDriverMenuVC":
            selectedTag = 99
            break
        case "OrdersVC":
            selectedTag = 2
            break
        case "NotificationsVC":
            selectedTag = 3
            break
        case "SettingsVC":
            selectedTag = 4
            break
        case "RegisteredShopsVC":
            selectedTag = 5
            break
        case "FAQsVC":
            selectedTag = 6
            break
        case "TermsVC":
            selectedTag = 7
            break
        case "AboutUsVC":
            selectedTag = 8
            break
        case "ContactUsVC":
            selectedTag = 9
            break
        case "MyShopsVC":
            selectedTag = 101
            break
        default:
            selectedTag = 1
            break
        }
    }
    
    func isProvider() -> Bool {
        if ((self.loadUser().data?.roles?.contains(find: "Driver"))! || (self.loadUser().data?.roles?.contains(find: "ServiceProvider"))! || (self.loadUser().data?.roles?.contains(find: "TenderProvider"))!) {
            return true
        }
        return false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func slideMenuItemSelectedAtIndex(_ index: Int32) {
        switch(index){
        case 1:
            self.openViewControllerBasedOnIdentifier(self.getSubHomeView())
            break
        case 99:
            self.openViewControllerBasedOnIdentifier("WorkingOrdersVC")
            break
        case 2:
            self.openViewControllerBasedOnIdentifier("OrdersVC")
            break
        case 3:
            self.openViewControllerBasedOnIdentifier("NotificationsVC")
            break
        case 4:
            self.openViewControllerBasedOnIdentifier("SettingsVC")
            break
        case 5:
            self.openViewControllerBasedOnIdentifier("RegisteredShopsVC")
            break
        case 6:
            self.openViewControllerBasedOnIdentifier("FAQsVC")
            break
        case 7:
            self.openViewControllerBasedOnIdentifier("TermsVC")
            break
        case 8:
            self.openViewControllerBasedOnIdentifier("AboutUsVC")
            break
        case 9:
            self.openViewControllerBasedOnIdentifier("ContactUsVC")
            break
        case 101:
            self.openViewControllerBasedOnIdentifier("MyShopsVC")
            break
        case 10:
            //rate action
            self.openAppStore()
            break
        case 11:
            //share action
            if (self.isArabic()) {
                self.shareAction(content: "\(App.shared.config?.configString?.arabicTellAFriend ?? "")\n\n\(App.shared.config?.updateStatus?.iosAppURL ?? "")")
            }else {
                self.shareAction(content: "\(App.shared.config?.configString?.englishTellAFriend ?? "")\n\n\(App.shared.config?.updateStatus?.iosAppURL ?? "")")
            }
            break
        case 12:
            //profile
            self.openViewControllerBasedOnIdentifier("ProfileVC")
            break
        case 105:
            //register driver
            self.openViewControllerBasedOnIdentifier("RegisterAsDriverMenuVC")
            break
        default:
            print("default\n", terminator: "")
        }
    }
    
    
    func openAppStore() {
        if let url = URL(string: "itms-apps://itunes.apple.com/app/id1459027070"),
            UIApplication.shared.canOpenURL(url){
            UIApplication.shared.open(url, options: [:]) { (opened) in
                if(opened){
                    print("App Store Opened")
                }
            }
        } else {
            print("Can't Open URL on Simulator")
        }
    }
    
    
    func shareAction(content : String){
        let textToShare = [ content ]
        let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
        
        // exclude some activity types from the list (optional)
        activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop, UIActivity.ActivityType.postToFacebook ]
        
        // present the view controller
        self.present(activityViewController, animated: true, completion: nil)
        
    }
    
    
    func getSubHomeView() -> String {
        if (App.shared.config?.configSettings?.isMapView ?? true) {
            return "HomeMapVC"
        }else {
            return "HomeMapVC"
        }
    }
    
    func getHomeView() -> String {
        if (App.shared.config?.configSettings?.isMapView ?? true) {
            // return "HomeMapVC"
            return "MapNavigationController"
        }else {
            //  return "HomeListVC"
            return "MapNavigationController"
        }
    }
    
    
    func openViewControllerBasedOnIdentifier(_ strIdentifier:String) {
        let destViewController : UIViewController = self.storyboard!.instantiateViewController(withIdentifier: strIdentifier)
        
        //temperorary fixed crash
        //        if (self.navigationController?.topViewController == nil) {
        //            return
        //        }
        
        guard let topViewController : UIViewController = self.navigationController?.topViewController else {
            return
        }
        
        if (topViewController.restorationIdentifier! == destViewController.restorationIdentifier!){
            print("Same VC")
        } else {
            self.navigationController!.pushViewController(destViewController, animated: true)
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    func getFontName() -> String {
        if (self.isArabic()) {
            return Constants.ARABIC_FONT_REGULAR
        }else {
            return Constants.ENGLISH_FONT_REGULAR
        }
    }
    
    //    func addSlideMenuButton(){
    //        let btnShowMenu = UIButton(type: UIButton.ButtonType.system)
    //        btnShowMenu.setImage(self.defaultMenuImage(), for: UIControl.State())
    //        btnShowMenu.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
    //        btnShowMenu.addTarget(self, action: #selector(BaseViewController.onSlideMenuButtonPressed(_:)), for: UIControl.Event.touchUpInside)
    //        let customBarItem = UIBarButtonItem(customView: btnShowMenu)
    //        self.navigationItem.leftBarButtonItem = customBarItem;
    //    }
    //
    //    func defaultMenuImage() -> UIImage {
    //        var defaultMenuImage = UIImage()
    //
    //        UIGraphicsBeginImageContextWithOptions(CGSize(width: 30, height: 22), false, 0.0)
    //
    //        UIColor.black.setFill()
    //        UIBezierPath(rect: CGRect(x: 0, y: 3, width: 30, height: 1)).fill()
    //        UIBezierPath(rect: CGRect(x: 0, y: 10, width: 30, height: 1)).fill()
    //        UIBezierPath(rect: CGRect(x: 0, y: 17, width: 30, height: 1)).fill()
    //
    //        UIColor.white.setFill()
    //        UIBezierPath(rect: CGRect(x: 0, y: 4, width: 30, height: 1)).fill()
    //        UIBezierPath(rect: CGRect(x: 0, y: 11,  width: 30, height: 1)).fill()
    //        UIBezierPath(rect: CGRect(x: 0, y: 18, width: 30, height: 1)).fill()
    //
    //        defaultMenuImage = UIGraphicsGetImageFromCurrentImageContext()!
    //
    //        UIGraphicsEndImageContext()
    //
    //        return defaultMenuImage;
    //    }
    
    @objc func  onAboutPressed(_ sender : UIButton) {
        //selectedTag = 8
        // self.openViewControllerBasedOnIdentifier("AboutUsVC")
    }
    
    @objc func onSlideMenuButtonPressed(_ sender : UIButton) {
        if (sender.tag == 10)
        {
            // To Hide Menu If it already there
            self.slideMenuItemSelectedAtIndex(-1);
            
            sender.tag = 0;
            
            let viewMenuBack : UIView = view.subviews.last!
            
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                var frameMenu : CGRect = viewMenuBack.frame
                frameMenu.origin.x = -1 * UIScreen.main.bounds.size.width
                viewMenuBack.frame = frameMenu
                viewMenuBack.layoutIfNeeded()
                viewMenuBack.backgroundColor = UIColor.clear
            }, completion: { (finished) -> Void in
                viewMenuBack.removeFromSuperview()
            })
            
            
            return
        }
        
        sender.isEnabled = false
        sender.tag = 10
        
        let menuVC : MenuViewController = self.storyboard!.instantiateViewController(withIdentifier: "MenuViewController") as! MenuViewController
        menuVC.btnMenu = sender
        menuVC.delegate = self
        self.view.addSubview(menuVC.view)
        self.addChild(menuVC)
        menuVC.view.layoutIfNeeded()
        
        if (self.isArabic()) {
            menuVC.view.frame=CGRect(x: UIScreen.main.bounds.size.width, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height);
        }else {
            menuVC.view.frame=CGRect(x: 0 - UIScreen.main.bounds.size.width, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height);
        }
        
        
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            menuVC.view.frame=CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height);
            sender.isEnabled = true
        }, completion:nil)
        menuVC.validateSelectedTag(tag : self.selectedTag)
    }
    
    func isArabic() -> Bool {
        if (MOLHLanguage.currentAppleLanguage() == "ar") {
            return true
        }else {
            return false
        }
    }
    
    func showBanner(title:String, message:String,style: UIColor) {
        let banner = Banner(title: title, subtitle: message, image: nil, backgroundColor: style)
        banner.dismissesOnTap = true
        banner.textColor = UIColor.white
        if (isArabic()) {
            banner.titleLabel.font = UIFont(name: Constants.ARABIC_FONT_REGULAR, size: 16)
            banner.detailLabel.font = UIFont(name: Constants.ARABIC_FONT_REGULAR, size: 14)
        }else {
            banner.titleLabel.font = UIFont(name: Constants.ENGLISH_FONT_REGULAR, size: 16)
            banner.detailLabel.font = UIFont(name: Constants.ENGLISH_FONT_REGULAR, size: 14)
        }
        
        banner.show(duration: 2.0)
    }
    
    func showLoading() {
        SVProgressHUD.show()
    }
    func hideLoading() {
        SVProgressHUD.dismiss()
    }
    
    
    func deleteUsers() {
        let realm = try! Realm()
        let results = realm.objects(RealmUser.self)
        try! realm.write {
            realm.delete(results)
        }
    }
    
    func getRealmUser (userProfile  : VerifyResponse) -> RealmUser {
        
        let realmUser = RealmUser()
        
        realmUser.access_token = userProfile.data?.accessToken ?? ""
        realmUser.phone_number = userProfile.data?.phoneNumber ?? ""
        realmUser.user_name = userProfile.data?.username ?? ""
        realmUser.full_name = userProfile.data?.fullName ?? ""
        realmUser.userId = userProfile.data?.userID ?? ""
        realmUser.date_of_birth = userProfile.data?.dateOfBirth ?? ""
        realmUser.profile_picture = userProfile.data?.profilePicture ?? ""
        realmUser.email = userProfile.data?.email ?? ""
        realmUser.gender = userProfile.data?.gender ?? 1
        realmUser.rate = userProfile.data?.rate ?? 0.0
        realmUser.roles = userProfile.data?.roles ?? ""
        realmUser.isOnline = userProfile.data?.isOnline ?? false
        realmUser.exceeded_amount = userProfile.data?.exceededDueAmount ?? false
        realmUser.dueAmount = userProfile.data?.dueAmount ?? 0.0
        realmUser.earnings = userProfile.data?.earnings ?? 0.0
        realmUser.balance = userProfile.data?.balance ?? 0.0
        
        return realmUser
    }
    
    
    func getUser (realmUser  : RealmUser) -> VerifyResponse {
        let userData = DataClass(accessToken: realmUser.access_token, phoneNumber: realmUser.phone_number, username: realmUser.user_name, fullName: realmUser.full_name, userID: realmUser.userId, dateOfBirth: realmUser.date_of_birth, profilePicture: realmUser.profile_picture, email: realmUser.email, gender: realmUser.gender, rate: realmUser.rate, roles: realmUser.roles, isOnline: realmUser.isOnline,exceededDueAmount : realmUser.exceeded_amount, dueAmount: realmUser.dueAmount, earnings: realmUser.earnings, balance: realmUser.balance)
        let verifyResponse = VerifyResponse(data: userData, errorCode: 0, errorMessage: "")
        
        return verifyResponse
    }
    
    func updateUser(_ objects: RealmUser) {
        let realm = try! Realm()
        try! realm.write {
            realm.add(objects, update: true)
        }
    }
    
    
    func loadUser() -> VerifyResponse{
        let realm = try! Realm()
        let realmUser = Array(realm.objects(RealmUser.self))
        if (realmUser.count > 0) {
            return self.getUser(realmUser: realmUser[0])
        }else {
            return VerifyResponse(data: DataClass(accessToken: "", phoneNumber: "", username: "", fullName: "", userID: "", dateOfBirth: "", profilePicture: "", email: "", gender: 1, rate: 0, roles: "", isOnline: false, exceededDueAmount: false, dueAmount: 0.0, earnings: 0.0, balance: 0.0), errorCode: 0, errorMessage: "")
        }
        
    }
    
    
    func showAlert(title: String,
                   message: String,
                   actionTitle: String,
                   cancelTitle: String,
                   actionHandler:(()->Void)?,
                   cancelHandler:(()->Void)? = nil) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: actionTitle, style: .default) { (action) in
            actionHandler?()
        }
        
        let cancelAction = UIAlertAction(title: cancelTitle, style: .cancel) { (action) in
            cancelHandler?()
        }
        
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    func showAlertOK(title: String,
                     message: String,
                     actionTitle: String,
                     cancelHandler:(()->Void)? = nil) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: actionTitle, style: .default) { (action) in
            cancelHandler?()
        }
        
        alert.addAction(okAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    func isLoggedIn() -> Bool{
        if (self.loadUser().data?.userID?.count ?? 0 > 0) {
            return true
        }else {
            self.showAlert(title: "alert".localized, message: "not_logged_in".localized, actionTitle: "login".localized, cancelTitle: "no".localized, actionHandler: {
                //login
                if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginVC") as? LoginVC
                {
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true, completion: nil)
                }
                
            }) {
                //no
            }
            return false
        }
    }
    func isLoggedInNoAlert() -> Bool{
        if (self.loadUser().data?.userID?.count ?? 0 > 0) {
            return true
        }else {
            return false
        }
    }
    
    
    
}
