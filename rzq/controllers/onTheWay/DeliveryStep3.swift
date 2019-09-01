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

protocol Step3Delegate {
    func updateModel(model : OTWOrder)
}
class DeliveryStep3: BaseVC, UINavigationControllerDelegate, ImagePickerDelegate {

    @IBOutlet weak var lblPickupLocation: MyUILabel!
    
    @IBOutlet weak var lblDropoffLocation: MyUILabel!
    
    @IBOutlet weak var mapView: UIView!
    
    
    @IBOutlet weak var lblImages: MyUILabel!
    
    @IBOutlet weak var viewImages: UIView!
    
    @IBOutlet weak var viewRecording: UIView!
    
    @IBOutlet weak var btnTime: MyUIButton!
    
    @IBOutlet weak var bgRecord: UIImageView!
    
    @IBOutlet weak var ivHandle: UIImageView!
    
    @IBOutlet weak var edtOrderDetails: MultilineTextField!
    
    @IBOutlet weak var gif: UIImageView!
    
    @IBOutlet weak var btnCost: MyUIButton!
    
    var markerLocation: GMSMarker?
    
    var currentZoom: Float = 0.0
    
    var gMap : GMSMapView?
    
    var latitude : Double?
    
    var longitude : Double?
    
    var orderModel : OTWOrder?
    
    var delegate : Step3Delegate?

    @IBOutlet weak var btnRecord: UIButton!
    
    @IBOutlet weak var btnPlay: UIButton!
    
    var selectedTime : Int?
    
    
    
    var selectedRoute: NSDictionary!
    
    var selectedImages = [UIImage]()
    
    var imagePicker: UIImagePickerController!
    
    var isAboveTen : Bool?
    
    enum ImageSource {
        case photoLibrary
        case camera
    }
    
    var recorder = KAudioRecorder.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (self.isArabic()) {
            self.ivHandle.image = UIImage(named: "ic_back_arabic")
        }
        self.btnTime.setTitle("asap".localized, for: .normal)
        // below are properties that can be optionally customized
        edtOrderDetails.placeholder = "order_details".localized
        edtOrderDetails.placeholderColor = UIColor.lightGray
        edtOrderDetails.isPlaceholderScrollEnabled = true
        
        let gif = UIImage(gifName: "recording.gif")
        self.gif.setGifImage(gif)
        
        gMap = GMSMapView()
        self.setUpGoogleMap()
        self.viewRecording.isHidden = true
        
        self.lblPickupLocation.text = self.orderModel?.pickUpAddress ?? ""
        self.lblDropoffLocation.text = self.orderModel?.dropOffAddress ?? ""
        
        self.drawLocationLine()
        
