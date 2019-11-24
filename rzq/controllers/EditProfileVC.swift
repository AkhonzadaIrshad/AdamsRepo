//
//  EditProfileVC.swift
//  rzq
//
//  Created by Zaid najjar on 4/7/19.
//  Copyright © 2019 technzone. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField
import SimpleCheckbox
import DatePickerDialog

class EditProfileVC: BaseVC,UINavigationControllerDelegate {
    
    @IBOutlet weak var ivProfile: CircleImage!
    
    @IBOutlet weak var edtEmail: SkyFloatingLabelTextField!
    @IBOutlet weak var edtUserName: SkyFloatingLabelTextField!
    
    @IBOutlet weak var ivHandle: UIImageView!
    
    
    @IBOutlet weak var edtMobileNumber: SkyFloatingLabelTextField!
    
    
    @IBOutlet weak var btnDate: MyUIButton!
    @IBOutlet weak var chkFemale: Checkbox!
    @IBOutlet weak var ivFemale: UIImageView!
    @IBOutlet weak var lblFemale: MyUILabel!
    
    @IBOutlet weak var chkMale: Checkbox!
    @IBOutlet weak var ivMale: UIImageView!
    @IBOutlet weak var lblMale: MyUILabel!
    
    var user : DataProfileObj?
    
    var profileImage : UIImage?
    
    var imagePicker: UIImagePickerController!
    enum ImageSource {
        case photoLibrary
        case camera
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.edtUserName.title = "name".localized
        self.edtUserName.placeholder = "name".localized
        self.edtUserName.selectedTitle = "name".localized
        self.edtUserName.font = UIFont(name: self.getFontName(), size: 14)
        
        self.edtEmail.title = "email_address".localized
        self.edtEmail.placeholder = "email_address".localized
        self.edtEmail.selectedTitle = "email_address".localized
        self.edtEmail.font = UIFont(name: self.getFontName(), size: 14)
        
        
        self.edtMobileNumber.title = "mobile_number".localized
        self.edtMobileNumber.placeholder = "mobile_number".localized
        self.edtMobileNumber.selectedTitle = "mobile_number".localized
        self.edtMobileNumber.font = UIFont(name: self.getFontName(), size: 14)
        
        if (self.isArabic()) {
            self.edtUserName.textAlignment = NSTextAlignment.right
            self.edtEmail.textAlignment = NSTextAlignment.right
            self.edtMobileNumber.textAlignment = NSTextAlignment.right
            self.ivHandle.image = UIImage(named: "ic_back_arabic")
        }
        
        self.chkFemale.checkmarkStyle = .tick
        self.chkFemale.checkmarkColor = UIColor.appDarkBlue
        self.chkFemale.checkedBorderColor = UIColor.appDarkBlue
        self.chkFemale.uncheckedBorderColor = UIColor.appLightGray
        self.chkFemale.isChecked = true
        
        self.chkMale.checkmarkStyle = .tick
        self.chkMale.checkmarkColor = UIColor.appDarkBlue
        self.chkMale.checkedBorderColor = UIColor.appDarkBlue
        self.chkMale.uncheckedBorderColor = UIColor.appLightGray
        self.chkMale.isChecked = false
        
        let urlStr = self.user?.image ?? ""
        if (urlStr.count > 0) {
            let url = URL(string: "\(Constants.IMAGE_URL)\(self.user?.image ?? "")")
            self.ivProfile.kf.setImage(with: url)
        }
        
