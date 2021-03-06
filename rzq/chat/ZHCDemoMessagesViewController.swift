//
//  ZHCDemoMessagesViewController.swift
//  ZHChatSwift
//
//  Created by aimoke on 16/12/16.
//  Copyright © 2016年 zhuo. All rights reserved.
//

import UIKit
import ZHChat
import JJFloatingActionButton
import MOLH
import BRYXBanner
import SVProgressHUD
import SwiftyGif
import Kingfisher
import ImageSlideshow

class ZHCDemoMessagesViewController: ZHCMessagesViewController, BillDelegate, ChatDelegate,UINavigationControllerDelegate, LabasLocationManagerDelegate, PaymentStatusDelegate, OrderChatDelegate, RateDriverDelegate {
    
    lazy var callDriverbutton: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = UIColor.appLogoColor
        button.addTarget(self, action: #selector(onCallTheDriver), for: .touchUpInside)
        button.layer.cornerRadius = 17.5
        button.layer.masksToBounds = true
        button.setImage(UIImage(named: "chat_call"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    lazy var paybutton: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = UIColor.appLogoColor
        button.addTarget(self, action: #selector(onPayOrder), for: .touchUpInside)
        button.layer.cornerRadius = 17.5
        button.layer.masksToBounds = true
        button.setTitle("payOrder".localized, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    lazy var stackView: UIStackView = {
    let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = 10
        return stackView
    }()
    
    var demoData: ZHModelData = ZHModelData.init()
    var presentBool: Bool = false
    
    var order: DatumDel?
    var orderInfo: DataClassDelObj?
    var orderIsPay: Bool = false
    var user : VerifyResponse?
    
    var delegate : ChatDelegate?
    
    var actionButton : JJFloatingActionButton?
    var driverActionButton : JJFloatingActionButton?
    
    var gif : UIImageView?
    var btnRecord : UIButton?
    var recorder = KAudioRecorder.shared
    
    var bottomMargin = 0.0
    
    var imagePicker: UIImagePickerController!
    enum ImageSource {
        case photoLibrary
        case camera
    }
    
    var hasSafeArea: Bool {
        guard #available(iOS 11.0, *), let topPadding = UIApplication.shared.keyWindow?.safeAreaInsets.top, topPadding > 24 else {
            return false
        }
        return true
    }
    
    var latitude : Double?
    var longitude : Double?
    var clientPhoneNumber: String?
    var shopPhoneNumber: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getOrderData()
        setupHeaderbuttons()
        
        if let id = self.order?.id {
            ApiService.getDelivery(id: id) { (deliveryResponse) in
                self.clientPhoneNumber = deliveryResponse.data?.ClientPhone
            }
        }
        if let shopId = self.order?.shopId {
            ApiService.getShopDetails(Authorization: DataManager.loadUser().data?.accessToken ?? "", id: shopId) { (response) in
                self.shopPhoneNumber = response.shopData?.phoneNumber
            }
        }
        
        self.latitude = UserDefaults.standard.value(forKey: Constants.LAST_LATITUDE) as? Double ?? 0.0
        self.longitude = UserDefaults.standard.value(forKey: Constants.LAST_LONGITUDE) as? Double ?? 0.0
        
        demoData.user = self.user
        demoData.order = self.order
        demoData.delegate = self
        demoData.loadMessages()
        self.title = "RZQ".localized
        if self.automaticallyScrollsToMostRecentMessage {
            self.scrollToBottom(animated: false)
        }
        
        if (self.isProvider() && self.user?.data?.userID == self.order?.providerID) {
            self.setupFloating()
        }else {
            self.setupUserFloating()
        }
        
        // Do any additional setup after loading the view.
        self.gif = UIImageView()
        self.gif?.frame = CGRect(x: self.view.frame.midX, y: self.view.frame.midY, width: 70, height: 70)
        self.gif?.center = self.view.center
        let gf = UIImage(gifName: "recording.gif")
        self.gif?.setGifImage(gf)
        
        self.gif?.isHidden = true
        self.view.addSubview(self.gif!)
        
        self.setUpRecordButton()
        
        if (self.hasSafeArea) {
            self.bottomMargin = 20.0
        }else {
            self.bottomMargin = 0.0
        }
        
        if (self.sendWelcomeMessage()) {
            ApiService.sendChatMessage(Authorization: self.user?.data?.accessToken ?? "", chatId: self.order?.chatId ?? 0, type: 1, message: "اهلا وسهلا, يسرني أن أقوم بخدمتك.. والآن انا متوجه لأخذ طلبك يمكنك تتبع المسار عند اصدار الفاتوره..\n\n\nWelcome, I'm happy to serve you, I'm on my way to take your order, you can track your order when i pick it up.\n", image: "", voice: "") { (response) in
                if (response.errorCode == 0) {
                    SVProgressHUD.dismiss()
                    let message: ZHCMessage = ZHCMessage.init(senderId: self.user?.data?.userID ?? "", senderDisplayName: self.user?.data?.fullName ?? "", date: Date(), text: "اهلا وسهلا, يسرني أن أقوم بخدمتك.. والآن انا متوجه لأخذ طلبك يمكنك تتبع المسار عند اصدار الفاتوره..\n\n\nWelcome, I'm happy to serve you, I'm on my way to take your order, you can track your order when i pick it up.\n")
                    self.demoData.messages.add(message)
                    self.finishSendingMessage(animated: true)
                }else if (response.errorCode == 18) {
                    self.showBanner(title: "alert".localized, message: "account_inactive".localized, style: UIColor.INFO)
                    if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginVC") as? LoginVC
                    {
                        vc.modalPresentationStyle = .fullScreen
                        self.present(vc, animated: true, completion: nil)
                    }
                }else {
                    self.closeChat()
                }
            }
        }
        
        
        let infoBarButtonItem = UIBarButtonItem(title: "chat_order_details".localized, style: .done, target: self, action: #selector(orderInfoAction))
        self.navigationItem.rightBarButtonItem  = infoBarButtonItem
        
        //  if (self.isProvider()) {
        LabasLocationManager.shared.delegate = self
        LabasLocationManager.shared.startUpdatingLocation()
        // }
        
        self.inputMessageBarView.contentView?.leftBarButtonItem?.isHidden = true
        
    }
    
    func changeOrderPaymentMethod(method : Int) {
        self.order?.paymentMethod = method
    }
    
    
    func getPaymentMethod(method: Int) -> String {
        switch method {
        case Constants.PAYMENT_METHOD_CASH:
            return "cash".localized
        case Constants.PAYMENT_METHOD_KNET:
            return "knet".localized
        case Constants.PAYMENT_METHOD_BALANCE:
            return "coupon".localized
        default:
            return "cash".localized
        }
    }
    
    
    func sendWelcomeMessage() -> Bool {
        if (self.isProvider() && self.user?.data?.userID == self.order?.providerID) {
            let x = UserDefaults.standard.value(forKey: "ordr_\(self.order?.id ?? 0)") as? Int ?? 0
            if (x > 0) {
                return false
            }else {
                UserDefaults.standard.setValue(1, forKey: "ordr_\(self.order?.id ?? 0)")
                return true
            }
        }else {
            return false
        }
    }
    
    func labasLocationManager(didUpdateLocation location: CLLocation) {
        
        print("location update")
        
        self.latitude = location.coordinate.latitude
        self.longitude = location.coordinate.longitude
        
        UserDefaults.standard.setValue(self.latitude, forKey: Constants.LAST_LATITUDE)
        UserDefaults.standard.setValue(self.longitude, forKey: Constants.LAST_LONGITUDE)
        
        
        if (self.isProvider()) {
            ApiService.updateLocation(Authorization: self.user?.data?.accessToken ?? "", latitude: location.coordinate.latitude , longitude: location.coordinate.longitude) { (response) in
                
            }
        }
        
    }
    
     func getOrderData() {
        ApiService.getDelivery(id: self.order?.id ?? 0) { (response) in
            self.orderInfo = response.data
            if (self.order?.isPaid ?? false) {
                self.orderIsPay = false
            }else {
                self.orderIsPay = true
            }
        }
        self.diplayPaybutton()
    }
    
    private func diplayPaybutton() {
        if  self.user?.data?.roles?.contains(find: "Driver") == true {
            self.paybutton.isHidden = true
        }else {
            // if (self.isPay ?? false) {
            if (self.order?.paymentMethod == Constants.PAYMENT_METHOD_KNET && (self.order?.isPaid ?? false) == false) {
                if (self.order?.status == Constants.ORDER_PENDING || self.order?.status == Constants.ORDER_PROCESSING || self.order?.status == Constants.ORDER_ON_THE_WAY) {
                    //for testing
                    self.paybutton.isHidden = false
                }else {
                    self.paybutton.isHidden = true
                }
            }else {
                self.paybutton.isHidden = true
            }
            
           // self.paybutton.isHidden = false
        }
    }
    
    func getNewOrderData() {
        ApiService.getDelivery(id: self.order?.id ?? 0) { (response) in
            self.orderInfo = response.data
            if (self.order?.isPaid ?? false) {
                self.orderIsPay = false
            }else {
                self.orderIsPay = true
            }
        }
    }
    
    @objc func orderInfoAction() {
        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "OrderDetailsVC") as? OrderDetailsVC
        {
            ApiService.getDelivery(id: self.order?.id ?? 0) { (response) in
                vc.order = response.data
                if (self.order?.isPaid ?? false) {
                    vc.isPay = false
                }else {
                    vc.isPay = true
                }
                vc.delegate = self
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    func onOrderPaymentSuccess() {
        self.sendTextMessage(text: "I have successfully paid my order using Knet.\n\n\nلقد قمت بدفع الطلب باستخدام كي نت بنجاح.")
        SVProgressHUD.show()
        ApiService.sendUserNotification(Authorization: self.user?.data?.accessToken ?? "", arabicTitle: "الطلب \(Constants.ORDER_NUMBER_PREFIX)\(self.order?.id ?? 0)", englishTitle: "Order \(Constants.ORDER_NUMBER_PREFIX)\(self.order?.id ?? 0)", arabicBody: "قام الزبون بدفع الطلب باستخدام كي نت", englishbody: "Client paid using Knet", userId: self.order?.providerID ?? "", type: 989) { (response) in
            SVProgressHUD.dismiss()
        }
    }
    func onOrderPaymentFail() {
        self.sendTextMessage(text: "I did'nt pay my order using Knet, is it possible that we use cash?\n\n\nلم اتمكن من الدفع باستخدام كي نت، هل من الممكن الدفع كاش؟")
    }
    
    func onCloseFromNotification() {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UserDefaults.standard.setValue(0, forKey: Constants.NOTIFICATION_CHAT_COUNT)
        
        if (self.order?.status == Constants.ORDER_CANCELLED || self.order?.status == Constants.ORDER_COMPLETED || self.order?.status == Constants.ORDER_EXPIRED) {
            self.showBanner(title: "alert".localized, message: "this_order_done".localized, style: UIColor.INFO)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                self.navigationController?.dismiss(animated: true, completion: nil)
            })
        }
        
    }
    
    func setUpRecordButton() {
        self.btnRecord = UIButton()
        self.btnRecord?.frame = CGRect(x: 7, y: self.view.frame.size.height - 38, width: 43, height: 43)
        self.btnRecord?.backgroundColor = UIColor.clear
        self.btnRecord?.setBackgroundImage(UIImage(named: "bg_audio_orange"), for: .normal)
        self.btnRecord?.addTarget(self, action: #selector(recordAction), for: .touchUpInside)
        self.btnRecord?.addTarget(self, action: #selector(recordPress), for: .touchDown)
        self.view.addSubview(btnRecord!)
        
        self.btnRecord?.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 11.0, *) {
            self.btnRecord?.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 9).isActive = true
        } else {
            // Fallback on earlier versions
        }
        if #available(iOS 11.0, *) {
            //            actionButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -56).isActive = true
            self.btnRecord?.bottomAnchor.constraint(equalTo: self.inputMessageBarView.bottomAnchor, constant: -6).isActive = true
        } else {
            // Fallback on earlier versions
        }
    }
    
    @objc func recordPress(sender: UIButton!) {
        if (recorder.isRecording) {
            //stop
            self.gif?.isHidden = true
            recorder.stop()
            if (recorder.time > 1) {
                self.sendVoiceMessage()
            }else {
                
            }
        }else {
            //record
            self.gif?.isHidden = false
            recorder.recordName = "chat_file"
            recorder.record()
        }
    }
    
    @objc func recordAction(sender: UIButton!) {
        //        if (recorder.isRecording) {
        //            //stop
        //            self.btnRecord.setImage(UIImage(named: "ic_microphone"), for: .normal)
        //            recorder.stop()
        //            if (recorder.time > 2) {
        //                self.viewRecording.isHidden = false
        //            }else {
        //                self.viewRecording.isHidden = true
        //            }
        //        }else {
        //            //record
        //            self.btnRecord.setImage(UIImage(named: "ic_recording"), for: .normal)
        //            recorder.recordName = "order_file"
        //            recorder.record()
        //        }
        //stop
        self.gif?.isHidden = true
        recorder.stop()
        if (recorder.time > 1) {
            self.sendVoiceMessage()
        }else {
            
        }
    }
    
    func sendCurrentLocation() {
        let link = "\("current_location".localized)\n\n\n\("https://www.google.com/maps/dir/?api=1&destination=\(self.latitude ?? 0.0),\(self.longitude ?? 0.0)&directionsmode=driving")"
        
        self.finishSendingMessage(animated: true)
        ApiService.sendChatMessage(Authorization: self.user?.data?.accessToken ?? "", chatId: self.order?.chatId ?? 0, type: 1, message: link, image: "", voice: "") { (response) in
            if (response.errorCode == 0) {
                let message: ZHCMessage = ZHCMessage.init(senderId: self.user?.data?.userID ?? "", senderDisplayName: self.user?.data?.fullName ?? "", date: Date(), text: link)
                self.demoData.messages.add(message)
                self.finishSendingMessage(animated: true)
            }else {
                self.closeChat()
            }
        }
        
    }
    
    func getChatMessages() {
        demoData.loadMessages()
    }
    
    func closeChat() {
        self.showBanner(title: "alert".localized, message: "delivery_completed_user".localized, style: UIColor.SUCCESS)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    //    func removeCancel() {
    //        self.order?.status = Constants.ORDER_ON_THE_WAY
    //        if (self.isProvider() && self.user?.data?.userID == self.order?.providerID) {
    //            self.setupFloating()
    //        }else if (self.order?.status == Constants.ORDER_ON_THE_WAY) {
    //            self.actionButton?.removeFromSuperview()
    //        }
    //    }
    
    func removeCancel() {
        self.order?.status = Constants.ORDER_ON_THE_WAY
        if (self.isProvider() && self.user?.data?.userID == self.order?.providerID) {
            self.setupFloating()
        }else {
            self.setupUserFloating()
        }
    }
    
    
    func reloadChat() {
        self.messageTableView?.reloadData()
        self.scrollToBottom(animated: false)
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
    
    
    func setupFloating() {
        self.driverActionButton?.removeFromSuperview()
        self.driverActionButton = JJFloatingActionButton()
        self.driverActionButton?.delegate = self
        self.driverActionButton?.overlayView.isHidden = true
        
        self.driverActionButton?.layer.shadowColor = UIColor.black.cgColor
        self.driverActionButton?.layer.shadowOffset = CGSize(width: 0, height: 1)
        self.driverActionButton?.layer.shadowOpacity = Float(0.4)
        self.driverActionButton?.layer.shadowRadius = CGFloat(2)
        
        
        if (self.order?.status != Constants.ORDER_ON_THE_WAY) {
            let item = self.driverActionButton?.addItem()
            item?.titleLabel.text = "cancel_order".localized
            item?.titleLabel.backgroundColor = UIColor.white
            item?.titleLabel.textColor = UIColor.black
            item?.titleLabel.font = UIFont(name: self.getBoldFontName(), size: 13)
            item?.imageView.image = UIImage(named: "chat_cancelorder")
            item?.buttonColor = UIColor.appLogoColor
            item?.buttonImageColor = .white
            item?.action = { item in
                
                self.showAlertField(title: "alert".localized, message: "confirm_cancel_delivery".localized, actionTitle: "yes".localized, cancelTitle: "no".localized) { (reason) in
                    if (self.isProvider() && self.user?.data?.userID == self.order?.providerID) {
                        self.cancelDeliveryByDriver(reason : reason)
                    }else {
                        self.cancelDeliveryByUser(reason : reason)
                    }
                }
                
                
                
            }
        }
        
        let callShopItem = self.driverActionButton?.addItem()
        callShopItem?.titleLabel.text = "Call Shop".localized
        callShopItem?.titleLabel.backgroundColor = UIColor.white
        callShopItem?.titleLabel.textColor = UIColor.black
        callShopItem?.titleLabel.font = UIFont(name: self.getBoldFontName(), size: 13)
        callShopItem?.imageView.image = UIImage(named: "ic_phone")
        callShopItem?.buttonColor = UIColor.appLogoColor
        callShopItem?.buttonImageColor = .white
        callShopItem?.action = { item in
            if let phoneNumber = self.shopPhoneNumber {
                guard let url = URL(string: "tel://\(String(phoneNumber))") else {
                return //be safe
                }
                UIApplication.shared.open(url)
            }
        }
        
        let callCustomerItem = self.driverActionButton?.addItem()
        callCustomerItem?.titleLabel.text = "Call Customer".localized
        callCustomerItem?.titleLabel.backgroundColor = UIColor.white
        callCustomerItem?.titleLabel.textColor = UIColor.black
        callCustomerItem?.titleLabel.font = UIFont(name: self.getBoldFontName(), size: 13)
        callCustomerItem?.imageView.image = UIImage(named: "ic_phone")
        callCustomerItem?.buttonColor = UIColor.appLogoColor
        callCustomerItem?.buttonImageColor = .white
        callCustomerItem?.action = { item in
            if let phoneNumber = self.clientPhoneNumber {
                guard let url = URL(string: "tel://\(String(phoneNumber))") else {
                return //be safe
                }
                UIApplication.shared.open(url)
            }
        }
        let item4 = self.driverActionButton?.addItem()
        item4?.titleLabel.text = "send_current_location".localized
        item4?.titleLabel.backgroundColor = UIColor.white
        item4?.titleLabel.textColor = UIColor.black
        item4?.titleLabel.font = UIFont(name: self.getBoldFontName(), size: 13)
        item4?.imageView.image = UIImage(named: "chat_send_location")
        item4?.buttonColor = UIColor.appLogoColor
        item4?.buttonImageColor = .white
        item4?.action = { item in
            self.sendCurrentLocation()
        }
        
        
        if (self.isProvider() && self.user?.data?.userID == self.order?.providerID) {
            
        }else {
            if (self.order?.status == Constants.ORDER_ON_THE_WAY) {
                let item0 = self.driverActionButton?.addItem()
                item0?.titleLabel.text = "track_order".localized
                item0?.titleLabel.backgroundColor = UIColor.white
                item0?.titleLabel.textColor = UIColor.black
                item0?.titleLabel.font = UIFont(name: self.getBoldFontName(), size: 13)
                item0?.imageView.image = UIImage(named: "chat_track")
                item0?.buttonColor = UIColor.appLogoColor
                item0?.buttonImageColor = .white
                item0?.action = { item in
                    self.goToHome()
                }
            }else if (self.order?.status == Constants.ORDER_PROCESSING) {
                if (self.order?.time ?? 0 <= 1) {
                    let item0 = self.driverActionButton?.addItem()
                    item0?.titleLabel.text = "track_order".localized
                    item0?.titleLabel.backgroundColor = UIColor.white
                    item0?.titleLabel.textColor = UIColor.black
                    item0?.titleLabel.font = UIFont(name: self.getBoldFontName(), size: 13)
                    item0?.imageView.image = UIImage(named: "chat_track")
                    item0?.buttonColor = UIColor.appLogoColor
                    item0?.buttonImageColor = .white
                    item0?.action = { item in
                        self.goToHome()
                    }
                }
            }
        }
        
        
        let item2 = self.driverActionButton?.addItem()
        if (self.order?.status == Constants.ORDER_PROCESSING) {
            if ((self.order?.isPaid ?? false) && (self.order?.paymentMethod == Constants.PAYMENT_METHOD_KNET)) {
                item2?.titleLabel.text = "on_my_way".localized
            }else {
                item2?.titleLabel.text = "release_receipt".localized
            }
        }else {
            item2?.titleLabel.text = "complete_delivery".localized
        }
        
        item2?.titleLabel.font = UIFont(name: self.getBoldFontName(), size: 13)
        item2?.imageView.image = UIImage(named: "chat_onmyway")
        item2?.titleLabel.backgroundColor = UIColor.white
        item2?.titleLabel.textColor = UIColor.black
        item2?.buttonColor = UIColor.appLogoColor
        item2?.buttonImageColor = .white
        item2?.action = { item in
            if (self.order?.status == Constants.ORDER_PROCESSING) {
                //on my way
                if ((self.order?.isPaid ?? false) && (self.order?.paymentMethod == Constants.PAYMENT_METHOD_KNET)) {
                    self.startDelivery(cost: self.order?.price ?? 0.0)
                }else {
                    if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CustomerBillVC") as? CustomerBillVC
                    {
                        vc.delegate = self
                        vc.deliveryCost = self.order?.price ?? 0.0
                        vc.paymentMethod = self.getPaymentMethod(method: self.order?.paymentMethod ?? 0)
                        vc.paymentMethodInt = self.order?.paymentMethod ?? 0
                        vc.commission = self.order?.KnetCommission ?? 0.0
                        vc.modalPresentationStyle = .fullScreen
                        self.present(vc, animated: true, completion: nil)
                    }
                }
            } else {
                self.showPaymentStatusDialog()
            }
        }
        
        //navigate new button in chat
        if (self.order?.status == Constants.ORDER_PROCESSING || self.order?.status == Constants.ORDER_ON_THE_WAY) {
            let item3 = self.driverActionButton?.addItem()
            if (self.order?.status == Constants.ORDER_PROCESSING) {
                item3?.titleLabel.text = "navigate_to_store".localized
            }else {
                item3?.titleLabel.text = "navigate_to_client".localized
            }
            
            item3?.titleLabel.font = UIFont(name: self.getBoldFontName(), size: 13)
            item3?.imageView.image = UIImage(named: "chat_navigate")
            item3?.titleLabel.backgroundColor = UIColor.white
            item3?.titleLabel.textColor = UIColor.black
            item3?.buttonColor = UIColor.appLogoColor
            item3?.buttonImageColor = .white
            item3?.action = { item in
                if (self.order?.status == Constants.ORDER_PROCESSING) {
                    self.startNavigation(longitude: self.order?.fromLongitude ?? 0.0, latitude: self.order?.fromLatitude ?? 0.0)
                }else {
                    self.startNavigation(longitude: self.order?.toLongitude ?? 0.0, latitude: self.order?.toLatitude ?? 0.0)
                }
            }
        }
        
        
        self.driverActionButton?.buttonColor = UIColor.appLogoColor
        self.driverActionButton?.shadowColor = UIColor.blue
        self.driverActionButton?.buttonImage = UIImage(named: "chat_floating")
        
        view.addSubview(self.driverActionButton!)
        self.driverActionButton?.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 11.0, *) {
            self.driverActionButton?.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16).isActive = true
        } else {
            // Fallback on earlier versions
        }
        if #available(iOS 11.0, *) {
            self.driverActionButton?.bottomAnchor.constraint(equalTo: self.inputMessageBarView.safeAreaLayoutGuide.bottomAnchor, constant: -56).isActive = true
        } else {
            // Fallback on earlier versions
        }
        // last 4 lines can be replaced with
        // actionButton.display(inViewController: self)
        
        self.driverActionButton?.open()
        
    }
    
    func completeDelivery() {
        ApiService.completeDelivery(Authorization: self.user?.data?.accessToken ?? "", deliveryId: self.order?.id ?? 0, completion: { (response) in
            if (response.errorCode == 0) {
                self.showBanner(title: "alert".localized, message: "delivery_completed", style: UIColor.SUCCESS)
                
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RateUserDialog") as! RateUserDialog
                vc.deliveryId = self.order?.id ?? 0
                self.definesPresentationContext = true
                vc.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
                vc.view.backgroundColor = UIColor.clear
                self.present(vc, animated: true, completion: nil)
                
            }else {
                self.showBanner(title: "alert".localized, message: response.errorMessage ?? "", style: UIColor.INFO)
            }
        })
    }
    
    
    func deliveryIsReceived() {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RateDriverDialog") as! RateDriverDialog
        vc.deliveryId = self.order?.id ?? 0
        self.definesPresentationContext = true
        vc.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        vc.view.backgroundColor = UIColor.clear
        vc.hideCancel = true
        vc.delegate = self
        self.present(vc, animated: true, completion: nil)
    }
    
    func reloadFromRateDriver() {
        self.closeChat()
    }
    
    func showPaymentStatusDialog() {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PaymentStatusDialog") as! PaymentStatusDialog
        self.definesPresentationContext = true
        vc.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        vc.view.backgroundColor = UIColor.clear
        vc.delegate = self
        vc.order = self.order
        vc.isPaid = self.order?.isPaid ?? false
        self.present(vc, animated: true, completion: nil)
    }
    
    func onCashPaid() {
        SVProgressHUD.show()
        ApiService.changePaymentMethod(Authorization: self.user?.data?.accessToken ?? "", orderId: self.order?.id ?? 0, paymentMethod: 1) { (response) in
            SVProgressHUD.dismiss()
            self.completeDelivery()
        }
    }
    
    func onCashFail() {
        self.sendTextMessage(text: "Please pay the driver in cash\n\n\nالرجاء دفع قيمة الطلب كاش للسائق")
    }
    
    func onKnetPaid() {
        if (self.order?.isPaid ?? false) {
            self.completeDelivery()
        }else {
            SVProgressHUD.show()
            ApiService.changePaymentMethod(Authorization: self.user?.data?.accessToken ?? "", orderId: self.order?.id ?? 0, paymentMethod: 1) { (response) in
                SVProgressHUD.dismiss()
                self.completeDelivery()
            }
        }
    }
    
    func onKnetFail() {
        //self.sendTextMessage(text: self.order?.invoiceId ?? "")
        self.sendTextMessage(text: "Please complete your order payment using Knet from order details above.\n\n\nالرجاء اتمام علمية الدفع باستخدام كي نت بالضغظ على تفاصيل الطلب بالاعلى من ثم دفع الطلب")
    }
    
    func sendTextMessage(text : String) {
        ApiService.sendChatMessage(Authorization: self.user?.data?.accessToken ?? "", chatId: self.order?.chatId ?? 0, type: 1, message: text, image: "", voice: "") { (response) in
            if (response.errorCode == 0) {
                SVProgressHUD.dismiss()
                let message: ZHCMessage = ZHCMessage.init(senderId: self.user?.data?.userID ?? "", senderDisplayName: self.user?.data?.fullName ?? "", date: Date(), text: text)
                self.demoData.messages.add(message)
                self.finishSendingMessage(animated: true)
            }else {
                self.closeChat()
            }
        }
    }
    
    func cancelDeliveryByUser(reason : String) {
        ApiService.cancelDelivery(Authorization: self.user?.data?.accessToken ?? "", deliveryId: self.order?.id ?? 0, reason : reason, completion: { (response) in
            if (response.errorCode == 0) {
                self.showBanner(title: "alert".localized, message: "delivery_cancelled".localized, style: UIColor.SUCCESS)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                    self.goToOrders()
                })
            }else {
                if (self.order?.status == Constants.ORDER_CANCELLED || self.order?.status == Constants.ORDER_COMPLETED || self.order?.status == Constants.ORDER_EXPIRED) {
                    self.goToOrders()
                }else {
                    self.showBanner(title: "alert".localized, message: response.errorMessage ?? "", style: UIColor.INFO)
                }
                //  self.dismiss(animated: true, completion: nil)
            }
        })
    }
    
