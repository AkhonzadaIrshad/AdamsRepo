//
//  LoginVC.swift
//  rzq
//
//  Created by Zaid najjar on 3/31/19.
//  Copyright © 2019 technzone. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField
import CountryPickerView
import SVProgressHUD

class LoginVC: BaseVC, CountryPickerViewDataSource, CountryPickerViewDelegate, PhoneVerificationDelegate {
    
    @IBOutlet weak var edtUserName: SkyFloatingLabelTextField!
    
    @IBOutlet weak var edtMobileNumber: SkyFloatingLabelTextField!
    
    @IBOutlet weak var ivHandle: UIImageView!
    
    @IBOutlet weak var lblTerms: MyUILabel!
    
    @IBOutlet weak var countryPicker: CountryPickerView!
    
    var attributedString = NSMutableAttributedString(string:"")
    
    
    @IBOutlet weak var lblGender: MyUILabel!
    @IBOutlet weak var genderSegment: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SVProgressHUD.setDefaultMaskType(.clear)
        
        self.edtUserName.title = "name".localized
        self.edtUserName.placeholder = "name".localized
        self.edtUserName.selectedTitle = "name".localized
        self.edtUserName.font = UIFont(name: self.getFontName(), size: 14)
        
        self.edtMobileNumber.font = UIFont(name: Constants.ARABIC_FONT_REGULAR, size: 14)
        
        self.edtMobileNumber.title = "mobile_number".localized
        self.edtMobileNumber.placeholder = "mobile_number".localized
        self.edtMobileNumber.selectedTitle = "mobile_number".localized
        
        if (self.isArabic()) {
            self.edtUserName.textAlignment = NSTextAlignment.right
            self.edtMobileNumber.textAlignment = NSTextAlignment.right
        }
        
        self.lblTerms.attributedText = NSAttributedString(string: "agree_terms".localized, attributes:
            [.underlineStyle: NSUnderlineStyle.single.rawValue])
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(LoginVC.openTerms))
        self.lblTerms.isUserInteractionEnabled = true
        self.lblTerms.addGestureRecognizer(tap)
        
        
        self.edtMobileNumber.delegate = self
        self.countryPicker.dataSource = self
        self.countryPicker.delegate = self
        self.countryPicker.textColor = UIColor.appDarkBlue
        self.countryPicker.font = UIFont(name: Constants.ARABIC_FONT_REGULAR, size: 14)!
        self.countryPicker.showPhoneCodeInView = true
        self.countryPicker.showCountryCodeInView = false
        self.countryPicker.setCountryByCode("KW")
        // Do any additional setup after loading the view.
        if (self.isArabic()) {
            self.ivHandle.image = UIImage(named: "bg_circular_arabic")
        }
        
        self.edtUserName.addDoneButtonOnKeyboard()
        self.edtMobileNumber.addDoneButtonOnKeyboard()
        
        let flag = App.shared.config?.configSettings?.flag ?? false
        if (flag == false) {
            self.checkForUpdates()
        }
        
        self.genderSegment.setTitle("female".localized, forSegmentAt: 0)
        self.genderSegment.setTitle("male".localized, forSegmentAt: 1)
        
        
        let titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        let titleTextAttributes2 = [NSAttributedString.Key.foregroundColor: UIColor.black]
        
        self.genderSegment.setTitleTextAttributes(titleTextAttributes2, for: .normal)
        self.genderSegment.setTitleTextAttributes(titleTextAttributes, for: .selected)
        
//        if (flag == true) {
//            self.lblGender.isHidden = true
//            self.genderSegment.isHidden = true
//        }else {
//            self.lblGender.isHidden = false
//            self.genderSegment.isHidden = false
//        }
//    
}