        self.edtUserName.text = self.user?.fullName ?? ""
        self.edtEmail.text = self.user?.email ?? ""
        self.btnDate.setTitle(self.user?.dateOfBirth ?? "", for: .normal)
        self.edtMobileNumber.text = self.user?.phoneNumber ?? ""
        
        
        if (self.user?.gender ?? 1 == 1) {
            self.chkFemale.isChecked = false
            self.chkMale.isChecked = true
            self.ivFemale.image = UIImage(named: "ic_female")
            self.ivMale.image = UIImage(named: "ic_male_selected")
            self.lblFemale.textColor = UIColor.appLightGray
            self.lblMale.textColor = UIColor.appDarkBlue
        }else {
            self.chkFemale.isChecked = true
            self.chkMale.isChecked = false
            self.ivFemale.image = UIImage(named: "ic_female_selected")
            self.ivMale.image = UIImage(named: "ic_male")
            self.lblFemale.textColor = UIColor.appDarkBlue
            self.lblMale.textColor = UIColor.appLightGray
        }
        
    }
    
    
    func selectImageFrom(_ source: ImageSource) {
        imagePicker =  UIImagePickerController()
        imagePicker.delegate = self
        switch source {
        case .camera:
            imagePicker.sourceType = .camera
        case .photoLibrary:
            imagePicker.sourceType = .photoLibrary
        }
        present(imagePicker, animated: true, completion: nil)
    }
    
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
        
    }
    
    @IBAction func saveAction(_ sender: Any) {
        if (self.validate()) {
            self.showLoading()
            var gender = 1
            if (self.chkFemale.isChecked) {
                gender = 2
            }
            
            let strBase64 = self.ivProfile.image?.toBase64()
            ApiService.updateProfile(Authorization: self.loadUser().data?.accessToken ?? "", FullName: self.edtUserName.text ?? "", Email: self.edtEmail.text ?? "", birthDate: self.btnDate.titleLabel?.text ?? "", gender: gender, profileImage: strBase64 ?? "") { (response) in
                self.hideLoading()
                if (response.errorCode == 0) {
                    self.showBanner(title: "alert".localized, message: "profile_updated_successfully".localized, style: UIColor.SUCCESS)
                    ApiService.getProfile(Authorization: self.loadUser().data?.accessToken ?? "") { (rsp) in
                        let userData = self.loadUser().data
                        let profile = VerifyResponse(data: DataClass(accessToken: userData?.accessToken ?? "", phoneNumber: rsp.dataProfileObj?.phoneNumber ?? "", username: userData?.username ?? "", fullName: rsp.dataProfileObj?.fullName ?? "", userID: userData?.userID ?? "", dateOfBirth: rsp.dataProfileObj?.dateOfBirth ?? "", profilePicture: rsp.dataProfileObj?.image ?? "", email: rsp.dataProfileObj?.email ?? "", gender: rsp.dataProfileObj?.gender ?? 1, rate: userData?.rate ?? 0.0, roles: userData?.roles ?? "", isOnline: userData?.isOnline ?? true, exceededDueAmount: userData?.exceededDueAmount ?? false, dueAmount: userData?.dueAmount ?? 0.0, earnings: userData?.earnings ?? 0.0, balance: userData?.balance ?? 0.0), errorCode: 0, errorMessage: "")
                        self.updateUser(self.getRealmUser(userProfile: profile))
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                            self.navigationController?.popViewController(animated: true)
                        })
                    }
                }else {
                    self.showBanner(title: "alert".localized, message: response.errorMessage ?? "", style: UIColor.INFO)
                }
                
            }
        }
        
    }
    
    func validate() -> Bool {
        if (self.edtUserName.text?.count ?? 0 == 0) {
            self.showBanner(title: "alert".localized, message: "enter_name_first".localized, style: UIColor.INFO)
            return false
        }
        return true
    }
    
    @IBAction func femaleAction(_ sender: Any) {
        self.chkFemale.isChecked = true
        self.chkMale.isChecked = false
        self.ivFemale.image = UIImage(named: "ic_female_selected")
        self.ivMale.image = UIImage(named: "ic_male")
        self.lblFemale.textColor = UIColor.appDarkBlue
        self.lblMale.textColor = UIColor.appLightGray
    }
    
    @IBAction func maleAction(_ sender: Any) {
        self.chkFemale.isChecked = false
        self.chkMale.isChecked = true
        self.ivFemale.image = UIImage(named: "ic_female")
        self.ivMale.image = UIImage(named: "ic_male_selected")
        self.lblFemale.textColor = UIColor.appLightGray
        self.lblMale.textColor = UIColor.appDarkBlue
    }
    
    @IBAction func femaleChkAction(_ sender: Checkbox) {
        self.chkFemale.isChecked = true
        self.chkMale.isChecked = false
        self.ivFemale.image = UIImage(named: "ic_female_selected")
        self.ivMale.image = UIImage(named: "ic_male")
        self.lblFemale.textColor = UIColor.appDarkBlue
        self.lblMale.textColor = UIColor.appLightGray
    }
    
    @IBAction func maleChkAction(_ sender: Checkbox) {
        self.chkFemale.isChecked = false
        self.chkMale.isChecked = true
        self.ivFemale.image = UIImage(named: "ic_female")
        self.ivMale.image = UIImage(named: "ic_male_selected")
        self.lblFemale.textColor = UIColor.appLightGray
        self.lblMale.textColor = UIColor.appDarkBlue
    }
    
    @IBAction func dobAction(_ sender: Any) {
        self.showDatePicker()
    }
    
    @IBAction func editImageAction(_ sender: Any) {
        self.showAlert(title: "add_image_pic_title".localized, message: "add_salon_pic_message".localized, actionTitle: "camera".localized, cancelTitle: "gallery".localized, actionHandler: {
            //camera
            guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
                self.selectImageFrom(.photoLibrary)
                return
            }
            self.selectImageFrom(.camera)
        }) {
            //gallery
            self.imagePicker =  UIImagePickerController()
            self.imagePicker.delegate = self
            self.imagePicker.sourceType = .photoLibrary
            self.present(self.imagePicker, animated: true, completion: nil)
        }
    }
    
    @IBAction func editProfileImageAction(_ sender: Any) {
        self.showAlert(title: "add_image_pic_title".localized, message: "add_salon_pic_message".localized, actionTitle: "camera".localized, cancelTitle: "gallery".localized, actionHandler: {
            //camera
            guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
                self.selectImageFrom(.photoLibrary)
                return
            }
            self.selectImageFrom(.camera)
        }) {
            //gallery
            self.imagePicker =  UIImagePickerController()
            self.imagePicker.delegate = self
            self.imagePicker.sourceType = .photoLibrary
            self.present(self.imagePicker, animated: true, completion: nil)
        }
    }
    
    func showDatePicker() {
        DatePickerDialog().show("choose_date".localized, doneButtonTitle: "done".localized, cancelButtonTitle: "cancel".localized, datePickerMode: .date) {
            (date) -> Void in
            if let dt = date {
                let formatter = DateFormatter()
                formatter.dateFormat = "dd/MM/yyyy"
                self.btnDate.setTitle(formatter.string(from: dt), for: .normal)
            }
        }
    }
    
}
extension EditProfileVC: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imagePicker.dismiss(animated: true, completion: nil)
        guard let selectedImage = info[.originalImage] as? UIImage else {
            print("Image not found!")
            return
        }
        self.ivProfile.image = selectedImage
    }
}
