//
//  SuggestShopVC.swift
//  rzq
//
//  Created by Zaid najjar on 5/14/19.
//  Copyright © 2019 technzone. All rights reserved.
//

import UIKit
import MultilineTextField
import CoreLocation

class SuggestShopVC: BaseVC, SelectLocationDelegate,UINavigationControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout,TypeListDelegate, AddHoursDelegate {

    @IBOutlet weak var btnBack: UIButton!
    
    @IBOutlet weak var edtName: MultilineTextField!
    
    @IBOutlet weak var edtAddress: UITextField!

    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var lblSelectedCategory: MyUILabel!
    
    var selectedLocation : CLLocation?
    
    var selectedImages = [UIImage]()
    var imagePicker: UIImagePickerController!
    var selectedType : ShopType?
    
    var chosenHours : String?
    
    enum ImageSource {
        case photoLibrary
        case camera
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.reloadData()
        
        edtName.placeholder = ""
        edtName.placeholderColor = UIColor.lightGray
        edtName.isPlaceholderScrollEnabled = true
        
        self.edtAddress.setLeftPaddingPoints(10)
        self.edtAddress.setRightPaddingPoints(10)
        
        self.edtName.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        // Do any additional setup after loading the view.
    }
    
    
    //collection delegates
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 120.0, height: 120.0)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
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
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: DialogImageCell = collectionView.dequeueReusableCell(withReuseIdentifier: "dialogimagecell", for: indexPath as IndexPath) as! DialogImageCell
        
        cell.ivAddedImage.image = self.selectedImages[indexPath.row]
        
        cell.deleteImage = {
            self.selectedImages.remove(at: indexPath.row)
            self.collectionView.reloadData()
        }
        
        return cell
        
    }
    
    
    
    @IBAction func addAction(_ sender: Any) {
        self.showAlertWithCancel(title: "add_image_pic_title".localized, message: "add_salon_pic_message".localized, actionTitle: "camera".localized, cancelTitle: "gallery".localized, actionHandler: {
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
    
    
    @IBAction func selectLocationAction(_ sender: Any) {
        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SelectLocationViewController") as? SelectLocationViewController
        {
            vc.delegate = self
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func selectedLocation(location: CLLocation, address : String) {
        self.selectedLocation = location
        self.edtAddress.text = address
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func onClick(type: ShopType) {
        self.selectedType = type
        self.lblSelectedCategory.text = type.name ?? ""
    }
    
    @IBAction func categoriesAction(_ sender: Any) {
        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ShopTypesFilterVC") as? ShopTypesFilterVC
        {
            vc.delegate = self
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func chosenHours(str: String) {
      self.chosenHours = str
    }
    
    @IBAction func workingHoursAction(_ sender: Any) {
        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AddHoursVC") as? AddHoursVC
        {
            vc.delegate = self
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    func validate() -> Bool {
        if (self.edtName.text.count == 0) {
            self.showBanner(title: "alert".localized, message: "enter_shop_name".localized, style: UIColor.INFO)
            return false
        }
        if (self.selectedLocation == nil) {
            self.showBanner(title: "alert".localized, message: "add_shop_location".localized, style: UIColor.INFO)
            return false
        }
        if (self.edtAddress.text?.count == 0) {
            self.showBanner(title: "alert".localized, message: "enter_shop_address".localized, style: UIColor.INFO)
            return false
        }
        if (self.selectedType == nil) {
            self.showBanner(title: "alert".localized, message: "select_shop_type".localized, style: UIColor.INFO)
            return false
        }
        if (self.chosenHours?.count ?? 0 == 0) {
            self.showBanner(title: "alert".localized, message: "add_shop_hours".localized, style: UIColor.INFO)
            return false
        }
        return true
    }
    @IBAction func submitAction(_ sender: Any) {
        if (self.validate()) {
            self.showLoading()
            var strBase64 = ""
            if (selectedImages.count > 0) {
               strBase64 = self.selectedImages[0].toBase64() ?? ""
            }
            ApiService.suggestShop(address: self.edtAddress.text ?? "", latitude: self.selectedLocation?.coordinate.latitude ?? 0.0, longitude: self.selectedLocation?.coordinate.longitude ?? 0.0, phoneNumber: "", workingHours: self.chosenHours ?? "", image: strBase64, name: self.edtName.text ?? "", type: self.selectedType?.id ?? 0) { (response) in
                self.hideLoading()
                if (response.errorCode == 0) {
                    self.showBanner(title: "alert".localized, message: "shop_suggested".localized, style: UIColor.SUCCESS)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                        self.navigationController?.popViewController(animated: true)
                    })
                }else {
                    self.showBanner(title: "alert".localized, message: response.errorMessage ?? "", style: UIColor.INFO)
                }
            }
        }
        
    }
    
}
extension SuggestShopVC: UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
        imagePicker.dismiss(animated: true, completion: nil)
        guard let selectedImage = info[.originalImage] as? UIImage else {
            print("Image not found!")
            return
        }
        self.selectedImages.append(selectedImage)
        self.collectionView.reloadData()
    }
}
