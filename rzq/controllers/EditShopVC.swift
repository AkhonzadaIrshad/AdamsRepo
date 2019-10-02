//
//  EditShopVC.swift
//  rzq
//
//  Created by Zaid Khaled on 8/31/19.
//  Copyright © 2019 technzone. All rights reserved.
//

import UIKit
import MultilineTextField
import CoreLocation
import GooglePlaces
import GoogleMaps

class EditShopVC: BaseVC, SelectLocationDelegate,UINavigationControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout,TypeListDelegate, AddHoursDelegate {
    
    @IBOutlet weak var btnBack: UIButton!
    
    @IBOutlet weak var edtName: MultilineTextField!
    
    @IBOutlet weak var edtAddress: UITextField!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var lblSelectedCategory: MyUILabel!
    
    @IBOutlet weak var ivHandle: UIImageView!
    
    
    @IBOutlet weak var ivIndicator1: UIImageView!
    @IBOutlet weak var ivIndicator2: UIImageView!
    
    var selectedLocation : CLLocation?
    
    var selectedImages = [UIImage]()
    var imagePicker: UIImagePickerController!
    var selectedType : TypeClass?
    
    var latitude : Double?
    var longitude : Double?
    
    var chosenHours : String?
    
    enum ImageSource {
        case photoLibrary
        case camera
    }
    
    var shop : ShopData?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (self.isArabic()) {
            self.ivHandle.image = UIImage(named: "ic_back_arabic")
            self.ivIndicator1.image = UIImage(named: "ic_indicator_arabic")
            self.ivIndicator2.image = UIImage(named: "ic_indicator_arabic")
        }
        
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
        
        if (self.latitude ?? 0.0 > 0.0 && self.longitude ?? 0.0 > 0.0) {
            let location =  CLLocation.init(latitude: self.latitude ?? 0.0, longitude: self.longitude ?? 0.0)
            self.selectedLocation = CLLocation.init(latitude: self.latitude ?? 0.0, longitude: self.longitude ?? 0.0)
            self.GetAnnotationUsingCoordinated(location)
        }
       
        
        self.edtName.text = self.shop?.name ?? ""
        self.edtAddress.text = self.shop?.address ?? ""
        self.lblSelectedCategory.text = self.shop?.type?.name ?? ""
        self.selectedType = self.shop?.type
        self.selectedImages.removeAll()
        self.chosenHours = self.shop?.workingHours ?? ""
        self.latitude = self.shop?.latitude ?? 0.0
        self.longitude = self.shop?.longitude ?? 0.0
        
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
        if (self.selectedImages.count < 5) {
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
        }else {
            self.showBanner(title: "alert".localized, message: "cant_add_more_images".localized, style: UIColor.INFO)
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
    
    func onClick(type: TypeClass) {
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
            ApiService.editShop(Authorization: self.loadUser().data?.accessToken ?? "",address: self.edtAddress.text ?? "", latitude: self.selectedLocation?.coordinate.latitude ?? 0.0, longitude: self.selectedLocation?.coordinate.longitude ?? 0.0, phoneNumber: self.loadUser().data?.phoneNumber ?? "", workingHours: self.chosenHours ?? "", name: self.edtName.text ?? "", type: self.selectedType?.id ?? 0, shopId : self.shop?.id ?? 0) { (response) in
                self.hideLoading()
                if (response.errorCode == 0) {
                    self.handleUploadingMedia(id : response.data ?? 0)
                }else {
                    self.showBanner(title: "alert".localized, message: response.errorMessage ?? "", style: UIColor.INFO)
                }
            }
        }
        
    }
    
    
    
    func handleUploadingMedia(id : Int) {
        if (self.selectedImages.count > 0) {
            self.showLoading()
            var imagesData = [Data]()
            for image in self.selectedImages {
                imagesData.append(image.jpegData(compressionQuality: 0.30)!)
            }
            
            ApiService.uploadShopImages(Authorization: self.loadUser().data?.accessToken ?? "", requestId: id, imagesData: imagesData) { (response) in
                self.hideLoading()
                if (response.errorCode == 0) {
                    self.showBanner(title: "alert".localized, message: "shop_saved".localized, style: UIColor.SUCCESS)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                        self.navigationController?.popViewController(animated: true)
                    })
                }else {
                    self.showBanner(title: "alert".localized, message: response.errorMessage ?? "", style: UIColor.INFO)
                }
                
            }
        }else {
            self.showBanner(title: "alert".localized, message: "shop_saved".localized, style: UIColor.SUCCESS)
            DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                self.navigationController?.popViewController(animated: true)
            })
        }
    }
    
    fileprivate func GetAnnotationUsingCoordinated(_ location : CLLocation) {
        
        GMSGeocoder().reverseGeocodeCoordinate(location.coordinate) { (response, error) in
            
            var strAddresMain : String = ""
            
            if let address : GMSAddress = response?.firstResult() {
                if let lines = address.lines  {
                    if (lines.count > 0) {
                        if lines.count > 0 {
                            if lines[0].count > 0 {
                                strAddresMain = strAddresMain + lines[0]
                            }
                        }
                    }
                    
                    if lines.count > 1 {
                        if lines[1].count > 0 {
                            if strAddresMain.count > 0 {
                                strAddresMain = strAddresMain + ", \(lines[1])"
                            } else {
                                strAddresMain = strAddresMain + "\(lines[1])"
                            }
                        }
                    }
                    
                    if (strAddresMain.count > 0) {
                        
                        var strSubTitle = ""
                        if let locality = address.locality {
                            strSubTitle = locality
                        }
                        
                        if let administrativeArea = address.administrativeArea {
                            if strSubTitle.count > 0 {
                                strSubTitle = "\(strSubTitle), \(administrativeArea)"
                            }
                            else {
                                strSubTitle = administrativeArea
                            }
                        }
                        
                        if let country = address.country {
                            if strSubTitle.count > 0 {
                                strSubTitle = "\(strSubTitle), \(country)"
                            }
                            else {
                                strSubTitle = country
                            }
                        }
                        
                        self.edtAddress.text = strAddresMain
                        
                    }
                    else {
                        self.edtAddress.text = ""
                    }
                }
                else {
                    self.edtAddress.text = ""
                }
            }
            else {
                self.edtAddress.text = ""
            }
        }
    }
    
}

extension EditShopVC: UIImagePickerControllerDelegate {
    
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
