//
//  DeliveryStep3.swift
//  rzq
//
//  Created by Zaid najjar on 4/2/19.
//  Copyright © 2019 technzone. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import MapKit
import CoreLocation
import Sheeeeeeeeet
import SwiftyGif
import MultilineTextField
import SVProgressHUD
import AVFoundation

protocol Step3Delegate {
    func updateModel(model : OTWOrder)
}
class DeliveryStep3: BaseVC {
    
    @IBOutlet weak var lblPickupLocation: MyUILabel!
    
    @IBOutlet weak var lblDropoffLocation: MyUILabel!
    
    @IBOutlet weak var mapView: UIView!
    
    
    
//    @IBOutlet weak var lblImages: MyUILabel!
//
//    @IBOutlet weak var viewImages: UIView!
//
//    @IBOutlet weak var viewRecording: UIView!
    
    @IBOutlet weak var btnTime: MyUIButton!
    
    
    
    //  @IBOutlet weak var ivHandle: UIImageView!
    
    
    
    @IBOutlet weak var gif: UIImageView!
    
    @IBOutlet weak var btnCost: MyUIButton!
    
    @IBOutlet weak var actionSheet: UIView!
    @IBOutlet weak var actionSheetConstraintBottom: NSLayoutConstraint!
    
    var markerLocation: GMSMarker?
    
    var currentZoom: Float = 0.0
    
    var gMap : GMSMapView?
    
    var latitude : Double?
    
    var longitude : Double?
    
    var orderModel : OTWOrder?
    
    var delegate : Step3Delegate?
           
    var selectedTime : Int?
    
    
    @IBOutlet weak var btnGender: MyUIButton!
    
    @IBOutlet weak var btnPaymentMethod: MyUIButton!
    
    var selectedRoute: NSDictionary!
    
    var selectedImages: [UIImage] = []
    

    var isAboveTen : Bool?
    var isFemale : Bool?
    var isCash : Bool = true
    
    var selectedItems = [ShopMenuItem]()
    var selectedTotal: Double?
    
        
    //hide/show
    @IBOutlet weak var viewGender: UIView!
    @IBOutlet weak var lblGender: MyUILabel!
    
        
    
    
//    init(selectedImages: [UIImage]) {
//        self.selectedImages = selectedImages
//        super.init(nibName: nil, bundle: nil)
//    }
    
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.isCash = true
        
        self.isFemale = false
        self.btnGender.setTitle("both_genders".localized, for: .normal)
        self.selectedTotal = self.orderModel?.selectedTotal
        
        SVProgressHUD.setDefaultMaskType(.clear)
        
        //        if (self.isArabic()) {
        //            self.ivHandle.image = UIImage(named: "ic_back_arabic")
        //        }
        self.btnTime.setTitle("asap".localized, for: .normal)
        // below are properties that can be optionally customized
       
        
//        let gif = UIImage(gifName: "recording.gif")
//        self.gif.setGifImage(gif)
        
        gMap = GMSMapView()
        self.setUpGoogleMap()
        
        
        self.lblPickupLocation.text = self.orderModel?.pickUpAddress ?? ""
        self.lblDropoffLocation.text = self.orderModel?.dropOffAddress ?? ""
        
        self.drawLocationLine()
        
//        self.edtOrderDetails.text = self.orderModel?.orderDetails ?? ""
//        self.edtCost.text = self.orderModel?.orderCost ?? ""
        
        if (self.orderModel?.fromReorder ?? false) {
            if (self.orderModel?.isFemale ?? false) {
                self.isFemale = true
                self.btnGender.setTitle("female_only".localized, for: .normal)
            }else {
                self.isFemale = false
                self.btnGender.setTitle("both_genders".localized, for: .normal)
            }
            if (self.orderModel?.paymentMethod == Constants.PAYMENT_METHOD_CASH) {
                self.isCash = true
                self.btnPaymentMethod.setTitle("cash".localized, for: .normal)
            }else {
                self.isCash = false
                self.btnPaymentMethod.setTitle("knet".localized, for: .normal)
            }
            if (self.orderModel?.selectedItems?.count ?? 0 > 0) {
                self.selectedItems.append(contentsOf: self.orderModel?.selectedItems ?? [ShopMenuItem]())
            }
            
            if (self.orderModel?.images?.count ?? 0 > 0) {
                
            }
            
           
            
        }
        
