//
//  RegisterAsServiceProviderVC.swift
//  rzq
//
//  Created by Zaid najjar on 5/25/19.
//  Copyright © 2019 technzone. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField

class RegisterAsServiceProviderVC: BaseVC, UINavigationControllerDelegate, SelectServicesDelegate {

    @IBOutlet weak var edtName: SkyFloatingLabelTextField!
    @IBOutlet weak var edtEmail: SkyFloatingLabelTextField!
    @IBOutlet weak var edtMobile: SkyFloatingLabelTextField!
    
    @IBOutlet weak var ivProfile: UIImageView!
    @IBOutlet weak var ivCivilId: UIImageView!
    
    @IBOutlet weak var ivHandle: UIImageView!
    
    @IBOutlet weak var edtService: MyUITextField!
    
    @IBOutlet weak var ivIndicator: UIImageView!
    
    var profileImage : UIImage?
    var civilImage : UIImage?
    
    var imageDest = 1
    
    var selectedServices = [Int]()
    
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
            self.ivHandle.image = UIImage(named: "ic_back_arabic")
            self.ivIndicator.image = UIImage(named: "ic_indicator_arabic")
        }
        self.edtName.text = self.loadUser().data?.fullName ?? ""
        self.edtMobile.text = self.loadUser().data?.phoneNumber ?? ""
        self.edtEmail.text = self.loadUser().data?.email ?? ""
        
        // Do any additional setup after loading the view.
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
            
            ApiService.registerAsServiceProvider(Authorization: self.loadUser().data?.accessToken ?? "", services: self.selectedServices, serviceName: self.edtService.text ?? "", nationalId: civilStr, profilePicture: profileStr, email: self.edtEmail.text ?? "") { (response) in
                self.hideLoading()
                if (response.errorCode == 0) {
                    self.showBanner(title: "alert".localized, message: "provider_registered".localized, style: UIColor.SUCCESS)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                        self.navigationController?.popViewController(animated: true)
                    })
                }else {
                    self.showBanner(title: "alert".localized, message: response.errorMessage ?? "", style: UIColor.INFO)
                }
            }
            //register api here
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
        return true
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func selectServicesAction(_ sender: Any) {
        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SelectServicesVC") as? SelectServicesVC
        {
            vc.delegate = self
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func onSubmit(services: [Int]) {
        self.selectedServices = services
    }
    
    
}

extension RegisterAsServiceProviderVC: UIImagePickerControllerDelegate {
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
        default:
            self.profileImage = selectedImage
            self.ivProfile.image = selectedImage
            break
        }
    }
}
