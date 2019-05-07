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

class LoginVC: BaseVC, CountryPickerViewDataSource, CountryPickerViewDelegate, PhoneVerificationDelegate {

    @IBOutlet weak var edtUserName: SkyFloatingLabelTextField!
    
    @IBOutlet weak var edtMobileNumber: SkyFloatingLabelTextField!
    
    @IBOutlet weak var ivHandle: UIImageView!
    
    @IBOutlet weak var lblTerms: MyUILabel!
    
    @IBOutlet weak var countryPicker: CountryPickerView!
    
    var attributedString = NSMutableAttributedString(string:"")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
            self.ivHandle.image = UIImage(named: "bg_circular")
        }
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
            var mobile = self.edtMobileNumber.text ?? ""
            if (mobile.starts(with: "0")) {
                mobile = String(mobile.dropFirst())
            }
            ApiService.registerUser(phoneNumber: "\(code)\(mobile)", fullName: self.edtUserName.text ?? "", email: "", birthDate: "", gender: 1) { (response) in
                self.hideLoading()
                if (response.errorCode == 0) {
                    let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PhoneVerificationDialog") as! PhoneVerificationDialog
                    self.definesPresentationContext = true
                    vc.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
                    vc.view.backgroundColor = UIColor.clear
                    vc.userId = response.data ?? ""
                    vc.delegate = self
                    
                    self.present(vc, animated: true, completion: nil)
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
        ApiService.registerUser(phoneNumber: "\(code)\(mobile)", fullName: self.edtUserName.text ?? "", email: "", birthDate: "", gender: 1) { (response) in
           
        }
    }
    
    @IBAction func skipAction(_ sender: Any) {
        self.updateUser(self.getRealmUser(userProfile: VerifyResponse(data: DataClass(accessToken: "", phoneNumber: "", username: "", fullName: "", userID: "", dateOfBirth: "", profilePicture: "", email: "", gender: 0, rate: 0, roles: "", isOnline: false,exceededDueAmount: false), errorCode: 0, errorMessage: "")))
        let mainStoryboardIpad : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let initialViewControlleripad : UIViewController = mainStoryboardIpad.instantiateViewController(withIdentifier: self.getHomeView()) as! UINavigationController
        self.present(initialViewControlleripad, animated: true, completion: {})
    }
    
    func validateFields() -> Bool {
        
        if (self.edtUserName.text?.count ?? 0 < 3) {
            self.showBanner(title: "alert".localized, message: "enter_name_first".localized, style: UIColor.INFO)
            return false
        }
        if (self.edtMobileNumber.text?.count ?? 0 < 6) {
            self.showBanner(title: "alert".localized, message: "enter_mobile_first".localized, style: UIColor.INFO)
            return false
        }
        
        return true
    }
    
    @objc func openTerms(sender:UITapGestureRecognizer) {
        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TermsPushVC") as? TermsPushVC
        {
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    
}
extension LoginVC: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        
        if textField == self.edtMobileNumber {
            let maxLength = 10
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