        if (DataManager.loadUser().data?.gender == 1) {
            self.viewGender.isHidden = true
            self.lblGender.isHidden = true
        }
        let swipeDownGesture = UISwipeGestureRecognizer(target: self, action: #selector(self.hideActionSheet))
        swipeDownGesture.direction = .down
        self.actionSheet.addGestureRecognizer(swipeDownGesture)
        
        let swipeUpGesture = UISwipeGestureRecognizer(target: self, action: #selector(self.showActionSheet))
        swipeUpGesture.direction = .up
        self.actionSheet.addGestureRecognizer(swipeUpGesture)
    }
    
    @objc func hideActionSheet() {
        self.actionSheetConstraintBottom.constant = 50 - self.actionSheet.frame.height
    }
    
    @objc func showActionSheet() {
        self.actionSheetConstraintBottom.constant = 0
    }

    
    func drawLocationLine() {
        
        let pickUpPosition = CLLocationCoordinate2D(latitude: self.orderModel?.pickUpLatitude ?? 0, longitude: self.orderModel?.pickUpLongitude ?? 0)
        let pickMarker = GMSMarker(position: pickUpPosition)
        pickMarker.title = self.orderModel?.pickUpAddress
        if (self.orderModel?.shop?.id ?? 0 > 0) {
            pickMarker.icon = UIImage(named: "ic_map_shop")
        }else {
            pickMarker.icon = UIImage(named: "ic_location_pin")
        }
        pickMarker.map = self.gMap
        
        
        let dropOffPosition = CLLocationCoordinate2D(latitude: self.orderModel?.dropOffLatitude ?? 0, longitude: self.orderModel?.dropOffLongitude ?? 0)
        let dropMarker = GMSMarker(position: dropOffPosition)
        dropMarker.title = self.orderModel?.dropOffAddress
        dropMarker.icon = UIImage(named: "ic_location")
        dropMarker.map = self.gMap
        
        var bounds = GMSCoordinateBounds()
        bounds = bounds.includingCoordinate(pickMarker.position)
        bounds = bounds.includingCoordinate(dropMarker.position)
        self.gMap?.animate(with: GMSCameraUpdate.fit(bounds, withPadding: 155.0))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //self.handleImagesView()
    }
    
    
    
    func handleRecordingView() {
        
    }
    
    func saveBackModel() {
        
        //.text ?? ""
        //  self.orderModel?.orderCost = self.edtCost.text ?? ""
        self.delegate?.updateModel(model: self.orderModel!)
        self.navigationController?.popViewController(animated: true)
    }
    
//    func selectImageFrom(_ source: ImageSource) {
//        imagePicker =  UIImagePickerController()
//        imagePicker.delegate = self
//        switch source {
//        case .camera:
//            imagePicker.sourceType = .camera
//        case .photoLibrary:
//            imagePicker.sourceType = .photoLibrary
//        }
//        present(imagePicker, animated: true, completion: nil)
//    }
    
    
    func setUpGoogleMap() {
        let camera = GMSCameraPosition.camera(withLatitude: self.latitude ?? 0.0, longitude: self.longitude ?? 0.0, zoom: 15.0)
        gMap = GMSMapView.map(withFrame: CGRect(x: 0, y: 0, width: self.mapView.frame.width, height: self.mapView.frame.height), camera: camera)
        gMap?.delegate = self
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: self.latitude ?? 0.0, longitude: self.longitude ?? 0.0)
        marker.title =  ""
        marker.snippet = ""
        marker.map = gMap
        
        self.mapView.addSubview(gMap!)
        gMap?.bindFrameToSuperviewBounds()
        self.view.layoutSubviews()
    }
    
    @IBAction func step1Action(_ sender: Any) {
        self.popBack(3)
    }
    
