//
//  TakeOrderVC.swift
//  rzq
//
//  Created by Zaid najjar on 4/3/19.
//  Copyright © 2019 technzone. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import MapKit
import CoreLocation
import Sheeeeeeeeet
import MultilineTextField
import AVFoundation

class TakeOrderVC: BaseVC, AVAudioPlayerDelegate {
    
    @IBOutlet weak var mapView: UIView!
    
    @IBOutlet weak var lblDriverShopDistance: MyUILabel!
    
    @IBOutlet weak var lblShopClientDistance: MyUILabel!
    
    @IBOutlet weak var lblPickuplocation: MyUILabel!
    
    @IBOutlet weak var lblClientsName: MyUILabel!
    
    @IBOutlet weak var lblDropoffLocation: MyUILabel!
    
    @IBOutlet weak var lblOrderDescription: MultilineTextField!
    
    @IBOutlet weak var btnTime: MyUIButton!
    
    @IBOutlet weak var ivHandle: UIImageView!
    
    @IBOutlet weak var lblPaymentMethod: MyUILabel!
    
    @IBOutlet weak var btnPlay: UIButton!
    @IBOutlet weak var btnImages: UIButton!
    
    
    @IBOutlet weak var lblMin: UILabel!
    @IBOutlet weak var lblMax: UILabel!
    @IBOutlet weak var btnMinus: UIButton!
    @IBOutlet weak var btnPlus: UIButton!
    @IBOutlet weak var lblValue: MyUILabel!
    
    var images = [String]()
    var voiceRecord : String?
    
    var selectedTime : Int?
    
    var markerLocation: GMSMarker?
    var currentZoom: Float = 0.0
    var gMap : GMSMapView?
    
    var latitude : Double?
    var longitude : Double?
    
    var pinMarker : GMSMarker?
    
    var deliveryId : Int?
    var fromLatitude : Double?
    var fromLongitude : Double?
    var toLatitude : Double?
    var toLongitude : Double?
    var fromAddress : String?
    var toAddress : String?
    var clientsName : String?
    var desc : String?
    
    var minValue : Double = 0.0
    var maxValue : Double = 0.0
    
    var player : AVPlayer?
    
    var selectedRoute: NSDictionary!
    
    var audioPlayer: AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (self.isArabic()) {
            self.ivHandle.image = UIImage(named: "ic_back_arabic")
        }
        if (self.latitude == nil || self.latitude == 0.0) {
            self.latitude = UserDefaults.standard.value(forKey: Constants.LAST_LATITUDE) as? Double ?? 0.0
        }
        if (self.longitude == nil || self.longitude == 0.0) {
            self.longitude = UserDefaults.standard.value(forKey: Constants.LAST_LONGITUDE) as? Double ?? 0.0
        }
        gMap = GMSMapView()
        self.setUpGoogleMap()
        
        self.lblDriverShopDistance.text = self.getDriverShopDistance()
        self.lblShopClientDistance.text = self.getShopClientDistance()
        
        self.lblPickuplocation.text = self.fromAddress ?? ""
        self.lblDropoffLocation.text = self.toAddress ?? ""
        self.lblClientsName.text = self.clientsName ?? ""
        
        self.lblOrderDescription.text = self.desc ?? ""
        // Do any additional setup after loading the view.
        
        lblOrderDescription.placeholder = ""
        lblOrderDescription.placeholderColor = UIColor.black
        lblOrderDescription.isPlaceholderScrollEnabled = true
        
        let driverLatLng = CLLocation(latitude: self.latitude ?? 0.0, longitude: self.longitude ?? 0.0)
        let dropOffLatLng = CLLocation(latitude: self.fromLatitude ?? 0.0, longitude: self.fromLongitude ?? 0.0)
        let distanceInMeters = dropOffLatLng.distance(from: driverLatLng)
        let distanceInKM = distanceInMeters / 1000.0
        
        if (distanceInKM > 1.0) {
            self.minValue = App.shared.config?.configSettings?.minimumFiveKMValue ?? 0.0
        }else {
            self.minValue = App.shared.config?.configSettings?.minimumOneKMValue ?? 0.0
        }
        self.maxValue = App.shared.config?.configSettings?.maximumValue ?? 0.0
        self.lblMin.text = "\(self.minValue)"
        self.lblMax.text = "\(App.shared.config?.configSettings?.maximumValue ?? 0.0)"
        self.lblValue.text = "\(self.minValue)"
        
