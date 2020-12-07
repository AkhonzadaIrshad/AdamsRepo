//
//  ProfileVC.swift
//  rzq
//
//  Created by Zaid najjar on 4/7/19.
//  Copyright © 2019 technzone. All rights reserved.
//

import UIKit
import Cosmos

class ProfileVC: BaseVC {

    @IBOutlet weak var btnEditProfile: MyUIButton!
    @IBOutlet weak var ivProfile: CircleImage!
    @IBOutlet weak var ivDriverBadge: UIImageView!
    @IBOutlet weak var ivProviderBadge: UIImageView!
    @IBOutlet weak var withrowButton: UIButton!
    
    @IBOutlet weak var ivHandle: UIImageView!
    
    @IBOutlet weak var lblName: MyUILabel!
    
    @IBOutlet weak var ratingView: CosmosView!
    
    @IBOutlet weak var lblBalance: MyUILabel!
    
    @IBOutlet weak var lblOrderCount: MyUILabel!
    
    @IBOutlet weak var edtCoupon: MyUITextField!
    
    @IBOutlet weak var viewRegisterDriver: UIView!
    @IBOutlet weak var viewRegisterPRovider: UIView!
    
    @IBOutlet weak var ivIndicator1: UIImageView!
    
    @IBOutlet weak var ivIndicator2: UIImageView!
    
    
    @IBOutlet weak var lblDueAmount: MyUILabel!
    @IBOutlet weak var lineDueAmount: UIView!
    @IBOutlet weak var lblDueTitle: MyUILabel!
    @IBOutlet weak var dueTitleHeight: NSLayoutConstraint!
    
    
    @IBOutlet weak var viewEarnings: UIView!
    @IBOutlet weak var earningsHeight: NSLayoutConstraint!
    @IBOutlet weak var lblEarnings: MyUILabel!
    
    @IBOutlet weak var navBar: NavBar!
    
