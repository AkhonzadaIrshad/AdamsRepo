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
        // self.swipeToPop()
        // Do any additional setup after loading the view.
        SVProgressHUD.setDefaultMaskType(.clear)
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
    
    func showAlertField(title: String,
                        message: String,
                        actionTitle: String,
                        cancelTitle: String,
                        completion:@escaping(_ reason : String)-> Void) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        var inputTextField: UITextField?
        inputTextField?.placeholder = "reason_here".localized
        inputTextField?.textColor = UIColor.black
        inputTextField?.font = UIFont(name: self.getFontName(), size: 14.0)
        
        alert.addTextField { textField -> Void in
            // you can use this text field
            inputTextField = textField
            inputTextField?.placeholder = "reason_here".localized
            inputTextField?.textColor = UIColor.black
            inputTextField?.font = UIFont(name: self.getFontName(), size: 14.0)
        }
        
        let okAction = UIAlertAction(title: actionTitle, style: .default) { (action) in
            completion(inputTextField?.text ?? "")
        }
        
        let cancelAction = UIAlertAction(title: cancelTitle, style: .cancel) { (action) in
            //nth
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
    
    func updateUser(_ objects: RealmUser) {
        let realm = try! Realm()
        try! realm.write {
            realm.add(objects, update: true)
        }
    }
    
    func isLoggedIn() -> Bool{
        if (DataManager.loadUser().data?.userID?.count ?? 0 > 0) {
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
    
    func isProvider() -> Bool {
        if ((DataManager.loadUser().data?.roles?.contains(find: "Driver"))! || (DataManager.loadUser().data?.roles?.contains(find: "ServiceProvider"))! || (DataManager.loadUser().data?.roles?.contains(find: "TenderProvider"))!) {
            return true
        }
        return false
    }
    
    func convertDate(isoDate: String) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
        let date = dateFormatter.date(from:isoDate)!
        dateFormatter.dateFormat = "dd/MM/yyyy hh:mm a"
        let displayDate = dateFormatter.string(from: date)
        return displayDate
    }
    
    
}
