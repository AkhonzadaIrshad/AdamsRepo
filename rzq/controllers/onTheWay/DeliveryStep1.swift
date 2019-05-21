//
//  DeliveryStep1.swift
//  rzq
//
//  Created by Zaid najjar on 4/1/19.
//  Copyright © 2019 technzone. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import MapKit
import CoreLocation
import Firebase
import AMPopTip

class DeliveryStep1: BaseVC,LabasLocationManagerDelegate, Step2Delegate {
    
    @IBOutlet weak var lblPickupLocation: MyUILabel!
    
    @IBOutlet weak var mapView: UIView!
    
    @IBOutlet weak var edtMoreDetails: MyUITextField!
    
    @IBOutlet weak var searchField: SearchTextField!
    
    @IBOutlet weak var ivHandle: UIImageView!
    
    @IBOutlet weak var ivShop: CircleImage!
    @IBOutlet weak var viewShopDetails: CardView!
    
    @IBOutlet weak var viewSuggest: UIView!
    @IBOutlet weak var viewPin: UIView!
    @IBOutlet weak var lblShopName: MyUILabel!
    @IBOutlet weak var shopNameHeight: NSLayoutConstraint!
    
    @IBOutlet weak var btnCurrentLocation: UIButton!
    
    var markerLocation: GMSMarker?
    var currentZoom: Float = 0.0
    var gMap : GMSMapView?
    
    var fromHome : Bool?
    
    var latitude : Double?
    var longitude : Double?
    
    var pinLatitude : Double?
    var pinLongitude : Double?
    
    var pinMarker : GMSMarker?
    var singleMarker : GMSMarker?
    
    var selectedLocation : CLLocation?
    
    var orderModel : OTWOrder?
    
    var toolTipView : ToolTipView?
    
    var shops = [DataShop]()
    var filterShops = [DataShop]()
    var shopMarkers = [GMSMarker]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (self.isArabic()) {
            self.ivHandle.image = UIImage(named: "ic_back_arabic")
        }
        if (self.orderModel == nil) {
            self.orderModel = OTWOrder()
        }
        gMap = GMSMapView()
        self.searchField.delegate = self
        
        if (self.latitude ?? 0.0 == 0.0 || self.longitude ?? 0.0 == 0.0) {
            self.showLoading()
            LabasLocationManager.shared.delegate = self
            LabasLocationManager.shared.startUpdatingLocation()
        }else {
            self.setUpGoogleMap()
        }
        
        
        if (self.orderModel?.shop?.id ?? 0 > 0) {
            self.lblPickupLocation.text = self.orderModel?.pickUpAddress ?? ""
            self.lblPickupLocation.textColor = UIColor.appDarkBlue
            //  self.edtMoreDetails.text = self.orderModel?.pickUpAddress ?? ""
            
            self.pinMarker?.map = nil
            self.pinMarker = GMSMarker()
            self.pinMarker?.position = CLLocationCoordinate2D(latitude: self.orderModel?.pickUpLatitude ?? 0.0, longitude: self.orderModel?.pickUpLongitude ?? 0.0)
            self.pinMarker?.title =  "\(self.orderModel?.shop?.id ?? 0)"
            self.pinMarker?.icon = UIImage(named: "ic_map_shop")
            self.pinMarker?.snippet = ""
            self.pinMarker?.map = gMap
            
            let camera = GMSCameraPosition.camera(withLatitude: self.orderModel?.pickUpLatitude ?? 0.0, longitude: self.orderModel?.pickUpLongitude ?? 0.0, zoom: 15.0)
            self.gMap?.animate(to: camera)
            
            
            self.ivShop.isHidden = false
            self.viewShopDetails.isHidden = false
            let url = URL(string: "\(Constants.IMAGE_URL)\(self.orderModel?.shop?.image ?? "")")
            self.ivShop.kf.setImage(with: url)
            self.edtMoreDetails.text = "\(self.orderModel?.shop?.name ?? "")\n\(self.orderModel?.shop?.address ?? "")"
            
            
            self.lblShopName.text = self.orderModel?.shop?.name ?? ""
            self.shopNameHeight.constant = 20
            self.viewPin.isHidden = false
            self.viewSuggest.isHidden = true
            
        }
        
