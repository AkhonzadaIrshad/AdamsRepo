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
import MarqueeLabel

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

    @IBOutlet weak var shopNameHeight: NSLayoutConstraint!
    
    @IBOutlet weak var lblShopName: MarqueeLabel!
    
    @IBOutlet weak var btnCurrentLocation: UIButton!
    
    @IBOutlet weak var ivIndicator: UIImageView!
    
    @IBOutlet weak var moreDetailsView: UIView!
    
    @IBOutlet weak var lblSearch: MyUILabel!
    
    @IBOutlet weak var viewBecomeDriver: UIView!
    
    
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
          //  self.ivHandle.image = UIImage(named: "ic_back_arabic")
            self.ivIndicator.image = UIImage(named: "ic_arrow_login_white_arabic")
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
            self.moreDetailsView.isHidden = false
            self.lblSearch.isHidden = true
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
            
            if (self.orderModel?.shop?.images?.count ?? 0 > 0) {
                let url = URL(string: "\(Constants.IMAGE_URL)\(self.orderModel?.shop?.images?[0] ?? "")")
                self.ivShop.kf.setImage(with: url)
            }else {
                let url = URL(string: "\(Constants.IMAGE_URL)\(self.orderModel?.shop?.type?.image ?? "")")
                self.ivShop.kf.setImage(with: url)
            }
            
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
            popTip.show(text: "current_location_desc".localized, direction: .left, maxWidth: 200, in: self.view, from: self.btnCurrentLocation.frame)
        }else {
            popTip.show(text: "current_location_desc".localized, direction: .left, maxWidth: 200, in: self.view, from: self.btnCurrentLocation.frame)
        }
      
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            popTip.hide()
        }
        
        if (App.shared.config?.configSettings?.flag ?? false) {
          self.checkForUpdates()
        }
        
        
        if (self.isProvider()) {
            self.getDriverOnGoingDeliveries()
        }
        
    }
    
    func getDriverOnGoingDeliveries() {
        self.showLoading()
        ApiService.getDriverOnGoingDeliveries(Authorization: self.loadUser().data?.accessToken ?? "") { (response) in
            self.hideLoading()
            for item in response.data ?? [DatumDriverDel]() {
                if (item.time ?? 0 <= 1) {
                    DispatchQueue.main.async {
                        let messagesVC: ZHCDemoMessagesViewController = ZHCDemoMessagesViewController.init()
                        messagesVC.presentBool = true
                        
                        let dumOrder = DatumDel(id: item.id ?? 0, title: item.title ?? "", status: item.status ?? 0, statusString: item.statusString ?? "", image: item.image ?? "", createdDate: item.createdDate ?? "", chatId: item.chatId ?? 0, fromAddress: item.fromAddress ?? "", fromLatitude: item.fromLatitude ?? 0.0, fromLongitude: item.fromLongitude ?? 0.0, toAddress: item.toAddress ?? "", toLatitude: item.toLatitude ?? 0.0, toLongitude: item.toLongitude ?? 0.0, providerID: item.providerID ?? "", providerName: item.providerName ?? "", providerImage: item.providerImage ?? "", providerRate: item.providerRate ?? 0.0, time: item.time ?? 0, price: item.price ?? 0.0, serviceName: item.serviceName ?? "")
                        
                        messagesVC.order = dumOrder
                        messagesVC.user = self.loadUser()
                        let nav: UINavigationController = UINavigationController.init(rootViewController: messagesVC)
                        self.navigationController?.present(nav, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if ((self.loadUser().data?.roles?.contains(find: "Driver"))!) {
            self.viewBecomeDriver.isHidden = true
        }else {
            self.viewBecomeDriver.isHidden = false
        }
    }
    
    
    func checkForUpdates() {
        
        let appVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String ?? "0.0"
        let CMSVersion = App.shared.config?.updateStatus?.iosVersion ?? appVersion
        let isMand = App.shared.config?.updateStatus?.iosIsMandatory ?? false
        
        if (appVersion != CMSVersion){
            if (isMand){
                //mandatory
                if (self.isArabic()) {
                    self.showMandUpdateDialog(titleStr: "mandatory_update".localized, desc: App.shared.config?.configString?.arabicNewVersionText ?? "new_update_available".localized)
                } else {
                    self.showMandUpdateDialog(titleStr: "mandatory_update".localized, desc: App.shared.config?.configString?.englishNewVersionText ?? "new_update_available".localized)
                }
                
            }else {
                //normal
                let defaults = UserDefaults.standard
                var updateCount = defaults.value(forKey: "UPDATE_COUNT_CLICK") as? Int ?? 4
                if (updateCount >= 4) {
                    defaults.setValue(1, forKey: "UPDATE_COUNT_CLICK")
                    if (self.isArabic()) {
                        self.showNormUpdateDialog(titleStr: "new_update".localized, desc: App.shared.config?.configString?.arabicNewVersionText ?? "new_update_available".localized)
                    } else {
                        self.showNormUpdateDialog(titleStr: "new_update".localized, desc: App.shared.config?.configString?.englishNewVersionText ?? "new_update_available".localized)
                    }
                }else {
                    updateCount = defaults.value(forKey: "UPDATE_COUNT_CLICK") as? Int ?? 1
                    defaults.setValue((updateCount + 1), forKey: "UPDATE_COUNT_CLICK")
                }
            }
        }
        
    }
    
    
    func showNormUpdateDialog(titleStr : String, desc : String) {
        let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "normdialogvc") as! NormUpdateDialog
        viewController.dialogTitleStr = titleStr
        viewController.dialogDescStr = desc
        self.present(viewController, animated: true, completion: nil)
    }
    
    func showMandUpdateDialog(titleStr : String, desc : String) {
        let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "manddialogvc") as! MandIUpdateDialog
        viewController.dialogTitleStr = titleStr
        viewController.dialogDescStr = desc
        self.present(viewController, animated: true, completion: nil)
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
            
            let shopData = ShopData(nearbyDriversCount: 0, id: self.orderModel?.shop?.id ?? 0, name: self.orderModel?.shop?.name ?? "", address: self.orderModel?.shop?.address ?? "", latitude: self.orderModel?.shop?.latitude ?? 0.0, longitude: self.orderModel?.shop?.longitude ?? 0.0, phoneNumber: self.orderModel?.shop?.phoneNumber ?? "", workingHours: self.orderModel?.shop?.workingHours ?? "", images: self.orderModel?.shop?.images ?? [String](), rate: self.orderModel?.shop?.rate ?? 0.0, type: self.orderModel?.shop?.type ?? TypeClass(id: 0, name: "",image: ""), ownerId: self.orderModel?.shop?.ownerId ?? "")
            shopData.placeId = self.orderModel?.shop?.placeId ?? ""
            
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
        self.hideLoading()
        if (self.latitude ?? 0.0 == 0.0 || self.longitude ?? 0.0 == 0.0) {
            
            self.latitude = location.coordinate.latitude
            self.longitude = location.coordinate.longitude
            
            UserDefaults.standard.setValue(self.latitude, forKey: Constants.LAST_LATITUDE)
            UserDefaults.standard.setValue(self.longitude, forKey: Constants.LAST_LONGITUDE)
            
//            self.latitude = 29.363534
//            self.longitude = 47.989769

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
        UserDefaults.standard.setValue(true, forKey: Constants.OPEN_MENU)
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
                        
                        self.shopNameHeight.constant = 20
                        self.lblShopName.text = strAddresMain
                        
                        self.lblPickupLocation.text = strAddresMain
                        self.lblPickupLocation.textColor = UIColor.appDarkBlue
                        self.orderModel?.pickUpAddress = strAddresMain
                        
                    }
                    else {
                        self.shopNameHeight.constant = 0
                        self.lblShopName.text = ""
                        self.lblPickupLocation.text = "Loading".localized
                        self.lblPickupLocation.textColor = UIColor.appDarkBlue
                        self.orderModel?.pickUpAddress = ""
                    }
                }
                else {
                    self.shopNameHeight.constant = 0
                    self.lblShopName.text = ""
                    self.lblPickupLocation.text = "Loading".localized
                    self.lblPickupLocation.textColor = UIColor.appDarkBlue
                    self.orderModel?.pickUpAddress = ""
                }
            }
            else {
                self.shopNameHeight.constant = 0
                self.lblShopName.text = ""
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
            self.searchField.startVisibleWithoutInteraction = true
            self.searchField.startSuggestingInmediately = true
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
                self.lblShopName.text = shop.name ?? ""
                self.lblPickupLocation.textColor = UIColor.appDarkBlue
                
                self.moreDetailsView.isHidden = false
                self.lblSearch.isHidden = true
                
                self.view.endEditing(true)
                
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
                
                if (shop.images?.count ?? 0 > 0) {
                    let url = URL(string: "\(Constants.IMAGE_URL)\(shop.images?[0] ?? "")")
                    self.ivShop.kf.setImage(with: url)
                }else if (shop.type?.image?.count ?? 0 > 0){
                    let url = URL(string: "\(Constants.IMAGE_URL)\(shop.type?.image ?? "")")
                    self.ivShop.kf.setImage(with: url)
                }else {
                    self.ivShop.image = UIImage(named: "ic_place_store")
                }
               
                
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
    
    
    func getShopByPlaces(name : String, latitude : Double, longitude: Double) {
        
        ApiService.getPlacesAPI(input: name, latitude: latitude, longitude: longitude) { (response) in
            self.shops.removeAll()
            var filterItems = [SearchTextFieldItem]()
            self.filterShops.removeAll()
            for prediction in response.results ?? [Result]() {
                let dataShop = DataShop(id: 0, name: prediction.name ?? "", address: prediction.vicinity ?? "", latitude: prediction.geometry?.location?.lat ?? 0.0, longitude: prediction.geometry?.location?.lng ?? 0.0, phoneNumber: "", workingHours: "", images: [String](), rate: prediction.rating ?? 0.0, type: TypeClass(id: 0, name: prediction.types?[0] ?? "", image: ""), ownerId: "")
               dataShop.placeId = prediction.id ?? ""
                  self.filterShops.append(dataShop)
            }
            
            for shop in self.filterShops {
                let item1 = SearchTextFieldItem(title: "\(shop.name ?? "")  \(self.getShopDistance(latitude: shop.latitude ?? 0.0, longitude: shop.longitude ?? 0.0))", subtitle: shop.address ?? "", image: UIImage(named: "ic_location"))
                filterItems.append(item1)
            }
            
            self.searchField.theme.font = UIFont.systemFont(ofSize: 13)
            self.searchField.forceNoFiltering = true
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
                self.lblShopName.text = shop.name ?? ""
                self.lblPickupLocation.textColor = UIColor.appDarkBlue
                
                 self.moreDetailsView.isHidden = false
                self.lblSearch.isHidden = true
                
                self.view.endEditing(true)
                
                for marker in self.shopMarkers {
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
                
                if (shop.images?.count ?? 0 > 0) {
                    let url = URL(string: "\(Constants.IMAGE_URL)\(shop.images?[0] ?? "")")
                    self.ivShop.kf.setImage(with: url)
                }else if (shop.type?.image?.count ?? 0 > 0){
                    let url = URL(string: "\(Constants.IMAGE_URL)\(shop.type?.image ?? "")")
                    self.ivShop.kf.setImage(with: url)
                }else {
                    self.ivShop.image = UIImage(named: "ic_place_store")
                }
                
                
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
        self.moreDetailsView.isHidden = true
        self.lblSearch.isHidden = false
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
    
    
    @IBAction func clearFieldAction(_ sender: Any) {
        self.moreDetailsView.isHidden = true
        self.lblSearch.isHidden = false
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
    
    
    @IBAction func becomeDriverAction(_ sender: Any) {
        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RegisterDriverVC") as? RegisterDriverVC
        {
            self.navigationController?.pushViewController(vc, animated: true)
        }
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
            ApiService.getShopDetails(Authorization: self.loadUser().data?.accessToken ?? "", id: Int(id)!) { (response) in
                self.hideLoading()
                self.pinMarker?.map = nil
                self.lblPickupLocation.textColor = UIColor.appDarkBlue
                self.lblPickupLocation.text = response.shopData?.name ?? ""
                let dataShop = DataShop(id: response.shopData?.id ?? 0, name: response.shopData?.name ?? "", address: response.shopData?.address ?? "", latitude: response.shopData?.latitude ?? 0.0, longitude: response.shopData?.longitude ?? 0.0, phoneNumber: response.shopData?.phoneNumber ?? "", workingHours: response.shopData?.workingHours ?? "", images: response.shopData?.images ?? [String](), rate: response.shopData?.rate ?? 0.0, type: response.shopData?.type ?? TypeClass(id: 0, name: "",image: ""),ownerId: response.shopData?.ownerId ?? "")
                self.orderModel?.shop = dataShop
                self.orderModel?.pickUpAddress = response.shopData?.name ?? ""
                self.orderModel?.pickUpLatitude = response.shopData?.latitude ?? 0.0
                self.orderModel?.pickUpLongitude = response.shopData?.longitude ?? 0.0
                
                self.lblShopName.text = response.shopData?.name ?? ""
                self.shopNameHeight.constant = 20
            
                self.moreDetailsView.isHidden = false
                self.lblSearch.isHidden = true
                self.viewShopDetails.isHidden = false
                
                self.ivShop.isHidden = false
                self.edtMoreDetails.text = "\(response.shopData?.name ?? "")\n\(response.shopData?.address ?? "")"
                
                if (response.shopData?.images?.count ?? 0 > 0) {
                    let url = URL(string: "\(Constants.IMAGE_URL)\(response.shopData?.images?[0] ?? "")")
                    self.ivShop.kf.setImage(with: url)
                }else if (response.shopData?.type?.image?.count ?? 0 > 0){
                    let url = URL(string: "\(Constants.IMAGE_URL)\(response.shopData?.type?.image ?? "")")
                    self.ivShop.kf.setImage(with: url)
                }else {
                    self.ivShop.image = UIImage(named: "ic_place_store")
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
        self.moreDetailsView.isHidden = false
        self.lblSearch.isHidden = true
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
        
  //      self.lblShopName.text = ""
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
                
                // self.getShopByPlaces(name: newString as String, latitude: self.latitude ?? 0.0, longitude: self.longitude ?? 0.0)
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