    func cancelDeliveryByDriver(reason : String) {
        ApiService.cancelDeliveryByDriver(Authorization: self.user?.data?.accessToken ?? "", deliveryId: self.order?.id ?? 0, reason : reason, completion: { (response) in
            if (response.errorCode == 0) {
                self.showBanner(title: "alert".localized, message: "delivery_cancelled".localized, style: UIColor.SUCCESS)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                    self.goToOrders()
                })
            }else {
                if (self.order?.status == Constants.ORDER_CANCELLED || self.order?.status == Constants.ORDER_COMPLETED || self.order?.status == Constants.ORDER_EXPIRED) {
                    self.goToOrders()
                }else {
                    self.showBanner(title: "alert".localized, message: response.errorMessage ?? "", style: UIColor.INFO)
                }
                //  self.dismiss(animated: true, completion: nil)
            }
        })
    }
    
    func goToOrders() {
        if (self.isProvider()) {
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WorkingOrdersNavigationController") as! UINavigationController
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true, completion: nil)
        }else {
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "OrdersNavigationController") as! UINavigationController
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    func goToHome() {
        let mainStoryboardIpad : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let initialViewControlleripad : UIViewController = mainStoryboardIpad.instantiateViewController(withIdentifier: "MapNavigationController") as! UINavigationController
        initialViewControlleripad.modalPresentationStyle = .fullScreen
        self.present(initialViewControlleripad, animated: true, completion: {})
    }
    
    private func setupHeaderbuttons() {
        
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        
        //self.view.addSubview(view)
        self.navigationItem.titleView = view

        // Setup View Constrint
        view.topAnchor.constraint(equalTo: self.navigationItem.titleView!.topAnchor, constant: 0).isActive = true
        view.leftAnchor.constraint(equalTo: self.navigationItem.titleView!.leftAnchor, constant: 0).isActive = true
        view.rightAnchor.constraint(equalTo: self.navigationItem.titleView!.rightAnchor, constant: 0).isActive = true
        view.heightAnchor.constraint(equalToConstant: 70).isActive = true
        view.widthAnchor.constraint(equalToConstant: 100).isActive = true
        
        // Add stackView to the View
        view.addSubview(stackView)
        
        // Setup Constraints
        self.stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        self.stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        self.stackView.addArrangedSubview(paybutton)
        
        self.paybutton.heightAnchor.constraint(equalToConstant: 35).isActive = true
        self.paybutton.widthAnchor.constraint(equalToConstant: 35).isActive = true
       
        if self.user?.data?.roles?.contains(find: "Driver") == false {
            self.stackView.addArrangedSubview(callDriverbutton)

            self.callDriverbutton.heightAnchor.constraint(equalToConstant: 35).isActive = true
            self.callDriverbutton.widthAnchor.constraint(equalToConstant: 35).isActive = true
        }
    }
    
    @objc func onCallTheDriver(){
        self.callNumber(phone: self.order?.ProviderPhone ?? "")

    }
    
    @objc func onPayOrder() {
        
        if self.orderInfo?.orderPrice != nil {
            let orderCost = self.orderInfo?.orderPrice ?? 0.0
            let knetCommistion = (0.15 * 100).rounded() / 100
            let deliveryCost = self.orderInfo?.cost ?? 0.0
            
            let totalCost = orderCost + knetCommistion
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc : PaymentVC = storyboard.instantiateViewController(withIdentifier: "PaymentVC") as! PaymentVC
            
            vc.total = totalCost
            
            let item = ShopMenuItem(id: 0, name: "driverFee", imageName: "", price: deliveryCost, shopMenuItemDescription: "", count: 1, isOutOfStock: false)
            let item2 = ShopMenuItem(id: 1, name: "order_price", imageName: "", price: orderCost - deliveryCost, shopMenuItemDescription: "", count: 1, isOutOfStock: false)
            let item3 = ShopMenuItem(id: 2, name: "knet_commission", imageName: "", price: knetCommistion, shopMenuItemDescription: "", count: 1, isOutOfStock: false)
            vc.items.append(item)
            vc.createDate = self.order?.createdDate
            vc.items.append(item2)
            vc.items.append(item3)
            vc.delegate = self
            
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "alert".localized, message: "payOrderErrorMessage".localized, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "PayOrder.Alert.OK".localized, style: .cancel, handler: { action in
                  switch action.style {
                  case .default:
                        print("default")
                  case .cancel:
                        print("cancel")
                  case .destructive:
                        print("destructive")
                  @unknown default:
                    print("error")
                  }}))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func setupUserFloating() {
        self.actionButton?.removeFromSuperview()
        self.actionButton = JJFloatingActionButton()
        self.actionButton?.delegate = self
        self.driverActionButton?.overlayView.isHidden = true
        
        self.actionButton?.layer.shadowColor = UIColor.black.cgColor
        self.actionButton?.layer.shadowOffset = CGSize(width: 0, height: 1)
        self.actionButton?.layer.shadowOpacity = Float(0.4)
        self.actionButton?.layer.shadowRadius = CGFloat(2)
        
        if (self.order?.status == Constants.ORDER_ON_THE_WAY || self.order?.status == Constants.ORDER_PROCESSING) {
//            let item90 = actionButton?.addItem()
//                      item90?.titleLabel.text = "chat_calldriver".localized
//                      item90?.titleLabel.backgroundColor = UIColor.white
//                      item90?.titleLabel.textColor = UIColor.black
//                      item90?.titleLabel.font = UIFont(name: self.getBoldFontName(), size: 13)
//                      item90?.imageView.image = UIImage(named: "chat_call")
//                      item90?.buttonColor = UIColor.appLogoColor
//                      item90?.buttonImageColor = .white
//                      item90?.action = { item in
//                        self.callNumber(phone: self.order?.ProviderPhone ?? "")
//                      }
       }
        
        if (self.order?.status != Constants.ORDER_ON_THE_WAY) {
            let item = actionButton?.addItem()
            item?.titleLabel.text = "cancel_order".localized
            item?.titleLabel.backgroundColor = UIColor.white
            item?.titleLabel.textColor = UIColor.black
            item?.titleLabel.font = UIFont(name: self.getBoldFontName(), size: 13)
            item?.imageView.image = UIImage(named: "chat_cancelorder")
            item?.buttonColor = UIColor.appLogoColor
            item?.buttonImageColor = .white
            item?.action = { item in
                
                //cancel order
                //                self.showAlert(title: "alert".localized, message: "confirm_cancel_delivery".localized, actionTitle: "yes".localized, cancelTitle: "no".localized, actionHandler: {
                //                    if (self.isProvider() && self.user?.data?.userID == self.order?.providerID) {
                //                        self.cancelDeliveryByDriver()
                //                    }else {
                //                        self.cancelDeliveryByUser()
                //                    }
                //                })
                
                self.showAlertField(title: "alert".localized, message: "confirm_cancel_delivery".localized, actionTitle: "yes".localized, cancelTitle: "no".localized) { (reason) in
                    if (self.isProvider() && self.user?.data?.userID == self.order?.providerID) {
                        self.cancelDeliveryByDriver(reason : reason)
                    }else {
                        self.cancelDeliveryByUser(reason : reason)
                    }
                }
                
            }
        }
        
        
        
        if (self.isProvider() && self.user?.data?.userID == self.order?.providerID) {
            
        }else {
            if (self.order?.status == Constants.ORDER_ON_THE_WAY) {
                let item0 = self.actionButton?.addItem()
                item0?.titleLabel.text = "track_order".localized
                item0?.titleLabel.backgroundColor = UIColor.white
                item0?.titleLabel.textColor = UIColor.black
                item0?.titleLabel.font = UIFont(name: self.getBoldFontName(), size: 13)
                item0?.imageView.image = UIImage(named: "chat_track")
                item0?.buttonColor = UIColor.appLogoColor
                item0?.buttonImageColor = .white
                item0?.action = { item in
                    self.goToHome()
                }
            }
            
        }
        
        
        let item4 = self.actionButton?.addItem()
        item4?.titleLabel.text = "send_current_location".localized
        item4?.titleLabel.backgroundColor = UIColor.white
        item4?.titleLabel.textColor = UIColor.black
        item4?.titleLabel.font = UIFont(name: self.getBoldFontName(), size: 13)
        item4?.imageView.image = UIImage(named: "chat_send_location")
        item4?.buttonColor = UIColor.appLogoColor
        item4?.buttonImageColor = .white
        item4?.action = { item in
            self.sendCurrentLocation()
        }
        
        
        
        self.actionButton?.buttonColor = UIColor.appLogoColor
        self.actionButton?.shadowColor = UIColor.blue
        self.actionButton?.buttonImage = UIImage(named: "chat_floating")
        
        view.addSubview(actionButton!)
        self.actionButton?.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 11.0, *) {
            self.actionButton?.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16).isActive = true
        } else {
            // Fallback on earlier versions
        }
        if #available(iOS 11.0, *) {
            //  actionButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -56).isActive = true
            self.actionButton?.bottomAnchor.constraint(equalTo: self.inputMessageBarView.safeAreaLayoutGuide.bottomAnchor, constant: -56).isActive = true
        } else {
            // Fallback on earlier versions
        }
        
        // last 4 lines can be replaced with
        // actionButton.display(inViewController: self)
        self.actionButton?.open()
        
    }
    
    
    func onDone(images: [UIImage], orderCost : Double,costDetails: String) {
        SVProgressHUD.show()
        ApiService.sendChatMessage(Authorization: self.user?.data?.accessToken ?? "", chatId: self.order?.chatId ?? 0, type: 1, message: costDetails, image: "", voice: "") { (response) in
            if (response.errorCode == 0) {
                SVProgressHUD.dismiss()
                let message: ZHCMessage = ZHCMessage.init(senderId: self.user?.data?.userID ?? "", senderDisplayName: self.user?.data?.fullName ?? "", date: Date(), text: costDetails)
                self.demoData.messages.add(message)
                self.finishSendingMessage(animated: true)
                if (images.count > 0) {
                    self.uploadImages(images: images, cost: orderCost)
                }else {
                    self.startDelivery(cost: orderCost)
                }
                
            }
        }
        
    }
    
    
    func startDelivery(cost : Double) {
        ApiService.startDelivery(Authorization: self.user?.data?.accessToken ?? "", deliveryId: self.order?.id ?? 0, actualPrice: cost) { (response) in
            if (response.errorCode == 0) {
                self.showBanner(title: "alert".localized, message: "delivery_started".localized, style: UIColor.SUCCESS)
                self.startNavigation(longitude: self.order?.toLongitude ?? 0.0, latitude: self.order?.toLatitude ?? 0.0)
                
                self.order = DatumDel(id: self.order?.id ?? 0, title: self.order?.title ?? "", status: Constants.ORDER_ON_THE_WAY, statusString: self.order?.statusString ?? "", image: self.order?.image ?? "", createdDate: self.order?.createdDate ?? "", chatId: self.order?.chatId ?? 0, fromAddress: self.order?.fromAddress ?? "", fromLatitude: self.order?.fromLatitude ?? 0.0, fromLongitude: self.order?.fromLongitude ?? 0.0, toAddress: self.order?.toAddress ?? "", toLatitude: self.order?.toLatitude ?? 0.0, toLongitude: self.order?.toLongitude ?? 0.0, providerID: self.order?.providerID, providerName: self.order?.providerName ?? "", providerImage: self.order?.providerImage ?? "", providerRate: self.order?.providerRate ?? 0.0, time: self.order?.time ?? 0, price: self.order?.price ?? 0.0, serviceName: self.order?.serviceName ?? "", paymentMethod: self.order?.paymentMethod ?? 0, items: self.order?.items ?? [ShopMenuItem](), isPaid: self.order?.isPaid ?? false, invoiceId: self.order?.invoiceId ?? "", toFemaleOnly: self.order?.toFemaleOnly ?? false, shopId: self.order?.shopId ?? 0, OrderPrice: self.order?.OrderPrice ?? 0.0, KnetCommission: self.order?.KnetCommission ?? 0.0, ClientPhone: self.order?.ClientPhone ?? "", ProviderPhone : self.order?.ProviderPhone ?? "", hasUnreadMessages: self.order?.hasUnreadMessages ?? false)
                
                self.setupFloating()
            }else {
                self.showBanner(title: "alert".localized, message: response.errorMessage ?? "", style: UIColor.INFO)
            }
        }
    }
    
    
    func startNavigation(longitude : Double, latitude : Double) {
        let sourceSelector = UIAlertController(title: "navigate_to_client".localized, message: nil, preferredStyle: .actionSheet)
        
        if let popoverController = sourceSelector.popoverPresentationController {
            popoverController.sourceView = self.view //to set the source of your alert
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0) // you can set this as per your requirement.
            popoverController.permittedArrowDirections = [] //to hide the arrow of any particular direction
        }
        
        let googleMapsAction = UIAlertAction(title: "googleMaps".localized, style: .default) { (action) in
            
            
            let url = URL(string: "https://www.google.com/maps/dir/?api=1&destination=\(latitude),\(longitude)&directionsmode=driving")
            
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url!, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url!)
            }
        }
        
        let appleMapsAction = UIAlertAction(title: "appleMaps".localized, style: .default) { (action) in
            
            let coordinate = CLLocationCoordinate2DMake(latitude ,longitude)
            let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate, addressDictionary:nil))
            mapItem.name = "\("") \("")"
            mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving])
            
        }
        let cancelAction = UIAlertAction(title: "cancel".localized, style: .cancel) { (action) in }
        
        sourceSelector.addAction(googleMapsAction)
        // sourceSelector.addAction(appleMapsAction)
        sourceSelector.addAction(cancelAction)
        
        self.present(sourceSelector, animated: true, completion: nil)
    }
    
    
    func uploadImages(images : [UIImage], cost : Double) {
        for image in images {
            let strBase64 = image.toBase64() ?? ""
            ApiService.sendChatMessage(Authorization: self.user?.data?.accessToken ?? "", chatId: self.order?.chatId ?? 0, type: 2, message: "" ,image: strBase64, voice: "") { (response) in
                if (response.errorCode == 0) {
                    self.demoData.addPhotoMediaMessage(image: image)
                    self.messageTableView?.reloadData()
                    self.finishSendingMessage()
                }
            }
        }
        self.startDelivery(cost: cost)
    }
    
    func isArabic() -> Bool {
        if (MOLHLanguage.currentAppleLanguage() == "ar") {
            return true
        }else {
            return false
        }
    }
    
    func showBanner(title:String, message:String,style: UIColor) {
        let banner = Banner(title: title, subtitle: message, image: nil, backgroundColor: style)
        banner.dismissesOnTap = true
        banner.textColor = UIColor.white
        if (isArabic()) {
            banner.titleLabel.font = UIFont(name: Constants.ARABIC_FONT_REGULAR, size: 16)
            banner.detailLabel.font = UIFont(name: Constants.ARABIC_FONT_REGULAR, size: 14)
        }else {
            banner.titleLabel.font = UIFont(name: Constants.ENGLISH_FONT_REGULAR, size: 16)
            banner.detailLabel.font = UIFont(name: Constants.ENGLISH_FONT_REGULAR, size: 14)
        }
        
        banner.show(duration: 2.0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.presentBool {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonItem.SystemItem.stop, target: self, action:#selector(closePressed))
        }
        
        if (self.order?.status == Constants.ORDER_COMPLETED || self.order?.status == Constants.ORDER_EXPIRED || self.order?.status == Constants.ORDER_CANCELLED) {
            self.showBanner(title: "alert".localized, message: "delivery_completed_user".localized, style: UIColor.INFO)
            DispatchQueue.main.asyncAfter(deadline: .now () + 1) {
                self.dismiss(animated: true, completion: nil)
            }
        }
        
    }
    
    @objc func closePressed() -> Void {
        self.navigationController?.dismiss(animated: true, completion: nil);
    }
    
    // MARK: ZHCMessagesTableViewDataSource
    
    override func senderDisplayName() -> String {
        return self.user?.data?.fullName ?? "";
    }
    
    override func  senderId() -> String {
        return self.user?.data?.userID ?? ""
    }
    
    override func  tableView(_ tableView: ZHCMessagesTableView, messageDataForCellAt indexPath: IndexPath) -> ZHCMessageData {
        return self.demoData.messages.object(at: indexPath.row) as! ZHCMessageData;
    }
    
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        self.demoData.messages.removeObject(at: indexPath.row);
    }
    
    override func tableView(_ tableView: ZHCMessagesTableView, messageBubbleImageDataForCellAt indexPath: IndexPath) -> ZHCMessageBubbleImageDataSource? {
        /**
         *  You may return nil here if you do not want bubbles.
         *  In this case, you should set the background color of your TableView view cell's textView.
         *
         *  Otherwise, return your previously created bubble image data objects.
         */

        let message: ZHCMessage = self.demoData.messages.object(at: indexPath.row) as! ZHCMessage;
        if message.isMediaMessage {
            print("is mediaMessage");
        }
        if message.senderId == self.senderId() {
            return self.demoData.outgoingBubbleImageData!
        }
        return self.demoData.incomingBubbleImageData!
    }
    
    override func tableView(_ tableView: ZHCMessagesTableView, avatarImageDataForCellAt indexPath: IndexPath) -> ZHCMessageAvatarImageDataSource? {
        
        let message: ZHCMessage = self.demoData.messages.object(at: indexPath.row) as! ZHCMessage;
        
        return self.demoData.avatars.object(forKey: message.senderId) as! ZHCMessageAvatarImageDataSource?
        
    }
    
    override func tableView(_ tableView: ZHCMessagesTableView, attributedTextForCellTopLabelAt indexPath: IndexPath) -> NSAttributedString? {
        
        let message: ZHCMessage = (self.demoData.messages.object(at: indexPath.row) as? ZHCMessage)!
        return ZHCMessagesTimestampFormatter.shared().attributedTimestamp(for: message.date)
    }
    
    override func tableView(_ tableView: ZHCMessagesTableView, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath) -> NSAttributedString? {
        let message: ZHCMessage = self.demoData.messages.object(at: indexPath.row) as! ZHCMessage;
        if message.senderId == self.senderId(){
            return NSAttributedString.init(string: self.user?.data?.fullName ?? "");
        }
        if (indexPath.row-1)>0 {
            let preMessage: ZHCMessage = self.demoData.messages.object(at: indexPath.row-1) as! ZHCMessage;
            if preMessage.senderId == message.senderId{
                return nil;
            }
        }
        return NSAttributedString.init(string: message.senderDisplayName);
    }
    
    
    override func tableView(_ tableView: ZHCMessagesTableView, attributedTextForCellBottomLabelAt indexPath: IndexPath) -> NSAttributedString? {
        return nil;
    }
    
    // MARK: Adjusting cell label heights
    
    override func tableView(_ tableView: ZHCMessagesTableView, heightForCellTopLabelAt indexPath: IndexPath) -> CGFloat {
        /**
         *  Each label in a cell has a `height` delegate method that corresponds to its text dataSource method
         */
        
        /**
         *  This logic should be consistent with what you return from `attributedTextForCellTopLabelAtIndexPath:`
         *  The other label height delegate methods should follow similarly
         *
         *  Show a timestamp for every 3rd message
         */
        var labelHeight = 0.0;
        if indexPath.row%3 == 0 {
            labelHeight = Double(kZHCMessagesTableViewCellLabelHeightDefault);
        }
        return CGFloat(labelHeight);
    }
    
    override func tableView(_ tableView: ZHCMessagesTableView, heightForMessageBubbleTopLabelAt indexPath: IndexPath) -> CGFloat {
        var labelHeight = kZHCMessagesTableViewCellLabelHeightDefault;
        let currentMessage: ZHCMessage = self.demoData.messages.object(at: indexPath.row) as! ZHCMessage;
        if currentMessage.senderId==self.senderId(){
            labelHeight = 0.0;
        }
        if ((indexPath.row - 1) > 0){
            let previousMessage: ZHCMessage = self.demoData.messages.object(at: indexPath.row-1) as! ZHCMessage;
            if (previousMessage.senderId == currentMessage.senderId) {
                labelHeight = 0.0;
            }
        }
        return CGFloat(labelHeight);
    }
    
    override func tableView(_ tableView: ZHCMessagesTableView, heightForCellBottomLabelAt indexPath: IndexPath) -> CGFloat {
        let string: NSAttributedString? = self.tableView(tableView, attributedTextForCellBottomLabelAt: indexPath);
        if ((string) != nil) {
            return CGFloat(kZHCMessagesTableViewCellSpaceDefault);
        }else{
            return 0.0;
        }
    }
    
    //MARK: ZHCMessagesTableViewDelegate
    override func tableView(_ tableView: ZHCMessagesTableView, didTapAvatarImageView avatarImageView: UIImageView, at indexPath: IndexPath) {
        super.tableView(tableView, didTapAvatarImageView: avatarImageView, at: indexPath);
    }
    
    override func tableView(_ tableView: ZHCMessagesTableView, didTapMessageBubbleAt indexPath: IndexPath) {
        super.tableView(tableView, didTapMessageBubbleAt: indexPath);
        let message: ZHCMessage = self.demoData.messages.object(at: indexPath.row) as! ZHCMessage;
        if (message.isMediaMessage) {
            var images = [String]()
            //  let str = message.media.mediaData?() as? String ?? ""
            let str = message.senderDisplayName
            images.append(str)
            DispatchQueue.main.async {
                if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ImageSliderVC") as? ImageSliderVC
                {
                    vc.orderImages = images
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
    }
    
    override func tableView(_ tableView: ZHCMessagesTableView, performAction action: Selector, forcellAt indexPath: IndexPath, withSender sender: Any?) {
        super.tableView(tableView, performAction: action, forcellAt: indexPath, withSender: sender);
    }
    
    //MARK:TableView datasource
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.demoData.messages.count;
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ZHCMessagesTableViewCell = super.tableView(tableView, cellForRowAt: indexPath) as! ZHCMessagesTableViewCell
        
        self.configureCell(cell, atIndexPath: indexPath)
        return cell
    }
    
    //MARK:Configure Cell Data
    func configureCell(_ cell: ZHCMessagesTableViewCell, atIndexPath indexPath: IndexPath) -> Void {
        let message: ZHCMessage = self.demoData.messages.object(at: indexPath.row) as! ZHCMessage;
        if !message.isMediaMessage {
            if (message.senderId == self.senderId()) {
                cell.textView?.textColor = UIColor.white;
            }else {
                if (message.text.contains(find: "I have successfully paid my order using Knet.") || message.text.contains(find: "لقد قمت بدفع الطلب باستخدام كي نت بنجاح.")) {
                    self.order?.isPaid = true
                }
                cell.textView?.textColor = UIColor.black;
            }
        } else {
            var images = [String]()

            //  let str = message.media.mediaData?() as? String ?? ""
            let str = message.senderDisplayName
            images.append(str)
            cell.textView?.text = "bla bla bla bla "

            for str in images {
                
                if (str.contains(find: "jpg") || str.contains(find: "jpeg") || str.contains(find: "png")) {
                  
                        let alamofireSource = KingfisherSource(urlString: "\(Constants.IMAGE_URL)\(str)")!
                    alamofireSource.load(to: cell.messageBubbleImageView ?? UIImageView()) { (image) in
                        //cell.imageView?.image = image
                        DispatchQueue.main.async {
                            let imageView = UIImageView(image: image)
                            imageView.frame = CGRect(x: -2, y: -4, width: 210, height: 150)
                                //imageView.translatesAutoresizingMaskIntoConstraints = false
                            cell.messageBubbleTopLabel?.isHidden = true
                            cell.messageBubbleContainerView?.addSubview(imageView)
                            cell.bringSubviewToFront(cell.mediaView ?? cell)
                            
                            cell.mediaView?.isHidden = false
                            cell.textView?.isHidden = true
                        }
                    }
                }
            }
        }
    }
    
    //MARK: Messages view controller
    
    override func didPressSend(_ button: UIButton?, withMessageText text: String, senderId: String, senderDisplayName: String, date: Date) {
        let message: ZHCMessage = ZHCMessage.init(senderId: senderId, senderDisplayName: senderDisplayName, date: date, text: text)
        self.demoData.messages.add(message)
        self.finishSendingMessage(animated: true)
        
        ApiService.sendChatMessage(Authorization: self.user?.data?.accessToken ?? "", chatId: self.order?.chatId ?? 0, type: 1, message: text, image: "", voice: "") { (response) in
            if (response.errorCode == 0) {
                
            }else {
                self.closeChat()
            }
        }
    }
    
    func sendVoiceMessage() {
        var audioData : Data?
        do {
            audioData = try Data.init(contentsOf: self.recorder.getUrl())
        }catch let err {
            audioData = Data(base64Encoded: "")
        }
        
        let audioBase64 = audioData?.base64EncodedString()
        
        ApiService.sendChatMessage(Authorization: self.user?.data?.accessToken ?? "", chatId: self.order?.chatId ?? 0, type: 3, message: "", image: "", voice: audioBase64!) { (response) in
            if (response.errorCode == 0) {
                let audioItem: ZHCAudioMediaItem = ZHCAudioMediaItem.init(data: audioData as! Data);
                let audioMessage: ZHCMessage = ZHCMessage.init(senderId: self.senderId(), displayName: self.senderDisplayName(), media: audioItem);
                self.demoData.messages.add(audioMessage);
                self.finishSendingMessage(animated: true);
            }
        }
        
    }
    
    //MARK: ZHCMessagesInputToolbarDelegate
    override func messagesInputToolbar(_ toolbar: ZHCMessagesInputToolbar, sendVoice voiceFilePath: String, seconds senconds: TimeInterval) {
        let audioData: NSData = try!NSData.init(contentsOfFile: voiceFilePath)
        
        let audioBase64 = audioData.base64EncodedString()
        
        ApiService.sendChatMessage(Authorization: self.user?.data?.accessToken ?? "", chatId: self.order?.chatId ?? 0, type: 3, message: "", image: "", voice: audioBase64) { (response) in
            if (response.errorCode == 0) {
                let audioItem: ZHCAudioMediaItem = ZHCAudioMediaItem.init(data: audioData as Data);
                let audioMessage: ZHCMessage = ZHCMessage.init(senderId: self.senderId(), displayName: self.senderDisplayName(), media: audioItem);
                self.demoData.messages.add(audioMessage);
                self.finishSendingMessage(animated: true);
            }
        }
    }
    
    //MARK: ZHCMessagesMoreViewDelegate
    override func messagesMoreView(_ moreView: ZHCMessagesMoreView, selectedMoreViewItemWith index: Int) {
        switch index {
        case 0://Camera
            guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
                self.selectImageFrom(.photoLibrary)
                return
            }
            self.selectImageFrom(.camera)
            break
        case 1://Photos
            self.imagePicker =  UIImagePickerController()
            self.imagePicker.delegate = self
            self.imagePicker.sourceType = .photoLibrary
            self.present(self.imagePicker, animated: true, completion: nil)
            break
            //        case 2:
            //            self.demoData.addLocationMediaMessageCompletion {
            //                self.messageTableView?.reloadData();
            //                self.finishSendingMessage();
            //            }
            
        default:
            break;
            
        }
    }
    
    //MARK: ZHCMessagesMoreViewDataSource
    override func messagesMoreViewTitles(_ moreView: ZHCMessagesMoreView) -> [Any] {
        return ["camera".localized,"gallery".localized];
    }
    
    override func messagesMoreViewImgNames(_ moreView: ZHCMessagesMoreView) -> [Any] {
        return ["bg_in_camera","bg_in_photos"]
    }
    
    
    func getFontName() -> String {
        if (self.isArabic()) {
            return Constants.ARABIC_FONT_REGULAR
        }else {
            return Constants.ENGLISH_FONT_REGULAR
        }
    }
    
    func getBoldFontName() -> String {
        if (self.isArabic()) {
            return Constants.ARABIC_FONT_SEMIBOLD
        }else {
            return Constants.ENGLISH_FONT_SEMIBOLD
        }
    }
    
    
    
    func showAlert(title: String,
                   message: String,
                   actionTitle: String,
                   cancelTitle: String,
                   actionHandler:(()->Void)?,
                   cancelHandler:(()->Void)? = nil) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: actionTitle, style: .default) { (action) in
            actionHandler?()
        }
        
        let cancelAction = UIAlertAction(title: cancelTitle, style: .cancel) { (action) in
            cancelHandler?()
        }
        
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view contrsoller.
     }
     */
    
    func isProvider() -> Bool {
        if ((self.user?.data?.roles?.contains(find: "Driver"))! || (self.user?.data?.roles?.contains(find: "ServiceProvider"))! || (self.user?.data?.roles?.contains(find: "TenderProvider"))!) {
            return true
        }
        return false
    }
    
    func showAlertField(title: String,
                        message: String,
                        actionTitle: String,
                        cancelTitle: String,
                        completion:@escaping(_ reason : String)-> Void) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        var inputTextField: UITextField?
        inputTextField?.placeholder = "reason_here".localized
        inputTextField?.textColor = UIColor.black
        inputTextField?.font = UIFont(name: self.getFontName(), size: 14.0)
        
        alert.addTextField { textField -> Void in
            // you can use this text field
            inputTextField = textField
            inputTextField?.placeholder = "reason_here".localized
            inputTextField?.textColor = UIColor.black
            inputTextField?.font = UIFont(name: self.getFontName(), size: 14.0)
        }
        
        let okAction = UIAlertAction(title: actionTitle, style: .default) { (action) in
            completion(inputTextField?.text ?? "")
        }
        
        let cancelAction = UIAlertAction(title: cancelTitle, style: .cancel) { (action) in
            //nth
        }
        
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func callNumber(phone : String) {
           if let url = URL(string: "tel://\(phone)") {
               UIApplication.shared.openURL(url)
           }
       }
    
    func showLoading() {
        SVProgressHUD.show()
    }
    
    func hideLoading() {
        SVProgressHUD.dismiss()
    }
}

