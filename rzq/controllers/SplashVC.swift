//
//  SplashVC.swift
//  rzq
//
//  Created by Zaid najjar on 3/30/19.
//  Copyright © 2019 technzone. All rights reserved.
//

import UIKit

class SplashVC: BaseVC {

    override func viewDidLoad() {
        super.viewDidLoad()
        
      
        ApiService.getAppConfig { (response) in
            App.shared.config = response.configData
            self.startSplashLoader()
        }
    }
    
    
    func startSplashLoader() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            let check = UserDefaults.standard.value(forKey: Constants.DID_CHOOSE_LANGUAGE) as? Bool ?? false
            if (check) {
                let user = self.loadUser()
                if (user.data?.accessToken?.count ?? 0 > 0) {
                    ApiService.refreshToken(Authorization: user.data?.accessToken ?? "") { (response) in
                        if (response.errorCode == 0) {
                            self.updateUser(self.getRealmUser(userProfile: response))
                            if (check) {
                                let mainStoryboardIpad : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                                let initialViewControlleripad : UIViewController = mainStoryboardIpad.instantiateViewController(withIdentifier: self.getHomeView()) as! UINavigationController
                                self.present(initialViewControlleripad, animated: true, completion: {})
                            }else {
                                if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LanguageVC") as? LanguageVC
                                {
                                    self.present(vc, animated: true, completion: nil)
                                }
                            }
                        }else if (response.errorCode == 18) {
                            self.showBanner(title: "alert".localized, message: "account_inactive".localized, style: UIColor.INFO)
                        }else {
                            if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginVC") as? LoginVC
                            {
                                self.present(vc, animated: true, completion: nil)
                            }
                        }
                    }
                }else {
                    if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginVC") as? LoginVC
                    {
                        self.present(vc, animated: true, completion: nil)
                    }
                }
            }else {
                if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LanguageVC") as? LanguageVC
                {
                    self.present(vc, animated: true, completion: nil)
                }
            }
        }
    }

}
