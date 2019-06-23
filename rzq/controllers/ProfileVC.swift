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
    
    var user : DataProfileObj?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (self.isArabic()) {
            self.ivHandle.image = UIImage(named: "ic_back_arabic")
            self.ivIndicator1.image = UIImage(named: "ic_indicator_arabic")
            self.ivIndicator2.image = UIImage(named: "ic_indicator_arabic")
        }
        // Do any additional setup after loading the view.
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.showLoading()
        ApiService.getProfile(Authorization: self.loadUser().data?.accessToken ?? "") { (response) in
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
            
            if ((response.dataProfileObj?.roles?.contains("Driver"))!) {
                self.ivDriverBadge.isHidden = false
                self.viewRegisterDriver.isHidden = true
            }else {
                self.ivDriverBadge.isHidden = true
                self.viewRegisterDriver.isHidden = false
            }
            
            if ((response.dataProfileObj?.roles?.contains("ServiceProvider"))!) {
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
          
            if ((response.dataProfileObj?.roles?.contains("Driver"))! || (response.dataProfileObj?.roles?.contains("ServiceProvider"))! ||
                (response.dataProfileObj?.roles?.contains("TenderProvider"))!) {
                
                self.lineDueAmount.isHidden = false
                self.dueTitleHeight.constant = 20
                self.lblDueTitle.isHidden = false
                let balance = response.dataProfileObj?.balance ?? 0.0
                let perc = App.shared.config?.configSettings?.percentage ?? 0.0
                let total = balance * perc
                let finalTotal = total / 10.0
                self.lblDueAmount.text = "\(finalTotal) \("currency".localized)"
                
            }else {
                self.lineDueAmount.isHidden = true
                self.dueTitleHeight.constant = 0
                self.lblDueTitle.isHidden = true
                self.lblDueAmount.text = ""
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
             self.updateUser(self.getRealmUser(userProfile: VerifyResponse(data: DataClass(accessToken: "", phoneNumber: "", username: "", fullName: "", userID: "", dateOfBirth: "", profilePicture: "", email: "", gender: 0, rate: 0, roles: "", isOnline: false,exceededDueAmount: false, balance: 0.0), errorCode: 0, errorMessage: "")))
            self.deleteUsers()
            if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginVC") as? LoginVC
            {
                self.present(vc, animated: true, completion: nil)
            }
            
        })
    }
}