extension ZHCDemoMessagesViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imagePicker.dismiss(animated: true, completion: nil)
        
        guard let selectedImage = info[.originalImage] as? UIImage else {
            print("Image not found!")
            return
        }
        let strBase64 = selectedImage.toBase64() ?? ""
        ApiService.sendChatMessage(Authorization: self.user?.data?.accessToken ?? "", chatId: self.order?.chatId ?? 0, type: 2, message: "" ,image: strBase64, voice: "") { (response) in
            if (response.errorCode == 0) {
                self.demoData.addPhotoMediaMessage(image: selectedImage)
                self.messageTableView?.reloadData()
                self.finishSendingMessage()
            }
        }
    }
}


extension ZHCDemoMessagesViewController: JJFloatingActionButtonDelegate {
    func floatingActionButtonWillOpen(_ button: JJFloatingActionButton) {
        
    }
    func floatingActionButtonDidOpen(_ button: JJFloatingActionButton) {
        
    }
    func floatingActionButtonWillClose(_ button: JJFloatingActionButton) {
        // self.driverActionButton?.open()
        //  self.actionButton?.open()
    }
    func floatingActionButtonDidClose(_ button: JJFloatingActionButton) {
        //  self.driverActionButton?.open()
        //  self.actionButton?.open()
    }
}