        self.edtOrderDetails.text = self.orderModel?.orderDetails ?? ""
      //  self.edtCost.text = self.orderModel?.orderCost ?? ""
        
    }
    
    func drawLocationLine() {
        let origin = "\(self.orderModel?.pickUpLatitude ?? 0),\(self.orderModel?.pickUpLongitude ?? 0)"
        let destination = "\(self.orderModel?.dropOffLatitude ?? 0),\(self.orderModel?.dropOffLongitude ?? 0)"
        
        let urlString = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(destination)&mode=driving&key=\(Constants.GOOGLE_API_KEY)"
        
        let url = URL(string: urlString)
        URLSession.shared.dataTask(with: url!, completionHandler: {
            (data, response, error) in
            if(error != nil){
                print("error")
            } else {
                do{
                    let json = try JSONSerialization.jsonObject(with: data!, options:.allowFragments) as! [String : AnyObject]
                    if let routes = json["routes"] as? NSArray {
                        if (routes.count > 0) {
                            self.gMap?.clear()
                            
                            self.selectedRoute = (json["routes"] as! Array<NSDictionary>)[0]
                            //  self.loadDistanceAndDuration()
                            
                            OperationQueue.main.addOperation({
                                for route in routes
                                {
                                    let routeOverviewPolyline:NSDictionary = (route as! NSDictionary).value(forKey: "overview_polyline") as! NSDictionary
                                    let points = routeOverviewPolyline.object(forKey: "points")
                                    let path = GMSPath.init(fromEncodedPath: points! as! String)
                                    let polyline = GMSPolyline.init(path: path)
                                    polyline.strokeWidth = 2
                                    polyline.strokeColor = UIColor.appDarkBlue
                                    
                                    let bounds = GMSCoordinateBounds(path: path!)
                                    self.gMap?.animate(with: GMSCameraUpdate.fit(bounds, withPadding: 30.0))
                                    
                                    polyline.map = self.gMap
                                    
                                    
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
                                    
                                }
                            })
                        }else {
                            //no routes
                        }
                        
                    }else {
                        //no routes
                    }
                    
                }catch let error as NSError{
                    print("error:\(error)")
                }
            }
        }).resume()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.handleImagesView()
    }
    
    func handleImagesView() {
        if (self.selectedImages.count > 0) {
           // self.viewImages.isHidden = false
            self.lblImages.text = "\(self.selectedImages.count) \("images".localized)"
        }else {
           // self.viewImages.isHidden = true
            self.lblImages.text = ""
        }
    }
    
    func handleRecordingView() {
        
    }
    
    func saveBackModel() {
        self.orderModel?.orderDetails = self.edtOrderDetails.text ?? ""
      //  self.orderModel?.orderCost = self.edtCost.text ?? ""
        self.delegate?.updateModel(model: self.orderModel!)
        self.navigationController?.popViewController(animated: true)
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
    
    @IBAction func backAction(_ sender: Any) {
     self.saveBackModel()
    }
    
    @IBAction func step1Action(_ sender: Any) {
       //  self.popBack(3)
    }
    
    @IBAction func step2Action(_ sender: Any) {
       // self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func step3Action(_ sender: Any) {
       
    }
    
    @IBAction func photoAction(_ sender: Any) {
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
    
    @IBAction func recordPress(_ sender: Any) {
        if (recorder.isRecording) {
            //stop
            self.bgRecord.isHidden = true
            self.btnRecord.setImage(UIImage(named: "ic_microphone"), for: .normal)
            self.gif.isHidden = true
            recorder.stop()
            if (recorder.time > 1) {
                self.viewRecording.isHidden = false
            }else {
                self.viewRecording.isHidden = true
            }
        }else {
            //record
            self.bgRecord.isHidden = false
            self.btnRecord.setImage(UIImage(named: "ic_recording"), for: .normal)
            self.gif.isHidden = false
            recorder.recordName = "order_file"
            recorder.record()
        }
    }
    @IBAction func recordAction(_ sender: Any) {
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
        self.bgRecord.isHidden = true
        self.btnRecord.setImage(UIImage(named: "ic_microphone"), for: .normal)
        self.gif.isHidden = true
        recorder.stop()
        if (recorder.time > 1) {
            self.viewRecording.isHidden = false
        }else {
            self.viewRecording.isHidden = true
        }
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
        if (self.validate()) {
            ApiService.createDelivery(Authorization: self.loadUser().data?.accessToken ?? "", desc: self.edtOrderDetails.text ?? "", fromLongitude: self.orderModel?.pickUpLongitude ?? 0.0, fromLatitude: self.orderModel?.pickUpLatitude ?? 0.0, toLongitude: self.orderModel?.dropOffLongitude ?? 0.0, toLatitude: self.orderModel?.dropOffLatitude ?? 0.0, time: self.selectedTime ?? 0, estimatedPrice: "\(self.getCost())", fromAddress: self.orderModel?.pickUpAddress ?? "", toAddress: self.orderModel?.dropOffAddress ?? "", shopId: self.orderModel?.shop?.id ?? 0, pickUpDetails : self.orderModel?.pickUpDetails ?? "", dropOffDetails : self.orderModel?.dropOffDetails ?? "") { (response) in
                if (response.data ?? 0 > 0) {
                    self.handleUploadingMedia(id : response.data ?? 0)
                }else {
                    self.showBanner(title: "alert".localized, message: response.errorMessage ?? "", style: UIColor.INFO)
                }
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
            ApiService.uploadMedia(Authorization: self.loadUser().data?.accessToken ?? "", deliveryId: id, imagesData: imagesData, audioData: audioData!) { (response) in
                self.hideLoading()
                if (response.errorCode == 0) {
                    let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SendingOrderVC") as! SendingOrderVC
//                    self.definesPresentationContext = true
//                    vc.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
//                    vc.view.backgroundColor = UIColor.clear
                    
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
    
    
    func validate() -> Bool {
        if (self.edtOrderDetails.text?.count ?? 0 == 0) {
            self.showBanner(title: "alert".localized, message: "enter_order_details".localized, style: UIColor.INFO)
            return false
        }
        
//        if (self.edtCost.text?.count ?? 0 == 0) {
//            self.showBanner(title: "alert".localized, message: "enter_order_cost".localized, style: UIColor.INFO)
//            return false
//        }
        
        return true
    }
    
    @IBAction func openDialogPhotos(_ sender: Any) {
        if (self.selectedImages.count > 0) {
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ImagePickerDialog") as! ImagePickerDialog
            vc.selectedImages = self.selectedImages
            self.definesPresentationContext = true
            vc.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
            vc.view.backgroundColor = UIColor.clear
            vc.delegate = self
            
            self.present(vc, animated: true, completion: nil)
        }else {
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
    }
    
    func onDone(images: [UIImage]) {
        self.selectedImages = images
        self.handleImagesView()
    }
    
    @IBAction func playRecordAction(_ sender: Any) {
        if (recorder.isPlaying) {
            self.btnPlay.setImage(UIImage(named: "ic_play_record"), for: .normal)
            recorder.stopPlaying()
        }else {
            self.btnPlay.setImage(UIImage(named: "ic_pause"), for: .normal)
            recorder.play(name:"order_file")
        }
    }
    
    @IBAction func deleteRecordAction(_ sender: Any) {
        recorder.delete(name: "order_file")
        self.btnRecord.setImage(UIImage(named: "ic_microphone"), for: .normal)
        self.gif.isHidden = true
        self.viewRecording.isHidden = true
        
    }
    
    @IBAction func backBtnAction(_ sender: Any) {
      self.saveBackModel()
    }
    
    @IBAction func costAction(_ sender: Any) {
        let actionSheet = createCostSheet()
        actionSheet.appearance.title.textColor = UIColor.colorPrimary
        actionSheet.present(in: self, from: self.view)
    }
    
    @IBAction func clearFieldAction(_ sender: Any) {
        self.edtOrderDetails.text = ""
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
extension DeliveryStep3: UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
        imagePicker.dismiss(animated: true, completion: nil)
        guard let selectedImage = info[.originalImage] as? UIImage else {
            print("Image not found!")
            return
        }
        self.selectedImages.append(selectedImage)
        self.handleImagesView()
    }
}
