//
//  SplashVC.swift
//  rzq
//
//  Created by Zaid najjar on 3/30/19.
//  Copyright © 2019 technzone. All rights reserved.
//

import UIKit
import Firebase

class SplashVC: BaseVC {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        ApiService.getAppConfig { (response) in
            App.shared.config = response.data
            self.startSplashLoader()
        }
        
        let x = Messaging.messaging().fcmToken ?? "not_avaliable"
        
        ApiService.updateRegId(Authorization: self.loadUser().data?.accessToken ?? "", regId: Messaging.messaging().fcmToken ?? "not_avaliable") { (response) in
            
            
        }
    }
    
    
    func startSplashLoader() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let check = UserDefaults.standard.value(forKey: Constants.DID_CHOOSE_LANGUAGE) as? Bool ?? false
            if (check) {
                let user = self.loadUser()
                if (user.data?.accessToken?.count ?? 0 > 0) {
                    ApiService.refreshToken(Authorization: user.data?.accessToken ?? "") { (response) in
                        if (response.errorCode == 0) {
                            self.updateUser(self.getRealmUser(userProfile: response))
                            if (check) {
                                
                                let type = App.shared.notificationType ?? "0"
                                if (type == "0") {
                                    self.loadTracks()
                                }else {
                                    let mainStoryboardIpad : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                                    let initialViewControlleripad : UIViewController = mainStoryboardIpad.instantiateViewController(withIdentifier: self.getHomeView()) as! UINavigationController
                                    initialViewControlleripad.modalPresentationStyle = .fullScreen
                                    self.present(initialViewControlleripad, animated: true, completion: {})
                                }
                            }else {
                                if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LanguageVC") as? LanguageVC
                                {
                                    vc.modalPresentationStyle = .fullScreen
                                    self.present(vc, animated: true, completion: nil)
                                }
                            }
                        }else if (response.errorCode == 18) {
                            self.showBanner(title: "alert".localized, message: "account_inactive".localized, style: UIColor.INFO)
                        }else {
                            if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginVC") as? LoginVC
                            {
                                vc.modalPresentationStyle = .fullScreen
                                self.present(vc, animated: true, completion: nil)
                            }
                        }
                    }
                }else {
                    if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginVC") as? LoginVC
                    {
                        vc.modalPresentationStyle = .fullScreen
                        self.present(vc, animated: true, completion: nil)
                    }
                }
            }else {
                if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LanguageVC") as? LanguageVC
                {
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true, completion: nil)
                }
            }
        }
    }
    
    func loadTracks() {
        ApiService.getOnGoingDeliveries(Authorization: self.loadUser().data?.accessToken ?? "") { (response) in
            if (response.data?.count ?? 0 > 0) {
                let mainStoryboardIpad : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let initialViewControlleripad : UIViewController = mainStoryboardIpad.instantiateViewController(withIdentifier: self.getHomeView()) as! UINavigationController
                initialViewControlleripad.modalPresentationStyle = .fullScreen
                self.present(initialViewControlleripad, animated: true, completion: {})
            }else {
                if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "step1navigation") as? UINavigationController
                {
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true, completion: nil)
                }
            }
        }
    }
    
}
