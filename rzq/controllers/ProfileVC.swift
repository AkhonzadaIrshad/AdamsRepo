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
    
    var user : DataProfileObj?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (self.isArabic()) {
            self.ivHandle.image = UIImage(named: "ic_back_arabic")
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
            
//            if ((response.dataProfileObj?.roles?.contains("ServiceProvider"))!) {
//                self.ivProviderBadge.isHidden = false
//            }else {
//                self.ivProviderBadge.isHidden = true
//            }
            
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
        
    }
    
    @IBAction func logoutAction(_ sender: Any) {
        self.showAlert(title: "alert".localized, message: "confirm_logout".localized, actionTitle: "logout".localized, cancelTitle: "cancel".localized, actionHandler: {
             self.updateUser(self.getRealmUser(userProfile: VerifyResponse(data: DataClass(accessToken: "", phoneNumber: "", username: "", fullName: "", userID: "", dateOfBirth: "", profilePicture: "", email: "", gender: 0, rate: 0, roles: "", isOnline: false,exceededDueAmount: false), errorCode: 0, errorMessage: "")))
            self.deleteUsers()
            if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginVC") as? LoginVC
            {
                self.present(vc, animated: true, completion: nil)
            }
            
        })
    }
}
