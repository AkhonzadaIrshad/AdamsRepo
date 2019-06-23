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

class ZHCDemoMessagesViewController: ZHCMessagesViewController, BillDelegate, ChatDelegate,UINavigationControllerDelegate {
    
    var demoData: ZHModelData = ZHModelData.init();
    var presentBool: Bool = false;
    
    var order : DatumDel?
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        }else if (self.order?.status != Constants.ORDER_ON_THE_WAY) {
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
    
    func getChatMessages() {
        demoData.loadMessages()
    }
    
    func closeChat() {
        self.showBanner(title: "alert".localized, message: "delivery_completed_user", style: UIColor.SUCCESS)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.dismiss(animated: true, completion: nil)
        }
        
    }
    
    func removeCancel() {
        self.order?.status = Constants.ORDER_ON_THE_WAY
        if (self.isProvider() && self.user?.data?.userID == self.order?.providerID) {
            self.setupFloating()
        }else if (self.order?.status == Constants.ORDER_ON_THE_WAY) {
            self.actionButton?.removeFromSuperview()
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
        
        let item = self.driverActionButton?.addItem()
        item?.titleLabel.text = "cancel_order".localized
        item?.titleLabel.font = UIFont(name: self.getFontName(), size: 13)
        item?.imageView.image = UIImage(named: "chat_cancelorder")
        item?.buttonColor = UIColor.appLogoColor
        item?.buttonImageColor = .white
        item?.action = { item in
            
            //cancel order
            self.showAlert(title: "alert".localized, message: "confirm_cancel_delivery".localized, actionTitle: "yes".localized, cancelTitle: "no".localized, actionHandler: {
                if (self.isProvider() && self.user?.data?.userID == self.order?.providerID) {
                    self.cancelDeliveryByDriver()
                }else {
                    self.cancelDeliveryByUser()
                }
            })
            
        }
        
        let item2 = self.driverActionButton?.addItem()
        if (self.order?.status == Constants.ORDER_PROCESSING) {
            item2?.titleLabel.text = "on_my_way".localized
        }else {
            item2?.titleLabel.text = "complete_delivery".localized
        }
        
        item2?.titleLabel.font = UIFont(name: self.getFontName(), size: 13)
        item2?.imageView.image = UIImage(named: "chat_onmyway")
        item2?.buttonColor = UIColor.appLogoColor
        item2?.buttonImageColor = .white
        item2?.action = { item in
            if (self.order?.status == Constants.ORDER_PROCESSING) {
                //on my way
                if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CustomerBillVC") as? CustomerBillVC
                {
                    vc.delegate = self
                    vc.deliveryCost = self.order?.price ?? 0.0
                    self.present(vc, animated: true, completion: nil)
                }
            }else {
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
    }
    
    
    func cancelDeliveryByUser() {
        ApiService.cancelDelivery(Authorization: self.user?.data?.accessToken ?? "", deliveryId: self.order?.id ?? 0, completion: { (response) in
            if (response.errorCode == 0) {
                self.showBanner(title: "alert".localized, message: "delivery_cancelled".localized, style: UIColor.SUCCESS)
                DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                    self.goToOrders()
                })
            }else {
                self.showBanner(title: "alert".localized, message: response.errorMessage ?? "", style: UIColor.INFO)
            }
        })
    }
    
    func cancelDeliveryByDriver() {
        ApiService.cancelDeliveryByDriver(Authorization: self.user?.data?.accessToken ?? "", deliveryId: self.order?.id ?? 0, completion: { (response) in
            if (response.errorCode == 0) {
                self.showBanner(title: "alert".localized, message: "delivery_cancelled".localized, style: UIColor.SUCCESS)
                DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                    self.goToOrders()
                })
            }else {
                self.showBanner(title: "alert".localized, message: response.errorMessage ?? "", style: UIColor.INFO)
            }
        })
    }
    
    func goToOrders() {
        if (self.isProvider()) {
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WorkingOrdersNavigationController") as! UINavigationController
            self.present(vc, animated: true, completion: nil)
        }else {
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "OrdersNavigationController") as! UINavigationController
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    func setupUserFloating() {
        self.actionButton?.removeFromSuperview()
        self.actionButton = JJFloatingActionButton()
        
        
        let item = actionButton?.addItem()
        item?.titleLabel.text = "cancel_order".localized
        item?.titleLabel.font = UIFont(name: self.getFontName(), size: 13)
        item?.imageView.image = UIImage(named: "chat_cancelorder")
        item?.buttonColor = UIColor.appLogoColor
        item?.buttonImageColor = .white
        item?.action = { item in
            
            //cancel order
            self.showAlert(title: "alert".localized, message: "confirm_cancel_delivery".localized, actionTitle: "yes".localized, cancelTitle: "no".localized, actionHandler: {
                if (self.isProvider() && self.user?.data?.userID == self.order?.providerID) {
                    self.cancelDeliveryByDriver()
                }else {
                    self.cancelDeliveryByUser()
                }
            })
            
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
                
                self.order = DatumDel(id: self.order?.id ?? 0, title: self.order?.title ?? "", status: Constants.ORDER_ON_THE_WAY, statusString: self.order?.statusString ?? "", image: self.order?.image ?? "", createdDate: self.order?.createdDate ?? "", chatId: self.order?.chatId ?? 0, fromAddress: self.order?.fromAddress ?? "", fromLatitude: self.order?.fromLatitude ?? 0.0, fromLongitude: self.order?.fromLongitude ?? 0.0, toAddress: self.order?.toAddress ?? "", toLatitude: self.order?.toLatitude ?? 0.0, toLongitude: self.order?.toLongitude ?? 0.0, providerID: self.order?.providerID, providerName: self.order?.providerName ?? "", providerImage: self.order?.providerImage ?? "", providerRate: self.order?.providerRate ?? 0.0, time: self.order?.time ?? 0, price: self.order?.price ?? 0.0, serviceName: self.order?.serviceName ?? "")
                
                self.setupFloating()
            }else {
                self.showBanner(title: "alert".localized, message: response.errorMessage ?? "", style: UIColor.INFO)
            }
        }
    }
    
    
    func startNavigation(longitude : Double, latitude : Double) {
        let sourceSelector = UIAlertController(title: "continueUsing".localized, message: nil, preferredStyle: .actionSheet)
        
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
        sourceSelector.addAction(appleMapsAction)
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

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    //    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    //         let message: ZHCMessage = self.demoData.messages.object(at: indexPath.row) as! ZHCMessage;
    //        if (message.isMediaMessage) {
    //            var images = [String]()
    //            let str = message.media.mediaData?() as? String ?? ""
    //            images.append(str)
    //            if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ImageSliderVC") as? ImageSliderVC
    //            {
    //                self.navigationController?.pushViewController(vc, animated: true)
    //            }
    //        }
    //    }
    
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
            return self.demoData.outgoingBubbleImageData;
        }
        return self.demoData.incomingBubbleImageData;
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
        let cell: ZHCMessagesTableViewCell = super.tableView(tableView, cellForRowAt: indexPath) as! ZHCMessagesTableViewCell;
        self.configureCell(cell, atIndexPath: indexPath);
        return cell;
    }
    
    //MARK:Configure Cell Data
    func configureCell(_ cell: ZHCMessagesTableViewCell, atIndexPath indexPath: IndexPath) -> Void {
        let message: ZHCMessage = self.demoData.messages.object(at: indexPath.row) as! ZHCMessage;
        if !message.isMediaMessage {
            if (message.senderId == self.senderId()) {
                cell.textView?.textColor = UIColor.white;
            }else{
                cell.textView?.textColor = UIColor.black;
            }
        }
    }
    
    //MARK: Messages view controller
    
    override func didPressSend(_ button: UIButton?, withMessageText text: String, senderId: String, senderDisplayName: String, date: Date) {
        ApiService.sendChatMessage(Authorization: self.user?.data?.accessToken ?? "", chatId: self.order?.chatId ?? 0, type: 1, message: text, image: "", voice: "") { (response) in
            if (response.errorCode == 0) {
                let message: ZHCMessage = ZHCMessage.init(senderId: senderId, senderDisplayName: senderDisplayName, date: date, text: text)
                self.demoData.messages.add(message)
                self.finishSendingMessage(animated: true)
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

