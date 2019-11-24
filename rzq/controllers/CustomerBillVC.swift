//
//  CustomerBillVC.swift
//  rzq
//
//  Created by Zaid najjar on 4/18/19.
//  Copyright © 2019 technzone. All rights reserved.
//

import UIKit

protocol BillDelegate {
    func onDone(images : [UIImage], orderCost : Double, costDetails : String)
}
class CustomerBillVC: BaseVC,UINavigationControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var edtOrderCost: MyUITextField!
    
    @IBOutlet weak var edtDeliveryCost: MyUITextField!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var lblTotalCost: MyUILabel!
    
    var delegate : BillDelegate?
    
    var deliveryCost : Double?
    var totalCost : Double?
    var paymentMethod: String?
    var paymentMethodInt : Int?
    var commission : Double?
    
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
        
        self.edtOrderCost.delegate = self
        self.edtDeliveryCost.text = "\(self.deliveryCost ?? 0.0) \("currency".localized)"
        // Do any additional setup after loading the view.
    }
    
    func validate() -> Bool {
        if (self.edtOrderCost.text?.count ?? 0 == 0) {
            self.showBanner(title: "alert".localized, message: "enter_order_actual_cost".localized, style: UIColor.INFO)
            return false
        }
        return true
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

    @IBAction func closeAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func sendAction(_ sender: Any) {
        if (self.validate()) {
            var totalStr = "\("order_cost".localized): \(self.edtOrderCost.text ?? "") \n\n \("delivery_cost".localized): \(self.deliveryCost ?? 0.0) \n\n \("total_cost".localized): \(self.lblTotalCost.text ?? "") \n\n \("payment_method".localized): \(self.paymentMethod ?? "")"
            
            if (self.paymentMethodInt == Constants.PAYMENT_METHOD_KNET) {
                totalStr = "\n\n\(totalStr)\n\n\("notify_user_knet".localized)\n\n\("knet_commission".localized): \(self.commission ?? 0.0)"
            }
            
            self.delegate?.onDone(images: self.selectedImages,orderCost: self.totalCost ?? 0.0, costDetails: totalStr)
            self.dismiss(animated: true, completion: nil)
        }
    }
    
}
extension CustomerBillVC: UIImagePickerControllerDelegate {
    
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

extension CustomerBillVC: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if let text = textField.text as NSString? {
            let txtAfterUpdate = text.replacingCharacters(in: range, with: string)
          //  if txtAfterUpdate.convertToEnglishNumber() != "0" {
                textField.text = txtAfterUpdate.replacedArabicDigitsWithEnglish
          //  }
        }
        if textField == self.edtOrderCost {
            let text = textField.text ?? ""
            let doublePrice = Double(text)
            let totalPrice = (doublePrice ?? 0.0) + (self.deliveryCost ?? 0.0)
            self.totalCost = totalPrice
            self.lblTotalCost.text = "\(totalPrice) \("currency".localized)"
        }
        return false
    }
    
}