        ApiService.getDelivery(id: self.deliveryId ?? 0) { (response) in
            if (response.data?.images?.count ?? 0 > 0) {
                self.images.append(contentsOf: response.data?.images ?? [String]())
                self.btnImages.isHidden = false
            }else {
                self.btnImages.isHidden = true
            }
            if (response.data?.voiceFile?.count ?? 0 > 0) {
                self.voiceRecord = response.data?.voiceFile ?? ""
                self.btnPlay.isHidden = false
            }else {
                self.btnPlay.isHidden = true
            }
            
            self.lblPaymentMethod.text = self.getPaymentMethod(method: response.data?.paymentMethod ?? Constants.PAYMENT_METHOD_CASH)
            
            
        }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
        }
        catch {
            print("Setting category to AVAudioSessionCategoryPlayback failed.")
        }
        
        
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
    
    func setUpGoogleMap() {
        let camera = GMSCameraPosition.camera(withLatitude: self.fromLatitude ?? 0.0, longitude: self.fromLongitude ?? 0.0, zoom: 15.0)
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
        
        self.drawLocationLine()
        self.drawShopDestinationLine()
        
    }
    
    
    func getDriverShopDistance() -> String {
        let driverLatLng = CLLocation(latitude: self.latitude ?? 0.0, longitude: self.longitude ?? 0.0)
        let dropOffLatLng = CLLocation(latitude: self.fromLatitude ?? 0.0, longitude: self.fromLongitude ?? 0.0)
        let distanceInMeters = dropOffLatLng.distance(from: driverLatLng)
        let distanceInKM = distanceInMeters / 1000.0
        let distanceStr = String(format: "%.2f", distanceInKM)
        return "\(distanceStr) \("km".localized)"
    }
    
    
    func getShopClientDistance() -> String {
        let driverLatLng = CLLocation(latitude: self.fromLatitude ?? 0.0, longitude: self.fromLongitude ?? 0.0)
        let dropOffLatLng = CLLocation(latitude: self.toLatitude ?? 0.0, longitude: self.toLongitude ?? 0.0)
        let distanceInMeters = dropOffLatLng.distance(from: driverLatLng)
        let distanceInKM = distanceInMeters / 1000.0
        let distanceStr = String(format: "%.2f", distanceInKM)
        return "\(distanceStr) \("km".localized)"
    }
    
    
    func playRecord(path : URL) {
        
        do {
            self.audioPlayer?.pause()
            self.audioPlayer = try AVAudioPlayer(contentsOf: path)
            self.audioPlayer?.delegate = self as AVAudioPlayerDelegate
            self.audioPlayer?.rate = 1.0
            self.audioPlayer?.volume = 1.0
            self.audioPlayer?.play()
            
        } catch {
            print("play(with name:), ",error.localizedDescription)
        }
        
        //        let playerItem:AVPlayerItem = AVPlayerItem(url: path)
        //       // let audioPlayer = AVPlayer(playerItem: playerItem)
        //        self.audioPlayer = try AVPlayer(playerItem: playerItem)
        //        self.audioPlayer.volume = 1.0
        //        self.audioPlayer.rate = 1.0
        //        self.audioPlayer.isMuted = false
        //        self.audioPlayer.play()
    }
    
    func downloadFileFromURL(urlContent:URL){
        
        var downloadTask:URLSessionDownloadTask
        downloadTask = URLSession.shared.downloadTask(with: urlContent, completionHandler: { (url, response, error) in
            // self.play(url: url!)
            self.playRecord(path: url!)
        })
        
        downloadTask.resume()
        
    }
    
    func play(url:URL) {
        print("playing \(url)")
        DispatchQueue.main.async {
            self.btnPlay.setImage(UIImage(named: "ic_order_pause"), for: .normal)
        }
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.delegate = self
            player.prepareToPlay()
            player.volume = 1.0
            player.play()
        } catch let error as NSError {
            //self.player = nil
            print(error.localizedDescription)
        } catch {
            print("AVAudioPlayer init failed")
        }
        
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        DispatchQueue.main.async {
            self.btnPlay.setImage(UIImage(named: "ic_order_play"), for: .normal)
        }
    }
    
    func drawLocationLine() {
        let origin = "\(self.latitude ?? 0),\(self.longitude ?? 0)"
        let destination = "\(self.fromLatitude ?? 0),\(self.fromLongitude ?? 0)"
        
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
                            // self.gMap?.clear()
                            
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
                                    
                                    
                                    let driverPosition = CLLocationCoordinate2D(latitude: self.latitude ?? 0, longitude: self.longitude ?? 0)
                                    let driverMarker = GMSMarker(position: driverPosition)
                                    driverMarker.title = ""
                                    driverMarker.icon = UIImage(named: "ic_map2_driver")
                                    driverMarker.map = self.gMap
                                    
                                    
                                    let pickUpPosition = CLLocationCoordinate2D(latitude: self.fromLatitude ?? 0, longitude: self.fromLongitude ?? 0)
                                    let pickMarker = GMSMarker(position: pickUpPosition)
                                    pickMarker.title = ""
                                    pickMarker.icon = UIImage(named: "ic_map2_shop")
                                    pickMarker.map = self.gMap
                                    
                                    
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
    
    
    
    
    func drawShopDestinationLine() {
        let origin = "\(self.fromLatitude ?? 0),\(self.fromLongitude ?? 0)"
        let destination = "\(self.toLatitude ?? 0),\(self.toLongitude ?? 0)"
        
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
                            // self.gMap?.clear()
                            
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
                                    
                                    
                                    let pickUpPosition = CLLocationCoordinate2D(latitude: self.fromLatitude ?? 0, longitude: self.fromLongitude ?? 0)
                                    let pickMarker = GMSMarker(position: pickUpPosition)
                                    pickMarker.title = ""
                                    pickMarker.icon = UIImage(named: "ic_map2_shop")
                                    pickMarker.map = self.gMap
                                    
                                    
                                    
                                    let dropOffPosition = CLLocationCoordinate2D(latitude: self.toLatitude ?? 0, longitude: self.toLongitude ?? 0)
                                    let dropMarker = GMSMarker(position: dropOffPosition)
                                    dropMarker.title = ""
                                    dropMarker.icon = UIImage(named: "ic_map2_client")
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
    
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func timeAction(_ sender: Any) {
        let actionSheet = createTimeSheet()
        actionSheet.appearance.title.textColor = UIColor.colorPrimary
        actionSheet.present(in: self, from: self.view)
    }
    
    @IBAction func sendAction(_ sender: Any) {
        if (self.validate()) {
            self.showLoading()
            ApiService.createBid(Authorization: self.loadUser().data?.accessToken ?? "", deliveryId: self.deliveryId ?? 0, time: self.selectedTime ?? 1, price: self.lblValue.text ?? "", longitude: self.longitude ?? 0.0, latitude: self.latitude ?? 0.0) { (response) in
                self.hideLoading()
                if (response.errorCode == 0) {
                    self.showBanner(title: "alert".localized, message: "bid_sent_to_user".localized, style: UIColor.SUCCESS)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                        self.navigationController?.popViewController(animated: true)
                    })
                }else {
                    self.showBanner(title: "alert".localized, message: response.errorMessage ?? "", style: UIColor.INFO)
                }
            }
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
                    //asap
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
    
    
    func validate() -> Bool {
        //        if (self.edtCost.text?.count ?? 0 == 0) {
        //            self.showBanner(title: "alert".localized, message: "enter_order_cost".localized, style: UIColor.INFO)
        //            return false
        //        }
        return true
    }
    
    @IBAction func playAction(_ sender: Any) {
        let urlz = URL(string: "\(Constants.IMAGE_URL)\(self.voiceRecord ?? "")")
        
        self.downloadFileFromURL(urlContent: urlz!)
        
        //  self.playRecord(path: urlz!)
        
    }
    
    @IBAction func openImagesAction(_ sender: Any) {
        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ImageSliderVC") as? ImageSliderVC
        {
            vc.orderImages = self.images
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func minusAction(_ sender: Any) {
        let incrementValue = App.shared.config?.configSettings?.incrementValue ?? 0.0
        let lblMinValue : Double = Double(self.lblValue.text ?? "")!
        if (lblMinValue <= self.minValue) {
            self.lblValue.text = "\(self.minValue)"
        }else {
            self.lblValue.text = "\(lblMinValue - incrementValue)"
        }
    }
    
    @IBAction func plusAction(_ sender: Any) {
        let incrementValue = App.shared.config?.configSettings?.incrementValue ?? 0.0
        let lblMaxValue : Double = Double(self.lblValue.text ?? "")!
        if (lblMaxValue >= self.maxValue) {
            self.lblValue.text = "\(self.maxValue)"
        }else {
            self.lblValue.text = "\(lblMaxValue + incrementValue)"
        }
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        let x = error?.localizedDescription ?? ""
    }
    
    
}
extension TakeOrderVC : GMSMapViewDelegate {
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
