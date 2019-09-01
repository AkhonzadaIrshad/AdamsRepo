//
//  BaseVC.swift
//  rzq
//
//  Created by Zaid najjar on 3/30/19.
//  Copyright © 2019 technzone. All rights reserved.
//

import UIKit
import MOLH
import RealmSwift
import BRYXBanner
import SVProgressHUD

class BaseVC: UIViewController,UIGestureRecognizerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.swipeToPop()
        // Do any additional setup after loading the view.
    }
    func swipeToPop() {
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        if gestureRecognizer == self.navigationController?.interactivePopGestureRecognizer {
            return false
        }
        return true
    }
    
    
    func isArabic() -> Bool {
        if (MOLHLanguage.currentAppleLanguage() == "ar") {
            return true
        }else {
            return false
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
    
    
    func getFontName() -> String {
        if (self.isArabic()) {
            return Constants.ARABIC_FONT_REGULAR
        }else {
            return Constants.ENGLISH_FONT_REGULAR
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
    
    
    func showAlert(title:String,
                   message:String,
                   buttonText:String = "Ok".localized,
                   actionHandler:(()->())? = nil) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: buttonText, style: UIAlertAction.Style.default) { (action) in
            actionHandler?()
        }
        
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
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
    
    func showAlertWithCancel(title: String,
                   message: String,
                   actionTitle: String,
                   cancelTitle: String,
                   actionHandler:(()->Void)?,
                   cancelHandler:(()->Void)? = nil) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: actionTitle, style: .default) { (action) in
            actionHandler?()
        }
        
        let cancelAction = UIAlertAction(title: cancelTitle, style: .default) { (action) in
            cancelHandler?()
        }
        let dismissAction = UIAlertAction(title: "cancel".localized, style: .cancel) {
            UIAlertAction in
            
        }
        
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        alert.addAction(dismissAction)
        self.present(alert, animated: true, completion: nil)
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
         let userData = DataClass(accessToken: realmUser.access_token, phoneNumber: realmUser.phone_number, username: realmUser.user_name, fullName: realmUser.full_name, userID: realmUser.userId, dateOfBirth: realmUser.date_of_birth, profilePicture: realmUser.profile_picture, email: realmUser.email, gender: realmUser.gender, rate: realmUser.rate, roles: realmUser.roles, isOnline: realmUser.isOnline,exceededDueAmount: realmUser.exceeded_amount, dueAmount: realmUser.dueAmount, earnings: realmUser.earnings, balance: realmUser.balance)
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
            return VerifyResponse(data: DataClass(accessToken: "", phoneNumber: "", username: "", fullName: "", userID: "", dateOfBirth: "", profilePicture: "", email: "", gender: 1, rate: 0, roles: "", isOnline: false,exceededDueAmount: false, dueAmount: 0.0, earnings: 0.0, balance: 0.0), errorCode: 0, errorMessage: "")
        }
        
    }
    
    func isLoggedIn() -> Bool{
        if (self.loadUser().data?.userID?.count ?? 0 > 0) {
            return true
        }else {
            self.showAlert(title: "alert".localized, message: "not_logged_in".localized, actionTitle: "login".localized, cancelTitle: "no".localized, actionHandler: {
                //login
                if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginVC") as? LoginVC
                {
                    self.present(vc, animated: true, completion: nil)
                }
                
            }) {
                //no
            }
            return false
        }
    }
    
    func isProvider() -> Bool {
        if ((self.loadUser().data?.roles?.contains(find: "Driver"))! || (self.loadUser().data?.roles?.contains(find: "ServiceProvider"))! || (self.loadUser().data?.roles?.contains(find: "TenderProvider"))!) {
            return true
        }
        return false
    }
    
    
}