extension ZHCDemoMessagesViewController: PaymentDelegate {
    func onPaymentSuccess(payment: PaymentStatusResponse) {
        self.showLoading()
        ApiService.createPaymentRecord(Authorization: DataManager.loadUser().data?.accessToken ?? "", orderId: self.order?.id ?? 0, payment: payment) { (response) in
            self.hideLoading()
            self.sendTextMessage(text: "I have successfully paid my order using Knet.\n\n\nلقد قمت بدفع الطلب باستخدام كي نت بنجاح.")
            SVProgressHUD.show()
            ApiService.sendUserNotification(Authorization: self.user?.data?.accessToken ?? "", arabicTitle: "الطلب \(Constants.ORDER_NUMBER_PREFIX)\(self.order?.id ?? 0)", englishTitle: "Order \(Constants.ORDER_NUMBER_PREFIX)\(self.order?.id ?? 0)", arabicBody: "قام الزبون بدفع الطلب باستخدام كي نت", englishbody: "Client paid using Knet", userId: self.order?.providerID ?? "", type: 989) { (response) in
                SVProgressHUD.dismiss()
            }
            self.navigationController?.popViewController(animated: true)
        }
        
    }
    
    func onPaymentFail() {
        //self.delegate?.onOrderPaymentFail()
        self.sendTextMessage(text: "I did'nt pay my order using Knet, is it possible that we use cash?\n\n\nلم اتمكن من الدفع باستخدام كي نت، هل من الممكن الدفع كاش؟")
    }
}