func checkForUpdates() {
    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0".replacedArabicDigitsWithEnglish
    let doubleAppVersion : Double = appVersion.toDouble() ?? 0.0
    let CMSVersion = App.shared.config?.updateStatus?.iosVersion ?? appVersion
    let doubleCmsVersion : Double = CMSVersion.toDouble() ?? 0.0
    let isMand = App.shared.config?.updateStatus?.iosIsMandatory ?? false
    
    if (doubleAppVersion < doubleCmsVersion){
        if (isMand){
            //mandatory
            if (self.isArabic()) {
                self.showMandUpdateDialog(titleStr: "mandatory_update".localized, desc: App.shared.config?.configString?.arabicNewVersionText ?? "new_update_available".localized)
            } else {
                self.showMandUpdateDialog(titleStr: "mandatory_update".localized, desc: App.shared.config?.configString?.englishNewVersionText ?? "new_update_available".localized)
            }
            
        }else {
            //normal
            let defaults = UserDefaults.standard
            var updateCount = defaults.value(forKey: "UPDATE_COUNT_CLICK") as? Int ?? 4
            if (updateCount >= 4) {
                defaults.setValue(1, forKey: "UPDATE_COUNT_CLICK")
                if (self.isArabic()) {
                    self.showNormUpdateDialog(titleStr: "new_update".localized, desc: App.shared.config?.configString?.arabicNewVersionText ?? "new_update_available".localized)
                } else {
                    self.showNormUpdateDialog(titleStr: "new_update".localized, desc: App.shared.config?.configString?.englishNewVersionText ?? "new_update_available".localized)
                }
            }else {
                updateCount = defaults.value(forKey: "UPDATE_COUNT_CLICK") as? Int ?? 1
                defaults.setValue((updateCount + 1), forKey: "UPDATE_COUNT_CLICK")
            }
        }
    }
    
}


func showNormUpdateDialog(titleStr : String, desc : String) {
    let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "normdialogvc") as! NormUpdateDialog
    viewController.dialogTitleStr = titleStr
    viewController.dialogDescStr = desc
    self.present(viewController, animated: true, completion: nil)
}

func showMandUpdateDialog(titleStr : String, desc : String) {
    let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "manddialogvc") as! MandIUpdateDialog
    viewController.dialogTitleStr = titleStr
    viewController.dialogDescStr = desc
    self.present(viewController, animated: true, completion: nil)
}

func countryPickerView(_ countryPickerView: CountryPickerView, didSelectCountry country: Country) {
    self.countryPicker.setCountryByCode(country.code)
}

func showOnlyPreferredSection(in countryPickerView: CountryPickerView) -> Bool {
    return true
}

func preferredCountries(in countryPickerView: CountryPickerView) -> [Country] {
    var countries = [Country]()
    ["KW"].forEach { code in
        if let country = countryPickerView.getCountryByCode(code) {
            countries.append(country)
        }
    }
    return countries
}

func sectionTitleForPreferredCountries(in countryPickerView: CountryPickerView) -> String? {
    return "select_country".localized
}

@IBAction func nextAction(_ sender: Any) {
    if (self.validateFields()) {
        self.showLoading()
        var code = self.countryPicker.selectedCountry.phoneCode
        code = code.replacingOccurrences(of: "+", with: "")
        var mobile = (self.edtMobileNumber.text ?? "").replacedArabicDigitsWithEnglish
        if (mobile.starts(with: "0")) {
            mobile = String(mobile.dropFirst())
        }
        var gender = 2
        if (self.genderSegment.selectedSegmentIndex == 1) {
            gender = 1
        }
        ApiService.registerUser(phoneNumber: "\(code)\(mobile)", fullName: self.edtUserName.text ?? "", email: "", birthDate: "", gender: gender, isResend: false) { (response) in
            self.hideLoading()
            if (response.errorCode == 0) {
                self.showLoading()
                ApiService.verifyPinCode(userId: response.data ?? "", code: "5555") { (response, status) in
                    self.hideLoading()
                    if (status != 0) {
                        self.showBanner(title: "alert".localized, message: "wrong_verification_code".localized, style: UIColor.INFO)
                        return
                    }
                    if (response?.errorCode == 0) {
                        self.deleteUsers()
                        self.updateUser(self.getRealmUser(userProfile: response!))
                    
                        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HomeMapVC") as? HomeMapVC
                        {
                            vc.modalPresentationStyle = .fullScreen
                            let navVC = UINavigationController(rootViewController: vc)
                            navVC.navigationBar.isHidden = true
                            navVC.modalPresentationStyle = .fullScreen
                            self.present(navVC, animated: true, completion: nil)
                        }
                        
                        
                    }else if (response?.errorCode == 18) {
                        self.showBanner(title: "alert".localized, message: "account_inactive".localized, style: UIColor.INFO)
                    }else {
                        self.showBanner(title: "alert".localized, message: "wrong_verification_code".localized, style: UIColor.INFO)
                    }
                }
                
//                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PhoneVerificationDialog") as! PhoneVerificationDialog
//                self.definesPresentationContext = true
//                vc.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
//                vc.view.backgroundColor = UIColor.clear
//                vc.userId = response.data ?? ""
//                vc.delegate = self
//
//                self.present(vc, animated: true, completion: nil)
            }else {
                self.showBanner(title: "alert".localized, message: response.errorMessage ?? "", style: UIColor.INFO)
            }
        }
    }
}

