//
//  RegisterAsDriverMenuVC.swift
//  rzq
//
//  Created by Zaid najjar on 4/25/19.
//  Copyright © 2019 technzone. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField

class RegisterAsDriverMenuVC: BaseViewController ,UINavigationControllerDelegate {

    @IBOutlet weak var edtName: SkyFloatingLabelTextField!
    @IBOutlet weak var edtEmail: SkyFloatingLabelTextField!
    @IBOutlet weak var edtMobile: SkyFloatingLabelTextField!
    
    @IBOutlet weak var ivProfile: UIImageView!
    @IBOutlet weak var ivCivilId: UIImageView!
    @IBOutlet weak var ivLicense: UIImageView!
    
    @IBOutlet weak var btnMenu: UIButton!
    
    var profileImage : UIImage?
    var civilImage : UIImage?
    var licenseImage : UIImage?
    
    var imageDest = 1
    
    var imagePicker: UIImagePickerController!
    enum ImageSource {
        case photoLibrary
        case camera
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
           self.btnMenu.addTarget(self, action: #selector(BaseViewController.onSlideMenuButtonPressed(_:)), for: UIControl.Event.touchUpInside)
        
        self.edtName.text = DataManager.loadUser().data?.fullName ?? ""
        self.edtMobile.text = DataManager.loadUser().data?.phoneNumber ?? ""
        self.edtEmail.text = DataManager.loadUser().data?.email ?? ""
        
        self.edtName.title = "name".localized
        self.edtName.placeholder = "name".localized
        self.edtName.selectedTitle = "name".localized
        self.edtName.font = UIFont(name: self.getFontName(), size: 14)
        
        self.edtMobile.title = "mobile_number".localized
        self.edtMobile.placeholder = "mobile_number".localized
        self.edtMobile.selectedTitle = "mobile_number".localized
        self.edtMobile.font = UIFont(name: self.getFontName(), size: 14)
        
        self.edtEmail.title = "email_address".localized
        self.edtEmail.placeholder = "email_address".localized
        self.edtEmail.selectedTitle = "email_address".localized
        self.edtEmail.font = UIFont(name: self.getFontName(), size: 14)
        
        if (self.isArabic()) {
            self.edtName.textAlignment = NSTextAlignment.right
            self.edtMobile.textAlignment = NSTextAlignment.right
            self.edtEmail.textAlignment = NSTextAlignment.right
        }
        self.openWelcomeDriver()
        // Do any additional setup after loading the view.
    }
    
    func openWelcomeDriver() {
       UserDefaults.standard.setValue(false, forKey: Constants.SEE_DRIVER_TERMS)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc : WelcomeDriverVC = storyboard.instantiateViewController(withIdentifier: "WelcomeDriverVC") as! WelcomeDriverVC
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
    
    
    
    @IBAction func profileImageAction(_ sender: Any) {
        self.imageDest = 1
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
    
    @IBAction func civilIdImageAction(_ sender: Any) {
        self.imageDest = 2
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
    
    @IBAction func drivingLicenseImageAction(_ sender: Any) {
        self.imageDest = 3
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
    
    @IBAction func registerAction(_ sender: Any) {
        if (self.validate()){
            self.showLoading()
            let profileStr = (self.ivProfile.image?.toBase64())!
            let civilStr = (self.ivCivilId.image?.toBase64())!
            let licenseStr = (self.ivLicense.image?.toBase64())!
            
            ApiService.registerAsDriver(Authorization: DataManager.loadUser().data?.accessToken ?? "", NationalId: civilStr, DrivingLicense: licenseStr, ProfilePicture: profileStr, Email: self.edtEmail.text ?? "") { (response) in
                self.hideLoading()
                if (response.errorCode == 0) {
                    self.showBanner(title: "alert".localized, message: "driver_registered".localized, style: UIColor.SUCCESS)
                }else {
                    self.showBanner(title: "alert".localized, message: response.errorMessage ?? "", style: UIColor.INFO)
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                    self.openViewControllerBasedOnIdentifier(self.getSubHomeView())
                })
            }
        }
        
    }
    
    func validate() -> Bool {
        if (self.edtName.text?.count ?? 0 == 0) {
            self.showBanner(title: "alert".localized, message: "enter_name_first".localized, style: UIColor.INFO)
            return false
        }
        if (self.edtEmail.text?.count ?? 0 == 0 || !(self.edtEmail.text?.isValidEmail() ?? false)) {
            self.showBanner(title: "alert".localized, message: "enter_email_first".localized, style: UIColor.INFO)
            return false
        }
        if (self.profileImage == nil) {
            self.showBanner(title: "alert".localized, message: "add_profile_image_first".localized, style: UIColor.INFO)
            return false
        }
        if (self.civilImage == nil) {
            self.showBanner(title: "alert".localized, message: "add_civil_image_first".localized, style: UIColor.INFO)
            return false
        }
        if (self.licenseImage == nil) {
            self.showBanner(title: "alert".localized, message: "add_license_first".localized, style: UIColor.INFO)
            return false
        }
        return true
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}

extension RegisterAsDriverMenuVC: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imagePicker.dismiss(animated: true, completion: nil)
        guard let selectedImage = info[.originalImage] as? UIImage else {
            print("Image not found!")
            return
        }
        switch self.imageDest {
        case 1:
            self.profileImage = selectedImage
            self.ivProfile.image = selectedImage
            break
        case 2:
            self.civilImage = selectedImage
            self.ivCivilId.image = selectedImage
            break
        case 3:
            self.licenseImage = selectedImage
            self.ivLicense.image = selectedImage
            break
        default:
            self.profileImage = selectedImage
            self.ivProfile.image = selectedImage
            break
        }
    }
    

}