    @IBAction func step2Action(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func step3Action(_ sender: Any) {
        
    }
    
   
    
    func getCost() -> Double {
              if (self.isAboveTen ?? false) {
                  return 11.0
              }else {
                  return 9.0
              }
          }
       
   
    
    @IBAction func timeAction(_ sender: Any) {
        let actionSheet = createTimeSheet()
        actionSheet.appearance.title.textColor = UIColor.colorPrimary
        actionSheet.present(in: self, from: self.view)
    }
    
    @IBAction func placeOrderAction(_ sender: Any) {
        
        if (self.isCash ?? false) {
            if (self.selectedItems.count > 0) {
                self.createDeliveryWithMenu(invoiceId : "")
            }else {
                self.createDeliveryWithoutMenu(invoiceId : "")
            }
        }else {
            self.generatePaymentUrl()
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
    
    func createDeliveryWithoutMenu(invoiceId: String) {
        self.showLoading()
        var paymentMethod = Constants.PAYMENT_METHOD_KNET
        if (self.isCash ?? false) {
            paymentMethod = Constants.PAYMENT_METHOD_CASH
        }
        ApiService.createDelivery(Authorization: DataManager.loadUser().data?.accessToken ?? "",
            desc: self.orderModel?.orderDetails ?? "",
            fromLongitude: self.orderModel?.pickUpLongitude ?? 0.0, fromLatitude: self.orderModel?.pickUpLatitude ?? 0.0, toLongitude: self.orderModel?.dropOffLongitude ?? 0.0, toLatitude: self.orderModel?.dropOffLatitude ?? 0.0, time: self.selectedTime ?? 0, estimatedPrice: "\(self.getCost())", fromAddress: self.orderModel?.pickUpAddress ?? "", toAddress: self.orderModel?.dropOffAddress ?? "", shopId: self.orderModel?.shop?.id ?? 0, pickUpDetails : self.orderModel?.pickUpDetails ?? "", dropOffDetails : self.orderModel?.dropOffDetails ?? "",paymentMethod : paymentMethod, isFemale : self.isFemale ?? false, invoiceId: invoiceId) { (response) in
            if (response.data ?? 0 > 0) {
                self.handleUploadingMedia(id : response.data ?? 0)
            }else {
                self.hideLoading()
                self.showBanner(title: "alert".localized, message: response.errorMessage ?? "", style: UIColor.INFO)
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
            if (response.data ?? 0 > 0) {
                self.handleUploadingMedia(id : response.data ?? 0)
            }else {
                self.hideLoading()
                self.showBanner(title: "alert".localized, message: response.errorMessage ?? "", style: UIColor.INFO)
            }
        }
    }
    
    let recorder = KAudioRecorder.shared
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
                    let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SendingOrderVC") as! SendingOrderVC
                    //                    self.definesPresentationContext = true
                    //                    vc.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
                    //                    vc.view.backgroundColor = UIColor.clear
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true, completion: nil)
                }else {
                    self.showBanner(title: "alert".localized, message: response.errorMessage ?? "", style: UIColor.INFO)
                }
                
            }
        }else {
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SendingOrderVC") as! SendingOrderVC
            //            self.definesPresentationContext = true
            //            vc.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
            //            vc.view.backgroundColor = UIColor.clear
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true, completion: nil)
            
        }
    }
    
    func createTimeSheet() -> ActionSheet {
        let title = ActionSheetTitle(title: "choose_time".localized)
        
        let appearance = ActionSheetAppearance()
        
        appearance.title.font = UIFont(name: Constants.ARABIC_FONT_REGULAR, size: 16)
        appearance.sectionTitle.font = UIFont(name: Constants.ARABIC_FONT_REGULAR, size: 14)
        appearance.sectionTitle.subtitleFont = UIFont(name: Constants.ARABIC_FONT_REGULAR, size: 14)
        appearance.item.subtitleFont = UIFont(name: Constants.ARABIC_FONT_REGULAR, size: 14)
        appearance.item.font = UIFont(name: Constants.ARABIC_FONT_REGULAR, size: 14)
        
        let item0 = ActionSheetItem(title: "asap".localized, value: 0, image: nil)
        let item1 = ActionSheetItem(title: "1_hour".localized, value: 1, image: nil)
        let item2 = ActionSheetItem(title: "2_hour".localized, value: 2, image: nil)
        let item3 = ActionSheetItem(title: "3_hour".localized, value: 3, image: nil)
        
        let item4 = ActionSheetItem(title: "1_day".localized, value: 4, image: nil)
        let item5 = ActionSheetItem(title: "2_day".localized, value: 5, image: nil)
        let item6 = ActionSheetItem(title: "3_day".localized, value: 6, image: nil)
        
        let actionSheet = ActionSheet(items: [title,item0,item1,item2,item3,item4,item5,item6]) { sheet, item in
            if let value = item.value as? Int {
                switch (value) {
                case 0:
                    //1 hour
                    self.btnTime.setTitle("asap".localized, for: .normal)
                    self.selectedTime = 0
                    break
                case 1:
                    //1 hour
                    self.btnTime.setTitle("1_hour".localized, for: .normal)
                    self.selectedTime = 1
                    break
                case 2:
                    //2 hour
                    self.btnTime.setTitle("2_hour".localized, for: .normal)
                    self.selectedTime = 2
                    break
                case 3:
                    //3 hour
                    self.btnTime.setTitle("3_hour".localized, for: .normal)
                    self.selectedTime = 3
                    break
                case 4:
                    //1 day
                    self.btnTime.setTitle("1_day".localized, for: .normal)
                    self.selectedTime = 24
                    break
                case 5:
                    //1 day
                    self.btnTime.setTitle("2_day".localized, for: .normal)
                    self.selectedTime = 48
                    break
                case 6:
                    //1 day
                    self.btnTime.setTitle("3_day".localized, for: .normal)
                    self.selectedTime = 72
                    break
                default:
                    print("1")
                    break
                }
            }
            if item is ActionSheetOkButton {
                print("OK buttons has the value `true`")
            }
        }
        actionSheet.appearance = appearance
        actionSheet.title = "select_an_option".localized
        
        return actionSheet
    }
    
    
    
    
    func createCostSheet() -> ActionSheet {
        let title = ActionSheetTitle(title: "select_cost_range".localized)
        
        let appearance = ActionSheetAppearance()
        
        appearance.title.font = UIFont(name: Constants.ARABIC_FONT_REGULAR, size: 16)
        appearance.sectionTitle.font = UIFont(name: Constants.ARABIC_FONT_REGULAR, size: 14)
        appearance.sectionTitle.subtitleFont = UIFont(name: Constants.ARABIC_FONT_REGULAR, size: 14)
        appearance.item.subtitleFont = UIFont(name: Constants.ARABIC_FONT_REGULAR, size: 14)
        appearance.item.font = UIFont(name: Constants.ARABIC_FONT_REGULAR, size: 14)
        
        let item0 = ActionSheetItem(title: "below_ten_kd".localized, value: 0, image: nil)
        let item1 = ActionSheetItem(title: "above_ten_kd".localized, value: 1, image: nil)
        
        let actionSheet = ActionSheet(items: [title,item0,item1]) { sheet, item in
            if let value = item.value as? Int {
                switch (value) {
                case 0:
                    //below
                    self.btnCost.setTitle("below_ten_kd".localized, for: .normal)
                    self.isAboveTen = false
                    break
                case 1:
                    //above
                    self.btnCost.setTitle("above_ten_kd".localized, for: .normal)
                    self.isAboveTen = true
                    break
                default:
                    print("1")
                    break
                }
            }
            if item is ActionSheetOkButton {
                print("OK buttons has the value `true`")
            }
        }
        actionSheet.appearance = appearance
        actionSheet.title = "select_an_option".localized
        
        return actionSheet
    }
    
    
    func createGenderSheet() -> ActionSheet {
        let title = ActionSheetTitle(title: "select_driver_gender".localized)
        
        let appearance = ActionSheetAppearance()
        
        appearance.title.font = UIFont(name: Constants.ARABIC_FONT_REGULAR, size: 16)
        appearance.sectionTitle.font = UIFont(name: Constants.ARABIC_FONT_REGULAR, size: 14)
        appearance.sectionTitle.subtitleFont = UIFont(name: Constants.ARABIC_FONT_REGULAR, size: 14)
        appearance.item.subtitleFont = UIFont(name: Constants.ARABIC_FONT_REGULAR, size: 14)
        appearance.item.font = UIFont(name: Constants.ARABIC_FONT_REGULAR, size: 14)
        
        let item0 = ActionSheetItem(title: "both_genders".localized, value: 0, image: nil)
        let item1 = ActionSheetItem(title: "female_only".localized, value: 1, image: nil)
        
        let actionSheet = ActionSheet(items: [title,item0,item1]) { sheet, item in
            if let value = item.value as? Int {
                switch (value) {
                case 0:
                    //below
                    self.btnGender.setTitle("both_genders".localized, for: .normal)
                    self.isFemale = false
                    break
                case 1:
                    //above
                    self.btnGender.setTitle("female_only".localized, for: .normal)
                    self.isFemale = true
                    break
                default:
                    print("1")
                    break
                }
            }
            if item is ActionSheetOkButton {
                print("OK buttons has the value `true`")
            }
        }
        
        actionSheet.appearance = appearance
        actionSheet.title = "select_an_option".localized
        
        return actionSheet
    }
    
    func createPaymentSheet() -> ActionSheet {
        let title = ActionSheetTitle(title: "select_payment_method".localized)
        
        let appearance = ActionSheetAppearance()
        
        appearance.title.font = UIFont(name: Constants.ARABIC_FONT_REGULAR, size: 16)
        appearance.sectionTitle.font = UIFont(name: Constants.ARABIC_FONT_REGULAR, size: 14)
        appearance.sectionTitle.subtitleFont = UIFont(name: Constants.ARABIC_FONT_REGULAR, size: 14)
        appearance.item.subtitleFont = UIFont(name: Constants.ARABIC_FONT_REGULAR, size: 14)
        appearance.item.font = UIFont(name: Constants.ARABIC_FONT_REGULAR, size: 14)
        
        let item0 = ActionSheetItem(title: "cash".localized, value: 0, image: nil)
        let item1 = ActionSheetItem(title: "knet".localized, value: 1, image: nil)
        
        let actionSheet = ActionSheet(items: [title,item0, item1]) { sheet, item in
           //   let actionSheet = ActionSheet(items: [title,item0]) { sheet, item in
            if let value = item.value as? Int {
                switch (value) {
                case 0:
                    //below
                    self.btnPaymentMethod.setTitle("cash".localized, for: .normal)
                    self.isCash = true
                    break
                case 1:
                    //above
                    self.btnPaymentMethod.setTitle("knet".localized, for: .normal)
                    self.isCash = false
                    break
                default:
                    print("1")
                    break
                }
            }
            if item is ActionSheetOkButton {
                print("OK buttons has the value `true`")
            }
        }
        actionSheet.appearance = appearance
        actionSheet.title = "select_an_option".localized
        
        return actionSheet
    }
    
    
    


    @IBAction func backBtnAction(_ sender: Any) {
        self.saveBackModel()
    }
    
    @IBAction func costAction(_ sender: Any) {
        let actionSheet = createCostSheet()
        actionSheet.appearance.title.textColor = UIColor.colorPrimary
        actionSheet.present(in: self, from: self.view)
    }
    
   
    
    @IBAction func GenderAction(_ sender: Any) {
        let actionSheet = createGenderSheet()
        actionSheet.appearance.title.textColor = UIColor.colorPrimary
        actionSheet.present(in: self, from: self.view)
    }
    
    @IBAction func paymentMethodAction(_ sender: Any) {
        let actionSheet = createPaymentSheet()
        actionSheet.appearance.title.textColor = UIColor.colorPrimary
        actionSheet.present(in: self, from: self.view)
    }
    
}
extension DeliveryStep3 : GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        
    }
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        
    }
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        //        let id = marker.title ?? "0"
        //        getshopinfo
        return true
    }
}

