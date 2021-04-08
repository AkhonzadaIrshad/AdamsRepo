//
//  SendingOrderVC.swift
//  rzq
//
//  Created by Zaid najjar on 4/30/19.
//  Copyright © 2019 technzone. All rights reserved.
//

import UIKit
import SwiftyGif
import Firebase

class SendingOrderVC: BaseVC {
    
    @IBOutlet weak var gif: UIImageView!
    
    @IBOutlet weak var lblTitle: MyUILabel!
    @IBOutlet weak var getMyOrderView: CardView!
    
    @IBOutlet weak var lblDesc: MyUILabel!
    var selectedItems = [ShopMenuItem]()
    var isCash : Bool = true
    let recorder = KAudioRecorder.shared
    var orderModel : OTWOrder?
    var selectedTime : Int?
    var selectedTotal: Double?
    var isFemale : Bool?
    var selectedImages: [UIImage] = []
    var isAboveTen : Bool?

    
    @IBOutlet weak var getMyOrderButton: MyUIButton!
    
    var type : Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getMyOrderButton.isHidden = true
        self.getMyOrderView.isHidden = true
        
        if (self.isArabic()) {
            let gif = UIImage(gifName: "pending_ar.gif")
            self.gif.setGifImage(gif)
        }else {
            let gif = UIImage(gifName: "pending_en.gif")
            self.gif.setGifImage(gif)
        }
        
        if (type == 2){
            self.lblTitle.text = "waiting_provider_bids".localized
            self.lblDesc.text = "waiting_provider_bids_desc".localized
        }
        if (self.isCash ?? false) {
            if (self.selectedItems.count > 0) {
                self.createDeliveryWithMenu(invoiceId : "")
            }else {
                self.createDeliveryWithoutMenu(invoiceId : "")
            }
        }else {
            self.generatePaymentUrl()
        }
        
        ApiService.updateRegId(Authorization: DataManager.loadUser().data?.accessToken ?? "", regId: Messaging.messaging().fcmToken ?? "not_avaliable") { (response) in
            
            
        }
        
        
    }
    func generatePaymentUrl() {
        self.showLoading()
        ApiService.placePayment(user: DataManager.loadUser(), total: self.selectedTotal ?? 0.0, items: self.selectedItems) { (response) in
            self.hideLoading()
            if (self.selectedItems.count > 0) {
                self.createDeliveryWithMenu(invoiceId : response.paymentData?.paymentURL ?? "")
            }else {
                self.createDeliveryWithoutMenu(invoiceId : response.paymentData?.paymentURL ?? "")
            }
        }
    }
    
    func createDeliveryWithMenu(invoiceId: String) {
        self.showLoading()
        var paymentMethod = Constants.PAYMENT_METHOD_KNET
        if (self.isCash ?? false) {
            paymentMethod = Constants.PAYMENT_METHOD_CASH
        }
        ApiService.createDeliveryWithMenu(
            Authorization: DataManager.loadUser().data?.accessToken ?? "",
            desc: self.orderModel?.orderDetails ?? "",
            fromLongitude: self.orderModel?.pickUpLongitude ?? 0.0,
            fromLatitude: self.orderModel?.pickUpLatitude ?? 0.0,
            toLongitude: self.orderModel?.dropOffLongitude ?? 0.0,
            toLatitude: self.orderModel?.dropOffLatitude ?? 0.0,
            time: self.selectedTime ?? 0,
            estimatedPrice: "\(self.getCost())",
            fromAddress: self.orderModel?.pickUpAddress ?? "",
            toAddress: self.orderModel?.dropOffAddress ?? "",
            shopId: self.orderModel?.shop?.id ?? 0,
            pickUpDetails : self.orderModel?.pickUpDetails ?? "",
            dropOffDetails : self.orderModel?.dropOffDetails ?? "",
            paymentMethod : paymentMethod,
            isFemale : self.isFemale ?? false,
            menuItems : self.selectedItems,
            invoiceId : invoiceId) { (response) in
            self.hideLoading()
            if (response.data ?? 0 > 0) {
                self.handleUploadingMedia(id : response.data ?? 0)
            }else {
                self.showBanner(title: "alert".localized, message: response.errorMessage ?? "", style: UIColor.INFO)
            }
        }
    }
    func createDeliveryWithoutMenu(invoiceId: String) {
        self.showLoading()
        var paymentMethod = Constants.PAYMENT_METHOD_KNET
        if (self.isCash ?? false) {
            paymentMethod = Constants.PAYMENT_METHOD_CASH
        }
        ApiService.createDelivery(Authorization: DataManager.loadUser().data?.accessToken ?? "",
                                  desc: self.orderModel?.orderDetails ?? "",
                                  fromLongitude: self.orderModel?.pickUpLongitude ?? 0.0, fromLatitude: self.orderModel?.pickUpLatitude ?? 0.0, toLongitude: self.orderModel?.dropOffLongitude ?? 0.0, toLatitude: self.orderModel?.dropOffLatitude ?? 0.0, time: self.selectedTime ?? 0, estimatedPrice: "\(self.getCost())", fromAddress: self.orderModel?.pickUpAddress ?? "", toAddress: self.orderModel?.dropOffAddress ?? "", shopId: self.orderModel?.shop?.id ?? 0, pickUpDetails : self.orderModel?.pickUpDetails ?? "", dropOffDetails : self.orderModel?.dropOffDetails ?? "",paymentMethod : paymentMethod, isFemale : self.isFemale ?? false, invoiceId: invoiceId) { (response) in
            self.hideLoading()
            if (response.data ?? 0 > 0) {
                self.handleUploadingMedia(id : response.data ?? 0)
            }else {
                self.showBanner(title: "alert".localized, message: response.errorMessage ?? "", style: UIColor.INFO)
            }
        }
    }
    
    func handleUploadingMedia(id : Int) {
        if (self.selectedImages.count > 0 || self.recorder.time > 0) {
            self.showLoading()
            var imagesData = [Data]()
            for image in self.selectedImages {
                imagesData.append(image.jpegData(compressionQuality: 0.30)!)
            }
            var audioData : Data?
            if (self.recorder.time > 0) {
                do {
                    audioData = try Data.init(contentsOf: self.recorder.getUrl())
                }catch let err {
                    audioData = Data(base64Encoded: "")
                }
            }else {
                audioData = Data(base64Encoded: "")
            }
            ApiService.uploadMedia(Authorization: DataManager.loadUser().data?.accessToken ?? "", deliveryId: id, imagesData: imagesData, audioData: audioData!) { (response) in
                self.hideLoading()
                if (response.errorCode == 0) {
                    self.getMyOrderButton.isHidden = false
                    self.getMyOrderView.isHidden = false

                }else {
                    self.showBanner(title: "alert".localized, message: response.errorMessage ?? "", style: UIColor.INFO)
                    self.getMyOrderButton.isHidden = false
                    self.getMyOrderView.isHidden = false

                }
                
            }
        }else {
            self.getMyOrderView.isHidden = false
            self.getMyOrderButton.isHidden = false
        }
    }
    
    func goToNotifications() {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NotificationsNavigationController") as! UINavigationController
        App.shared.notificationSegmentIndex = 1
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
    
    func getCost() -> Double {
        if (self.isAboveTen ?? false) {
            return 11.0
        }else {
            return 9.0
        }
    }
    
    @IBAction func openOrdersAction(_ sender: Any) {
        //        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "OrdersNavigationController") as! UINavigationController
        //        vc.modalPresentationStyle = .fullScreen
        //        self.present(vc, animated: true, completion: nil)
        self.goToNotifications()
    }
    
}