func resend() {
    var code = self.countryPicker.selectedCountry.phoneCode
    code = code.replacingOccurrences(of: "+", with: "")
    var mobile = self.edtMobileNumber.text ?? ""
    if (mobile.starts(with: "0")) {
        mobile = String(mobile.dropFirst())
    }
    ApiService.registerUser(phoneNumber: "\(code)\(mobile)", fullName: self.edtUserName.text ?? "", email: "", birthDate: "", gender: 1, isResend: true) { (response) in
        
    }
}

@IBAction func skipAction(_ sender: Any) {
    self.updateUser(self.getRealmUser(userProfile: VerifyResponse(data: DataClass(accessToken: "", phoneNumber: "", username: "", fullName: "", userID: "", dateOfBirth: "", profilePicture: "", email: "", gender: 0, rate: 0, roles: "", isOnline: false,exceededDueAmount: false, dueAmount: 0.0, earnings: 0.0, balance: 0.0), errorCode: 0, errorMessage: "")))
    
    
    let mainStoryboardIpad : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
    let initialViewControlleripad : UIViewController = mainStoryboardIpad.instantiateViewController(withIdentifier: self.getHomeView()) as! UINavigationController
    initialViewControlleripad.modalPresentationStyle = .fullScreen
    self.present(initialViewControlleripad, animated: true, completion: {})
    
    
}

func validateFields() -> Bool {
    
    if (self.edtUserName.text?.count ?? 0 < 3) {
        self.showBanner(title: "alert".localized, message: "enter_name_first".localized, style: UIColor.INFO)
        return false
    }
    if (self.edtMobileNumber.text?.count ?? 0 < 8) {
        self.showBanner(title: "alert".localized, message: "enter_mobile_first".localized, style: UIColor.INFO)
        return false
    }
    if  edtMobileNumber.text?.first == "6" {
        return true
    } else
        if edtMobileNumber.text?.first == "9" {
            return true
        } else
            if edtMobileNumber.text?.first == "5" {
                return true
            } else {
                self.showBanner(title: "alert".localized, message: "enter_valid_mobile_number".localized, style: UIColor.INFO)
                return false
            }
}

@objc func openTerms(sender:UITapGestureRecognizer) {
    if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TermsPushVC") as? TermsPushVC
    {
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
}


}
extension LoginVC: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        
        if textField == self.edtMobileNumber {
            let maxLength = 8
            let currentString: NSString = textField.text as NSString? ?? ""
            let newString: NSString =
                currentString.replacingCharacters(in: range, with: string) as NSString
            return newString.length <= maxLength
        }
        
        
        if let text = textField.text as NSString? {
            let txtAfterUpdate = text.replacingCharacters(in: range, with: string)
            if txtAfterUpdate.convertToEnglishNumber() != "0" {
                textField.text = txtAfterUpdate.convertToEnglishNumber()
            }
        }
        return false
    }
}