    var user : DataProfileObj?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (self.isArabic()) {
            self.ivHandle.image = UIImage(named: "ic_back_arabic")
            self.ivIndicator1.image = UIImage(named: "ic_indicator_arabic")
            self.ivIndicator2.image = UIImage(named: "ic_indicator_arabic")
        }
        if DataManager.loadUser().data?.roles?.contains(find: "Driver") ?? false {
            self.navBar.isHidden = false
        } else {
            self.navBar.isHidden = true
        }
        self.navBar.delegate = self        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navBar.refreshCounters()
       self.loadProfileData()
    }
    
    func loadProfileData() {
        self.showLoading()
        ApiService.getProfile(Authorization: DataManager.loadUser().data?.accessToken ?? "") { (response) in
            self.hideLoading()
            self.user = response.dataProfileObj
            
            let urlStr = response.dataProfileObj?.image ?? ""
            if (urlStr.count > 0) {
                let url = URL(string: "\(Constants.IMAGE_URL)\(response.dataProfileObj?.image ?? "")")
                self.ivProfile.kf.setImage(with: url)
            }
            
            self.lblName.text = response.dataProfileObj?.fullName ?? ""
            self.lblBalance.text = "\(response.dataProfileObj?.balance ?? 0) \("currency".localized)"
            self.lblOrderCount.text = "\(response.dataProfileObj?.ordersCount ?? 0)"
            
            self.ratingView.rating = Double(response.dataProfileObj?.rate ?? 0)
            self.ratingView.isUserInteractionEnabled = false
            
            if ((response.dataProfileObj?.roles?.contains("Driver") ?? false)) {
                self.ivDriverBadge.isHidden = false
                self.viewRegisterDriver.isHidden = true
            }else {
                self.ivDriverBadge.isHidden = true
                self.viewRegisterDriver.isHidden = false
            }
            
            if ((response.dataProfileObj?.roles?.contains("ServiceProvider")) ?? false) {
                self.ivProviderBadge.isHidden = false
                self.viewRegisterPRovider.isHidden = true
            }else {
                self.ivDriverBadge.isHidden = true
                self.viewRegisterPRovider.isHidden = true
            }
            
            //            if ((response.dataProfileObj?.roles?.contains("ServiceProvider"))!) {
            //                self.ivProviderBadge.isHidden = false
            //            }else {
            //                self.ivProviderBadge.isHidden = true
            //            }
            
            if ((response.dataProfileObj?.roles?.contains("Driver")) ?? false || (response.dataProfileObj?.roles?.contains("ServiceProvider")) ?? false ||
                (response.dataProfileObj?.roles?.contains("TenderProvider")) ?? false) {
                
                self.lineDueAmount.isHidden = false
                self.dueTitleHeight.constant = 20
                self.lblDueTitle.isHidden = false
                let balance = response.dataProfileObj?.earnings ?? 0.0
                let perc = App.shared.config?.configSettings?.percentage ?? 0.0
                let total = balance * perc
                let finalTotal = total / 10.0
                self.lblDueAmount.text = "\(response.dataProfileObj?.dueAmount ?? 0.0) \("currency".localized)"
                
                if response.dataProfileObj?.dueAmount ?? 0 >= -10 {
                    self.withrowButton.isHidden = false
                } else {
                    self.withrowButton.isHidden = true
                }
                self.viewEarnings.isHidden = false
                self.earningsHeight.constant = 51
                self.lblEarnings.text = "\(response.dataProfileObj?.earnings ?? 0) \("currency".localized)"
                
            }else {
                self.lineDueAmount.isHidden = true
                self.dueTitleHeight.constant = 0
                self.lblDueTitle.isHidden = true
                self.withrowButton.isHidden = true
                self.lblDueAmount.text = ""
                self.viewEarnings.isHidden = true
                self.earningsHeight.constant = 0
            }
            
        }
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func editProfileAction(_ sender: Any) {
        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "EditProfileVC") as? EditProfileVC
        {
            vc.user = self.user
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func redeemCouponAction(_ sender: Any) {
        if (edtCoupon.text?.count ?? 0 > 0) {
            self.showLoading()
            ApiService.redeemCoupon(Authorization: DataManager.loadUser().data?.accessToken ?? "", code: self.edtCoupon.text ?? "") { (response) in
                self.hideLoading()
                if (response.errorCode ?? 0 == 0) {
                    self.edtCoupon.text = ""
                    self.showBanner(title: "alert".localized, message: "coupon_added".localized, style: UIColor.SUCCESS)
                    self.loadProfileData()
                }else {
                       self.showBanner(title: "alert".localized, message: response.errorMessage ?? "", style: UIColor.INFO)
                }
            }
        }else {
            self.showBanner(title: "alert".localized, message: "enter_coupon".localized, style: UIColor.INFO)
        }
    }
    
    
    @IBAction func registerDriver(_ sender: Any) {
        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RegisterDriverVC") as? RegisterDriverVC
        {
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func registerProvider(_ sender: Any) {
        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RegisterAsServiceProviderVC") as? RegisterAsServiceProviderVC
        {
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func logoutAction(_ sender: Any) {
        self.showAlert(title: "alert".localized, message: "confirm_logout".localized, actionTitle: "logout".localized, cancelTitle: "cancel".localized, actionHandler: {
             self.updateUser(self.getRealmUser(userProfile: VerifyResponse(data: DataClass(accessToken: "", phoneNumber: "", username: "", fullName: "", userID: "", dateOfBirth: "", profilePicture: "", email: "", gender: 0, rate: 0, roles: "", isOnline: false,exceededDueAmount: false, dueAmount: 0.0, earnings: 0.0, balance: 0.0), errorCode: 0, errorMessage: "")))
            self.deleteUsers()
            if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginVC") as? LoginVC
            {
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true, completion: nil)
            }
            
        })
    }
}

extension ProfileVC: NavBarDelegate {
   func goToHomeScreen() {
       self.slideMenuItemSelectedAtIndex(1)
   }
   
   func goToOrdersScreen() {
       self.slideMenuItemSelectedAtIndex(99)
   }
   
   func goToNotificationsScreen() {
       self.slideMenuItemSelectedAtIndex(3)
   }
   
   func goToProfileScreen() {
       self.slideMenuItemSelectedAtIndex(12)
   }
}
