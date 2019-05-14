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

class SuggestShopVC: BaseVC, SelectLocationDelegate,UINavigationControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var btnBack: UIButton!
    
    @IBOutlet weak var edtName: MultilineTextField!
    
    @IBOutlet weak var edtAddress: UITextField!

    @IBOutlet weak var collectionView: UICollectionView!
    
    var selectedLocation : CLLocation?
    
    var selectedImages = [UIImage]()
    var imagePicker: UIImagePickerController!
    
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
    
    @IBAction func categoriesAction(_ sender: Any) {
        
    }
    
    
    @IBAction func workingHoursAction(_ sender: Any) {
        
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