        ApiService.updateRegId(Authorization: self.loadUser().data?.accessToken ?? "", regId: Messaging.messaging().fcmToken ?? "not_avaliable") { (response) in
            
            
        }
        
        let popTip = PopTip()
        popTip.bubbleColor = UIColor.processing
        popTip.textColor = UIColor.white
        if (self.isArabic()) {
            popTip.show(text: "current_location_desc".localized, direction: .right, maxWidth: 200, in: self.view, from: self.btnCurrentLocation.frame)
        }else {
            popTip.show(text: "current_location_desc".localized, direction: .left, maxWidth: 200, in: self.view, from: self.btnCurrentLocation.frame)
        }
      
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            popTip.hide()
        }
        
    }
    
    @IBAction func myLocationAction(_ sender: Any) {
        let camera = GMSCameraPosition.camera(withLatitude: self.latitude ?? 0.0, longitude: self.longitude ?? 0.0, zoom: 20.0)
        self.gMap?.animate(to: camera)
    }
    
    @IBAction func shopDetailsAction(_ sender: Any) {
        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ShopDetailsVC") as? ShopDetailsVC
        {
            vc.latitude = self.latitude ?? 0.0
            vc.longitude = self.longitude ?? 0.0
            
            let shopData = ShopData(nearbyDriversCount: 0, id: self.orderModel?.shop?.id ?? 0, name: self.orderModel?.shop?.name ?? "", address: self.orderModel?.shop?.address ?? "", latitude: self.orderModel?.shop?.latitude ?? 0.0, longitude: self.orderModel?.shop?.longitude ?? 0.0, phoneNumber: self.orderModel?.shop?.phoneNumber ?? "", workingHours: self.orderModel?.shop?.workingHours ?? "", image: self.orderModel?.shop?.image ?? "", rate: self.orderModel?.shop?.rate ?? 0.0, type: self.orderModel?.shop?.type ?? TypeClass(id: 0, name: "",image: ""))
            vc.shop = shopData
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    
    func validate() -> Bool {
        if (self.orderModel?.pickUpLatitude ?? 0.0 == 0.0 || self.orderModel?.pickUpLongitude ?? 0.0 == 0.0) {
            self.showBanner(title: "alert".localized, message: "choose_shop_or_pickup".localized, style: UIColor.INFO)
            return false
        }
        //        if (self.orderModel?.shop?.id ?? 0 == 0) {
        //            if (self.edtMoreDetails.text?.count ?? 0 == 0) {
        //                self.showBanner(title: "alert".localized, message: "enter_pickup_details".localized, style: UIColor.INFO)
        //                return false
        //            }
        //        }
        return true
    }
    
    func labasLocationManager(didUpdateLocation location: CLLocation) {
        if (self.latitude ?? 0.0 == 0.0 || self.longitude ?? 0.0 == 0.0) {
            
//            self.latitude = location.coordinate.latitude
//            self.longitude = location.coordinate.longitude
            
            self.latitude = 29.273551
            self.longitude = 47.936161

            self.hideLoading()
            self.setUpGoogleMap()
        }
    }
    
    func updateModel(model: OTWOrder) {
        self.orderModel = model
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
        
        self.getShopsList(radius: Float(Constants.DEFAULT_RADIUS), rating: 0)
        
    }
    
    @IBAction func step1Action(_ sender: Any) {
        
    }
    
    @IBAction func step2Action(_ sender: Any) {
        //        if (self.validate()) {
        //            if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DeliveryStep2") as? DeliveryStep2
        //            {
        //                self.orderModel?.pickUpDetails = self.edtMoreDetails.text ?? ""
        //                vc.latitude = self.latitude
        //                vc.longitude = self.longitude
        //                vc.orderModel = self.orderModel
        //                vc.delegate = self
        //                self.navigationController?.pushViewController(vc, animated: true)
        //            }
        //        }
        
    }
    
    @IBAction func step3Action(_ sender: Any) {
        
    }
    
    @IBAction func nextAction(_ sender: Any) {
        if (self.validate()) {
            if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DeliveryStep2") as? DeliveryStep2
            {
                self.orderModel?.pickUpDetails = self.edtMoreDetails.text ?? ""
                vc.latitude = self.latitude
                vc.longitude = self.longitude
                vc.orderModel = self.orderModel
                vc.delegate = self
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    @IBAction func backAction(_ sender: Any) {
        if (fromHome ?? false) {
            self.navigationController?.popViewController(animated: true)
        }else {
            let mainStoryboardIpad : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let initialViewControlleripad : UIViewController = mainStoryboardIpad.instantiateViewController(withIdentifier: self.getHomeView()) as! UINavigationController
            self.present(initialViewControlleripad, animated: true, completion: {})
        }
    }
    
    @IBAction func searchAction(_ sender: Any) {
        
    }
    
    fileprivate func getAddressForMapCenter() {
        let point : CGPoint = mapView.center
        let coordinate : CLLocationCoordinate2D = (self.pinMarker?.position)!
        let location =  CLLocation.init(latitude: coordinate.latitude, longitude: coordinate.longitude)
        self.selectedLocation = location
        self.GetAnnotationUsingCoordinated(location)
    }
    
    fileprivate func GetAnnotationUsingCoordinated(_ location : CLLocation) {
        
        GMSGeocoder().reverseGeocodeCoordinate(location.coordinate) { (response, error) in
            
            var strAddresMain : String = ""
            
            if let address : GMSAddress = response?.firstResult() {
                if let lines = address.lines  {
                    if (lines.count > 0) {
                        if lines.count > 0 {
                            if lines[0].characters.count > 0 {
                                strAddresMain = strAddresMain + lines[0]
                            }
                        }
                    }
                    
                    if lines.count > 1 {
                        if lines[1].characters.count > 0 {
                            if strAddresMain.characters.count > 0 {
                                strAddresMain = strAddresMain + ", \(lines[1])"
                            } else {
                                strAddresMain = strAddresMain + "\(lines[1])"
                            }
                        }
                    }
                    
                    if (strAddresMain.characters.count > 0) {
                        
                        var strSubTitle = ""
                        if let locality = address.locality {
                            strSubTitle = locality
                        }
                        
                        if let administrativeArea = address.administrativeArea {
                            if strSubTitle.characters.count > 0 {
                                strSubTitle = "\(strSubTitle), \(administrativeArea)"
                            }
                            else {
                                strSubTitle = administrativeArea
                            }
                        }
                        
                        if let country = address.country {
                            if strSubTitle.characters.count > 0 {
                                strSubTitle = "\(strSubTitle), \(country)"
                            }
                            else {
                                strSubTitle = country
                            }
                        }
                        
                        self.lblPickupLocation.text = strAddresMain
                        self.lblPickupLocation.textColor = UIColor.appDarkBlue
                        self.orderModel?.pickUpAddress = strAddresMain
                        
                    }
                    else {
                        self.lblPickupLocation.text = "Loading".localized
                        self.lblPickupLocation.textColor = UIColor.appDarkBlue
                        self.orderModel?.pickUpAddress = ""
                    }
                }
                else {
                    self.lblPickupLocation.text = "Loading".localized
                    self.lblPickupLocation.textColor = UIColor.appDarkBlue
                    self.orderModel?.pickUpAddress = ""
                }
            }
            else {
                self.lblPickupLocation.text = "Loading".localized
                self.orderModel?.pickUpAddress = ""
            }
        }
    }
    
    func getShopsList(radius : Float, rating : Double) {
        ApiService.getShops(latitude: self.latitude ?? 0.0, longitude: self.longitude ?? 0.0, radius: radius, rating : rating, types : 0) { (response) in
            self.shops.removeAll()
            self.shops.append(contentsOf: response.dataShops ?? [DataShop]())
            self.addShopsMarkers()
        }
    }
    
    func getShopDistance(latitude : Double, longitude : Double) -> String {
        let userLatLng = CLLocation(latitude: self.latitude ?? 0.0, longitude: self.longitude ?? 0.0)
        let shopLatLng = CLLocation(latitude: latitude, longitude: longitude)
        let distanceInMeters = shopLatLng.distance(from: userLatLng)
        let distanceInKM = distanceInMeters / 1000.0
        let distanceStr = String(format: "%.2f", distanceInKM)
        return "(\(distanceStr) \("km".localized))"
    }
    
    func getShopsByName(name : String, latitude : Double, longitude: Double, radius : Float) {
        ApiService.getShopsByName(name: name,latitude: latitude, longitude: longitude, radius: radius) { (response) in
            self.shops.removeAll()
            var filterItems = [SearchTextFieldItem]()
            self.filterShops.removeAll()
            self.filterShops.append(contentsOf: response.dataShops ?? [DataShop]())
            
            
            for shop in self.filterShops {
                let item1 = SearchTextFieldItem(title: "\(shop.name ?? "")  \(self.getShopDistance(latitude: shop.latitude ?? 0.0, longitude: shop.longitude ?? 0.0))", subtitle: shop.address ?? "", image: UIImage(named: "ic_location"))
                filterItems.append(item1)
            }
            
            self.searchField.theme.font = UIFont.systemFont(ofSize: 13)
            self.searchField.filterItems(filterItems)
            self.searchField.itemSelectionHandler = { filteredResults, itemPosition in
                // Just in case you need the item position
                let shop = self.filterShops[itemPosition]
                self.searchField.text = shop.name ?? ""
                self.orderModel?.pickUpLatitude = shop.latitude ?? 0.0
                self.orderModel?.pickUpLongitude = shop.longitude ?? 0.0
                self.orderModel?.shop = shop
                self.orderModel?.pickUpAddress = shop.name ?? ""
                self.lblPickupLocation.text = shop.name ?? ""
                self.lblPickupLocation.textColor = UIColor.appDarkBlue
                
                
                for marker in self.shopMarkers {
//                    marker.icon = UIImage(named: "ic_map_shop")
//                    if (marker.title == "\(shop.id ?? 0)") {
//                        marker.icon = UIImage(named: "ic_map_shop_selected")
//                    }else {
//                        marker.map = nil
//                    }
                    marker.map = nil
                }
                
                self.singleMarker?.map = nil
                self.singleMarker = GMSMarker()
                self.singleMarker?.position = CLLocationCoordinate2D(latitude: shop.latitude ?? 0.0, longitude: shop.longitude ?? 0.0)
                self.singleMarker?.title =  "\(shop.id ?? 0)"
                self.singleMarker?.snippet = "\(shop.phoneNumber ?? "")"
                self.singleMarker?.icon = UIImage(named: "ic_map_shop_selected")
                self.singleMarker?.map = self.gMap
                
                self.ivShop.isHidden = false
                self.viewShopDetails.isHidden = false
                let url = URL(string: "\(Constants.IMAGE_URL)\(shop.image ?? "")")
                self.ivShop.kf.setImage(with: url)
                self.edtMoreDetails.text = "\(shop.name ?? "")\n\(shop.address ?? "")"
                
                self.lblShopName.text = shop.name ?? ""
                self.shopNameHeight.constant = 20
                self.viewPin.isHidden = false
                self.viewSuggest.isHidden = true
                
                
                let camera = GMSCameraPosition.camera(withLatitude: self.orderModel?.pickUpLatitude ?? 0.0, longitude: self.orderModel?.pickUpLongitude ?? 0.0, zoom: 15.0)
                self.gMap?.animate(to: camera)
                
                
            }
            
        }
    }
    
    @IBAction func clearPickLocation(_ sender: Any) {
        self.ivShop.image = nil
        self.edtMoreDetails.text = ""
        self.lblPickupLocation.text = ""
        self.searchField.text = ""
        self.ivShop.isHidden = true
        self.viewShopDetails.isHidden = true
        self.gMap?.clear()
        self.getShopsList(radius: Float(Constants.DEFAULT_RADIUS), rating: 0)
        
        self.lblShopName.text = ""
        self.shopNameHeight.constant = 0
        self.viewPin.isHidden = false
        self.viewSuggest.isHidden = true
        
    }
    
    
    @IBAction func suggestAction(_ sender: Any) {
        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SuggestShopVC") as? SuggestShopVC
        {
            vc.latitude = self.pinLatitude ?? 0.0
            vc.longitude = self.pinLongitude ?? 0.0
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func addShopsMarkers() {
        self.gMap?.clear()
        for center in self.shops {
            let marker = GMSMarker()
            marker.position = CLLocationCoordinate2D(latitude: center.latitude ?? 0.0, longitude: center.longitude ?? 0.0)
            marker.title =  "\(center.id ?? 0)"
            marker.snippet = "\(center.phoneNumber ?? "")"
            marker.icon = UIImage(named: "ic_map_shop")
            marker.map = gMap
            self.shopMarkers.append(marker)
        }
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: self.latitude ?? 0.0, longitude: self.longitude ?? 0.0)
        marker.title =  "my_location"
        marker.snippet = ""
        marker.map = gMap
    }
    
    
}
extension DeliveryStep1 : GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        toolTipView?.removeFromSuperview()
    }
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        
    }
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        let id = marker.title ?? "0"
        if (id.contains(find: "my_location")) {
            return true
        }
        if (id == "0" || id == "") {
         return true
       }
        if (Int(id) ?? 0 > 0) {
            self.showLoading()
            self.viewPin.isHidden = false
            self.viewSuggest.isHidden = true
            ApiService.getShopDetails(id: Int(id)!) { (response) in
                self.hideLoading()
                self.pinMarker?.map = nil
                self.lblPickupLocation.textColor = UIColor.appDarkBlue
                self.lblPickupLocation.text = response.shopData?.name ?? ""
                let dataShop = DataShop(id: response.shopData?.id ?? 0, name: response.shopData?.name ?? "", address: response.shopData?.address ?? "", latitude: response.shopData?.latitude ?? 0.0, longitude: response.shopData?.longitude ?? 0.0, phoneNumber: response.shopData?.phoneNumber ?? "", workingHours: response.shopData?.workingHours ?? "", image: response.shopData?.image ?? "", rate: response.shopData?.rate ?? 0.0, type: response.shopData?.type ?? TypeClass(id: 0, name: "",image: ""))
                self.orderModel?.shop = dataShop
                self.orderModel?.pickUpAddress = response.shopData?.name ?? ""
                self.orderModel?.pickUpLatitude = response.shopData?.latitude ?? 0.0
                self.orderModel?.pickUpLongitude = response.shopData?.longitude ?? 0.0
                
                self.lblShopName.text = response.shopData?.name ?? ""
                self.shopNameHeight.constant = 20
                
                
                self.viewShopDetails.isHidden = false
                self.ivShop.isHidden = false
                self.edtMoreDetails.text = "\(response.shopData?.name ?? "")\n\(response.shopData?.address ?? "")"
                
                if (response.shopData?.image?.count ?? 0 > 0) {
                    let url = URL(string: "\(Constants.IMAGE_URL)\(response.shopData?.image ?? "")")
                    self.ivShop.kf.setImage(with: url)
                }else {
                    let url = URL(string: "\(Constants.IMAGE_URL)\(response.shopData?.type?.image ?? "")")
                    self.ivShop.kf.setImage(with: url)
                }
                
                for mark in self.shopMarkers {
                    mark.map = nil
                }
                self.singleMarker?.map = nil
                self.singleMarker = GMSMarker()
                self.singleMarker?.position = CLLocationCoordinate2D(latitude: marker.position.latitude, longitude: marker.position.longitude)
                self.singleMarker?.title =  id
                self.singleMarker?.snippet = ""
                self.singleMarker?.icon = UIImage(named: "ic_map_shop_selected")
                self.singleMarker?.map = self.gMap
                
                let camera = GMSCameraPosition.camera(withLatitude: self.orderModel?.pickUpLatitude ?? 0.0, longitude: self.orderModel?.pickUpLongitude ?? 0.0, zoom: 15.0)
                self.gMap?.animate(to: camera)
            }
            return true
        }else {
            return true
        }
    }
    
    
    func getShopImageByType(type : Int) -> UIImage {
        switch type {
        case Constants.PLACE_BAKERY:
            return UIImage(named: "ic_place_bakery")!
        case Constants.PLACE_BOOK_STORE:
            return UIImage(named: "ic_place_book_store")!
        case Constants.PLACE_CAFE:
            return UIImage(named: "ic_place_cafe")!
        case Constants.PLACE_MEAL_DELIVERY:
            return UIImage(named: "ic_place_meal_delivery")!
        case Constants.PLACE_MEAL_TAKEAWAY:
            return UIImage(named: "ic_place_meal_takeaway")!
        case Constants.PLACE_PHARMACY:
            return UIImage(named: "ic_place_pharmacy")!
        case Constants.PLACE_RESTAURANT:
            return UIImage(named: "ic_place_restaurant")!
        case Constants.PLACE_SHOPPING_MALL:
            return UIImage(named: "ic_place_shopping_mall")!
        case Constants.PLACE_STORE:
            return UIImage(named: "ic_place_store")!
        case Constants.PLACE_SUPERMARKET:
            return UIImage(named: "ic_place_supermarket")!
        default:
            return UIImage(named: "ic_place_store")!
        }
    }
    
    
    
    
    func mapView(_ mapView: GMSMapView, didLongPressAt coordinate: CLLocationCoordinate2D) {
        self.gMap?.clear()
        self.shopMarkers.removeAll()
        self.pinMarker?.map = nil
        self.pinMarker = GMSMarker()
        self.pinLatitude = coordinate.latitude
        self.pinLongitude = coordinate.longitude
        self.pinMarker?.position = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
        self.pinMarker?.title =  ""
        self.pinMarker?.icon = UIImage(named: "ic_location_pin")
        self.pinMarker?.snippet = ""
        self.pinMarker?.map = gMap
        self.lblPickupLocation.text = "Loading".localized
        self.lblPickupLocation.textColor = UIColor.appDarkBlue
        self.orderModel?.pickUpAddress = ""
        self.orderModel?.pickUpLatitude = coordinate.latitude
        self.orderModel?.pickUpLongitude = coordinate.longitude
        self.getAddressForMapCenter()
        
        self.lblShopName.text = ""
        self.shopNameHeight.constant = 0
        self.viewPin.isHidden = true
        self.viewSuggest.isHidden = false
        
        self.ivShop.image = nil
        self.edtMoreDetails.text = ""
        self.ivShop.isHidden = true
        self.viewShopDetails.isHidden = true
        
    }
    
}

extension DeliveryStep1: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField == self.searchField {
            let maxLength = 100
            let currentString: NSString = textField.text as NSString? ?? ""
            let newString: NSString =
                currentString.replacingCharacters(in: range, with: string) as NSString
            if (newString.length >= 3) {
                self.getShopsByName(name: newString as String, latitude: self.latitude ?? 0.0, longitude: self.longitude ?? 0.0, radius: Float(Constants.DEFAULT_RADIUS))
            }
            if (newString.length == 0) {
                self.gMap?.clear()
                self.getShopsList(radius: Float(Constants.DEFAULT_RADIUS), rating: 0)
            }
            return newString.length <= maxLength
        }
        
        return false
    }
    
}
