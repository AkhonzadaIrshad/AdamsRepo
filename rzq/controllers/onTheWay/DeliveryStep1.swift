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
import SearchTextField

class DeliveryStep1: BaseVC,LabasLocationManagerDelegate {
    
    @IBOutlet weak var lblPickupLocation: MyUILabel!
    
    @IBOutlet weak var mapView: UIView!
    
    @IBOutlet weak var edtMoreDetails: MyUITextField!
    
    @IBOutlet weak var searchField: SearchTextField!
    
    @IBOutlet weak var ivHandle: UIImageView!
    
    var markerLocation: GMSMarker?
    var currentZoom: Float = 0.0
    var gMap : GMSMapView?
    
    var latitude : Double?
    var longitude : Double?
    
    var pinMarker : GMSMarker?
    
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
            self.latitude = location.coordinate.latitude
            self.longitude = location.coordinate.longitude
            self.hideLoading()
            self.setUpGoogleMap()
        }
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
        if (self.validate()) {
            if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DeliveryStep2") as? DeliveryStep2
            {
                vc.latitude = self.latitude
                vc.longitude = self.longitude
                vc.orderModel = self.orderModel
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        
    }
    
    @IBAction func step3Action(_ sender: Any) {
        
    }
    
    @IBAction func nextAction(_ sender: Any) {
        if (self.validate()) {
            if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DeliveryStep2") as? DeliveryStep2
            {
                vc.latitude = self.latitude
                vc.longitude = self.longitude
                vc.orderModel = self.orderModel
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
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
                    marker.icon = UIImage(named: "ic_map_shop")
                    if (marker.title == "\(shop.id ?? 0)") {
                         marker.icon = UIImage(named: "ic_map_shop_selected")
                    }
                }
                
                
                let camera = GMSCameraPosition.camera(withLatitude: self.orderModel?.pickUpLatitude ?? 0.0, longitude: self.orderModel?.pickUpLongitude ?? 0.0, zoom: 15.0)
                self.gMap?.animate(to: camera)
                
                
            }
            
        }
    }
    @IBAction func clearPickLocation(_ sender: Any) {
        self.gMap?.clear()
        self.getShopsList(radius: Float(Constants.DEFAULT_RADIUS), rating: 0)
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
        if (Int(id) ?? 0 > 0) {
            ApiService.getShopDetails(id: Int(id)!) { (response) in
                self.pinMarker?.map = nil
                self.lblPickupLocation.textColor = UIColor.appDarkBlue
                self.lblPickupLocation.text = response.shopData?.name ?? ""
                let dataShop = DataShop(id: response.shopData?.id ?? 0, type: response.shopData?.type ?? 0, rate: response.shopData?.rate ?? 0.0, name: response.shopData?.name ?? "", address: response.shopData?.address ?? "", latitude: response.shopData?.latitude ?? 0.0, longitude: response.shopData?.longitude ?? 0.0, phoneNumber: response.shopData?.phoneNumber ?? "", workingHours: response.shopData?.workingHours ?? "", isOpen: response.shopData?.isOpen ?? false, image: response.shopData?.image ?? "")
                self.orderModel?.shop = dataShop
                self.orderModel?.pickUpAddress = response.shopData?.name ?? ""
                self.orderModel?.pickUpLatitude = response.shopData?.latitude ?? 0.0
                self.orderModel?.pickUpLongitude = response.shopData?.longitude ?? 0.0
                
                for mark in self.shopMarkers {
                    mark.icon = UIImage(named: "ic_map_shop")
                }
                marker.icon = UIImage(named: "ic_map_shop_selected")
                
                let camera = GMSCameraPosition.camera(withLatitude: self.orderModel?.pickUpLatitude ?? 0.0, longitude: self.orderModel?.pickUpLongitude ?? 0.0, zoom: 15.0)
                self.gMap?.animate(to: camera)
            }
            return true
        }else {
            return true
        }
    }
    func mapView(_ mapView: GMSMapView, didLongPressAt coordinate: CLLocationCoordinate2D) {
         self.pinMarker?.map = nil
        self.pinMarker = GMSMarker()
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
    }
    
}
extension DeliveryStep1: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField == self.searchField {
            let maxLength = 20
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
