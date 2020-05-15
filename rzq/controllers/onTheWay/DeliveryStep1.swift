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

class DeliveryStep1: BaseVC,LabasLocationManagerDelegate, Step2Delegate, AllShopDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var lblPickupLocation: MyUILabel!
    
    @IBOutlet weak var mapView: UIView!
    
    @IBOutlet weak var edtMoreDetails: MyUITextField!
    
    @IBOutlet weak var searchField: SearchTextField!
    
    @IBOutlet weak var viewParentSearch: CardView!
    
    @IBOutlet weak var ivHandle: UIImageView!
    
    @IBOutlet weak var ivShop: CircleImage!
    @IBOutlet weak var viewShopDetails: CardView!
    @IBOutlet weak var viewClearField: CardView!
    
    @IBOutlet weak var viewSuggest: UIView!
    
    @IBOutlet weak var viewPin: UIView!
    
    @IBOutlet weak var shopNameHeight: NSLayoutConstraint!
    
    @IBOutlet weak var lblShopName: MarqueeLabel!
    
    @IBOutlet weak var btnCurrentLocation: UIButton!
    
    @IBOutlet weak var ivIndicator: UIImageView!
    
    @IBOutlet weak var moreDetailsView: UIView!
    
    @IBOutlet weak var lblSearch: MyUILabel!
    
    @IBOutlet weak var viewBecomeDriver: UIView!
    
    @IBOutlet weak var ivGoogle: UIButton!
    @IBOutlet weak var btnListView: UIButton!
    @IBOutlet weak var lblViewList: UILabel!
    
    @IBOutlet weak var btnCheckMenu: MyUIButton!
    @IBOutlet weak var viewCheckMenu: CardView!
    
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
    
    var selectdCategory: TypeClass?
    var selectedItems = [ShopMenuItem]()
    
    @IBOutlet weak var viewPop: UIView!
    
    @IBOutlet weak var collectionCategories: UICollectionView!
    var categories = [TypeClass]()
    
    override func viewDidLoad() {
        
        if (self.orderModel?.shop?.id ?? 0 > 0) {
            self.btnCheckMenu.isHidden = false
            self.viewCheckMenu.isHidden = false
        }else {
            self.btnCheckMenu.isHidden = true
            self.viewCheckMenu.isHidden = true
        }
        if (self.orderModel?.selectedItems?.count ?? 0 > 0) {
            self.selectedItems.append(contentsOf: self.orderModel?.selectedItems ?? [ShopMenuItem]())
        }
        
        self.lblViewList.text = "DeliveryStep1.listView".localized
        super.viewDidLoad()
        if (self.isArabic()) {
            //  self.ivHandle.image = UIImage(named: "ic_back_arabic")
            self.ivIndicator.image = UIImage(named: "ic_arrow_login_white_arabic")
            self.collectionCategories.semanticContentAttribute = UISemanticContentAttribute.forceRightToLeft
            
            self.collectionCategories.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
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
            self.singleMarker?.icon = UIImage(named: "ic_shop_empty")
            // snuff1
            let url = URL(string: "\(Constants.IMAGE_URL)\(self.orderModel?.shop?.type?.icon ?? "")")
            self.applyMarkerImage(from: url!, to: self.pinMarker!)
            self.pinMarker?.snippet = ""
            self.pinMarker?.map = gMap
            
            let camera = GMSCameraPosition.camera(withLatitude: self.orderModel?.pickUpLatitude ?? 0.0, longitude: self.orderModel?.pickUpLongitude ?? 0.0, zoom: 15.0)
            self.gMap?.animate(to: camera)
            
            self.ivShop.isHidden = false
            self.viewShopDetails.isHidden = false
            self.viewClearField.isHidden = false
            
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
        
        //        let popTip = PopTip()
        //        popTip.bubbleColor = UIColor.processing
        //        popTip.textColor = UIColor.white
        //        if (self.isArabic()) {
        //            popTip.show(text: "current_location_desc".localized, direction: .left, maxWidth: 200, in: self.view, from: self.btnCurrentLocation.frame)
        //        }else {
        //            popTip.show(text: "current_location_desc".localized, direction: .left, maxWidth: 200, in: self.view, from: self.btnCurrentLocation.frame)
        //        }
        //
        //        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
        //            popTip.hide()
        //        }
        
        let flag = App.shared.config?.configSettings?.flag ?? false
        if (flag == false) {
            self.checkForUpdates()
        }
        
        
        if (self.isProvider()) {
            self.getDriverOnGoingDeliveries()
        }
        
        
        // self.showSearchFieldToolTip()
        
        
        viewSuggest.isHidden = true
        
        //        let popTip = PopTip()
        //        popTip.bubbleColor = UIColor.colorPrimary
        //        popTip.textColor = UIColor.white
        //
        //        popTip.show(text: "search_from_google".localized, direction: .left, maxWidth: 260, in: self.view, from: self.ivGoogle.frame)
        //
        self.viewPop.isHidden = true
        
        //        DispatchQueue.main.asyncAfter(deadline: .now() + 11) {
        //            self.viewPop.isHidden = true
        //        }
        
        
        
        self.collectionCategories.delegate = self
        self.collectionCategories.dataSource = self
        
        
        ApiService.getAllTypes { (response) in
            let category = TypeClass(id: 0, name: "all_shops".localized, image: "", selectedIcon: "", icon: "")
            category.isChecked = true
            self.categories.append(category)
            self.categories.append(contentsOf: response.data ?? [TypeClass]())
            self.collectionCategories.reloadData()
        }
        
    }
    
    
    //collection delegates
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let label = UILabel(frame: CGRect.zero)
        label.text = self.categories[indexPath.row].name ?? ""
        label.sizeToFit()
        return CGSize(width: label.bounds.width + 8, height: self.collectionCategories.bounds.height - 8)
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
        return self.categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedCat = self.categories[indexPath.row]
        self.selectdCategory = selectedCat
        if selectedCat.id == 0 {
            self.addShopsMarkers()
        } else {
            self.filterShopsMarkers(selectedShopTypeId: selectedCat.id ?? 0)
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: Step1CatCell = collectionView.dequeueReusableCell(withReuseIdentifier: "Step1CatCell", for: indexPath as IndexPath) as! Step1CatCell
        
        let category = self.categories[indexPath.row]
        
        if (self.isArabic()) {
            cell.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        }
        
        cell.lblName.text = category.name ?? ""
        
        
        if (category.image?.count ?? 0 > 0) {
            let url = URL(string: "\(Constants.IMAGE_URL)\(category.image ?? "")")
            cell.ivLogo.kf.setImage(with: url)
        }else {
            cell.ivLogo.image = UIImage(named: "type_holder")
        }
        
        return cell
        
    }
    
    
    func openShopList() {
        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AllShopsVC") as? AllShopsVC
        {
            vc.delegate = self
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func onSelect(shop: DataShop) {
        self.showLoading()
        self.viewPin.isHidden = false
        self.viewSuggest.isHidden = true
        ApiService.getShopDetails(Authorization: self.loadUser().data?.accessToken ?? "", id: shop.id ?? 0) { (response) in
            self.hideLoading()
            self.pinMarker?.map = nil
            self.lblPickupLocation.textColor = UIColor.appDarkBlue
            self.lblPickupLocation.text = response.shopData?.name ?? ""
            let dataShop = DataShop(id: response.shopData?.id ?? 0, name: response.shopData?.name ?? "", address: response.shopData?.address ?? "", latitude: response.shopData?.latitude ?? 0.0, longitude: response.shopData?.longitude ?? 0.0, phoneNumber: response.shopData?.phoneNumber ?? "", workingHours: response.shopData?.workingHours ?? "", images: response.shopData?.images ?? [String](), rate: response.shopData?.rate ?? 0.0, type: response.shopData?.type ?? TypeClass(id: 0, name: "",image: "", selectedIcon: "", icon: ""),ownerId: response.shopData?.ownerId ?? "", googlePlaceId: response.shopData?.googlePlaceId ?? "", openNow : response.shopData?.openNow ?? false, NearbyDriversCount : response.shopData?.nearbyDriversCount ?? 0)
            self.orderModel?.shop = dataShop
            self.orderModel?.pickUpAddress = response.shopData?.name ?? ""
            self.orderModel?.pickUpLatitude = response.shopData?.latitude ?? 0.0
            self.orderModel?.pickUpLongitude = response.shopData?.longitude ?? 0.0
            
            self.lblShopName.text = response.shopData?.name ?? ""
            self.shopNameHeight.constant = 20
            
            self.moreDetailsView.isHidden = false
            self.lblSearch.isHidden = true
            self.viewShopDetails.isHidden = false
            self.viewClearField.isHidden = false
            
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
            self.singleMarker?.position = CLLocationCoordinate2D(latitude: shop.latitude ?? 0.0, longitude: shop.longitude ?? 0.0)
            self.singleMarker?.title =  "\(shop.id ?? 0)"
            self.singleMarker?.snippet = ""
            self.singleMarker?.icon = UIImage(named: "ic_shop_empty_selected")
            // snuff1
            let url = URL(string: "\(Constants.IMAGE_URL)\(response.shopData?.type?.selectedIcon ?? "")")
            self.applyMarkerImage(from: url!, to: self.singleMarker!)
            self.singleMarker?.map = self.gMap
            
            self.handleOpenNow(shop: response.shopData)
            
            let camera = GMSCameraPosition.camera(withLatitude: self.orderModel?.pickUpLatitude ?? 0.0, longitude: self.orderModel?.pickUpLongitude ?? 0.0, zoom: 15.0)
            self.gMap?.animate(to: camera)
        }
    }
    
    
    func showSearchFieldToolTip() {
        let popTip = PopTip()
        popTip.bubbleColor = UIColor.processing
        popTip.textColor = UIColor.white
        popTip.show(text: "searchfield_tooltip".localized, direction: .down, maxWidth: 900, in: self.view, from: self.viewParentSearch.frame)
        
        //        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
        //            popTip.hide()
        //        }
        
    }
    
    func getDriverOnGoingDeliveries() {
        self.showLoading()
        ApiService.getDriverOnGoingDeliveries(Authorization: self.loadUser().data?.accessToken ?? "") { (response) in
            self.hideLoading()
            //            for item in response.data ?? [DatumDriverDel]() {
            //                if (item.time ?? 0 == 0) {
            //                    ApiService.getDelivery(id: item.id ?? 0) { (response) in
            //                        let items = response.data?.items ?? [ShopMenuItem]()
            //                        DispatchQueue.main.async {
            //                            let messagesVC: ZHCDemoMessagesViewController = ZHCDemoMessagesViewController.init()
            //                            messagesVC.presentBool = true
            //
            //                            let dumOrder = DatumDel(id: item.id ?? 0, title: item.title ?? "", status: item.status ?? 0, statusString: item.statusString ?? "", image: item.image ?? "", createdDate: item.createdDate ?? "", chatId: item.chatId ?? 0, fromAddress: item.fromAddress ?? "", fromLatitude: item.fromLatitude ?? 0.0, fromLongitude: item.fromLongitude ?? 0.0, toAddress: item.toAddress ?? "", toLatitude: item.toLatitude ?? 0.0, toLongitude: item.toLongitude ?? 0.0, providerID: item.providerID ?? "", providerName: item.providerName ?? "", providerImage: item.providerImage ?? "", providerRate: item.providerRate ?? 0.0, time: item.time ?? 0, price: item.price ?? 0.0, serviceName: item.serviceName ?? "", paymentMethod: item.paymentMethod ?? 0, items: items, isPaid: item.isPaid ?? false, invoiceId: item.invoiceId ?? "", toFemaleOnly: item.toFemaleOnly ?? false, shopId: item.shopId ?? 0, OrderPrice: item.OrderPrice ?? 0.0, KnetCommission : item.KnetCommission ?? 0.0, ClientPhone: "", ProviderPhone : "")
            //
            //                            messagesVC.order = dumOrder
            //                            messagesVC.user = self.loadUser()
            //                            let nav: UINavigationController = UINavigationController.init(rootViewController: messagesVC)
            //                            nav.modalPresentationStyle = .fullScreen
            //                            messagesVC.modalPresentationStyle = .fullScreen
            //                            self.navigationController?.present(nav, animated: true, completion: nil)
            //                        }
            //
            //                    }
            //                }
            //            }
        }
    }
    
    
    func checkForUpdates() {
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0".replacedArabicDigitsWithEnglish
        let doubleAppVersion : Double = appVersion.toDouble() ?? 0.0
        let CMSVersion = App.shared.config?.updateStatus?.iosVersion ?? appVersion
        let doubleCmsVersion : Double = CMSVersion.toDouble() ?? 0.0
        let isMand = App.shared.config?.updateStatus?.iosIsMandatory ?? false
        
        if (doubleAppVersion < doubleCmsVersion){
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
        viewController.modalPresentationStyle = .fullScreen
        self.present(viewController, animated: true, completion: nil)
    }
    
    func showMandUpdateDialog(titleStr : String, desc : String) {
        let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "manddialogvc") as! MandIUpdateDialog
        viewController.dialogTitleStr = titleStr
        viewController.dialogDescStr = desc
        viewController.modalPresentationStyle = .fullScreen
        self.present(viewController, animated: true, completion: nil)
    }
    
    func validate() -> Bool {
        if (self.orderModel?.pickUpLatitude ?? 0.0 == 0.0 || self.orderModel?.pickUpLongitude ?? 0.0 == 0.0) {
            self.showBanner(title: "alert".localized, message: "searchfield_tooltip".localized, style: UIColor.INFO)
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
            
//            self.latitude = 28.537264
//            self.longitude = 47.726557
            
            
            UserDefaults.standard.setValue(self.latitude, forKey: Constants.LAST_LATITUDE)
            UserDefaults.standard.setValue(self.longitude, forKey: Constants.LAST_LONGITUDE)
            
            
            
            self.setUpGoogleMap()
        }
    }
    
    func updateModel(model: OTWOrder) {
        self.orderModel = model
    }
    
    func setUpGoogleMap() {
        let camera = GMSCameraPosition.camera(withLatitude: self.latitude ?? 0.0, longitude: self.longitude ?? 0.0, zoom: 11.0)
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
                            if lines[0].count > 0 {
                                strAddresMain = strAddresMain + lines[0]
                            }
                        }
                    }
                    
                    if lines.count > 1 {
                        if lines[1].count > 0 {
                            if strAddresMain.count > 0 {
                                strAddresMain = strAddresMain + ", \(lines[1])"
                            } else {
                                strAddresMain = strAddresMain + "\(lines[1])"
                            }
                        }
                    }
                    
                    if (strAddresMain.count > 0) {
                        
                        var strSubTitle = ""
                        if let locality = address.locality {
                            strSubTitle = locality
                        }
                        
                        if let administrativeArea = address.administrativeArea {
                            if strSubTitle.count > 0 {
                                strSubTitle = "\(strSubTitle), \(administrativeArea)"
                            }
                            else {
                                strSubTitle = administrativeArea
                            }
                        }
                        
                        if let country = address.country {
                            if strSubTitle.count > 0 {
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
            
            //            self.searchField.theme.font = UIFont.systemFont(ofSize: 13)
            //            self.searchField.startVisibleWithoutInteraction = true
            //            self.searchField.startSuggestingInmediately = true
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
                self.singleMarker?.icon = UIImage(named: "ic_shop_empty_selected")
                //snuff1
                let url = URL(string: "\(Constants.IMAGE_URL)\(shop.type?.selectedIcon ?? "")")
                self.applyMarkerImage(from: url!, to: self.singleMarker!)
                self.singleMarker?.map = self.gMap
                
                self.ivShop.isHidden = false
                self.viewShopDetails.isHidden = false
                self.viewClearField.isHidden = false
                
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
                let dataShop = DataShop(id: 0, name: prediction.name ?? "", address: prediction.vicinity ?? "", latitude: prediction.geometry?.location?.lat ?? 0.0, longitude: prediction.geometry?.location?.lng ?? 0.0, phoneNumber: "", workingHours: "", images: [String](), rate: prediction.rating ?? 0.0, type: TypeClass(id: 0, name: prediction.types?[0] ?? "", image: "", selectedIcon: "", icon: ""), ownerId: "", googlePlaceId: prediction.placeID ?? "", openNow: prediction.openingHours?.openNow ?? false, NearbyDriversCount : 0)
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
                self.singleMarker?.icon = UIImage(named: "ic_shop_empty_selected")
                // snuff1
                let url = URL(string: "\(Constants.IMAGE_URL)\(shop.type?.selectedIcon ?? "")")
                self.applyMarkerImage(from: url!, to: self.singleMarker!)
                self.singleMarker?.map = self.gMap
                
                self.ivShop.isHidden = false
                self.viewShopDetails.isHidden = false
                self.viewClearField.isHidden = false
                
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
    

    
    func addShopsMarkers() {
        self.gMap?.clear()
        for center in self.shops {
            let marker = GMSMarker()
            marker.position = CLLocationCoordinate2D(latitude: center.latitude ?? 0.0, longitude: center.longitude ?? 0.0)
            marker.title =  "\(center.id ?? 0)"
            marker.snippet = "\(center.phoneNumber ?? "")"
            self.singleMarker?.icon = UIImage(named: "ic_shop_empty")
            // snuff1
            let url = URL(string: "\(Constants.IMAGE_URL)\(center.type?.icon ?? "")")
            self.applyMarkerImage(from: url!, to: marker)
            self.singleMarker?.map = self.gMap
            marker.map = gMap
            self.shopMarkers.append(marker)
        }
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: self.latitude ?? 0.0, longitude: self.longitude ?? 0.0)
        marker.title =  "my_location"
        marker.snippet = ""
        marker.map = gMap
    }
    
    func filterShopsMarkers(selectedShopTypeId: Int) {
        self.gMap?.clear()
        let selectedShops = self.shops.filter({$0.type?.id == selectedShopTypeId})
        for center in selectedShops{
            let marker = GMSMarker()
            marker.position = CLLocationCoordinate2D(latitude: center.latitude ?? 0.0, longitude: center.longitude ?? 0.0)
            marker.title =  "\(center.id ?? 0)"
            marker.snippet = "\(center.phoneNumber ?? "")"
            self.singleMarker?.icon = UIImage(named: "ic_shop_empty")
            // snuff1
            let url = URL(string: "\(Constants.IMAGE_URL)\(center.type?.icon ?? "")")
            self.applyMarkerImage(from: url!, to: marker)
            self.singleMarker?.map = self.gMap
            marker.map = gMap
            self.shopMarkers.append(marker)
        }
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: self.latitude ?? 0.0, longitude: self.longitude ?? 0.0)
        marker.title =  "my_location"
        marker.snippet = ""
        marker.map = gMap
    }
    
    func showShopsList() {
        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AllShopsVC") as? AllShopsVC
        {
            vc.delegate = self
            vc.selectedCategory = self.selectdCategory?.id
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func applyMarkerImage(from url: URL, to marker: GMSMarker) {
        DispatchQueue.global(qos: .background).async {
            guard let data = try? Data(contentsOf: url),
                // let image = UIImage(data: data)?.cropped()
                let image = UIImage(data: data)
                else { return }
            
            DispatchQueue.main.async {
                marker.icon = self.imageWithImage(image: image, scaledToSize: CGSize(width: 48.0, height: 48.0))
                //  marker.icon = image
            }
        }
    }
    
    func imageWithImage(image:UIImage, scaledToSize newSize:CGSize) -> UIImage{
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
        
    // MARK: - UI Actions
    
    @IBAction func step1Action(_ sender: Any) {
        
    }
    
    @IBAction func step2Action(_ sender: Any) {
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
            initialViewControlleripad.modalPresentationStyle = .fullScreen
            self.present(initialViewControlleripad, animated: true, completion: {})
        }
    }
    
    @IBAction func searchAction(_ sender: Any) {
        
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
        self.viewClearField.isHidden = true
        self.gMap?.clear()
        self.getShopsList(radius: Float(Constants.DEFAULT_RADIUS), rating: 0)
        
        self.lblShopName.text = ""
        self.shopNameHeight.constant = 0
        self.viewPin.isHidden = false
        self.viewSuggest.isHidden = true
        
        let camera = GMSCameraPosition.camera(withLatitude: self.latitude ?? 0.0, longitude: self.longitude ?? 0.0, zoom: 11.0)
        self.gMap?.animate(to: camera)
        
    }
    
    
    @IBAction func suggestAction(_ sender: Any) {
        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SuggestShopVC") as? SuggestShopVC
        {
            vc.latitude = self.pinLatitude ?? 0.0
            vc.longitude = self.pinLongitude ?? 0.0
            self.navigationController?.pushViewController(vc, animated: true)
        }
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
        self.viewClearField.isHidden = true
        self.gMap?.clear()
        self.getShopsList(radius: Float(Constants.DEFAULT_RADIUS), rating: 0)
        
        self.lblShopName.text = ""
        self.shopNameHeight.constant = 0
        self.viewPin.isHidden = false
        self.viewSuggest.isHidden = true
        
        let camera = GMSCameraPosition.camera(withLatitude: self.latitude ?? 0.0, longitude: self.longitude ?? 0.0, zoom: 11.0)
        self.gMap?.animate(to: camera)
    }
    
    @IBAction func clearFieldAction2(_ sender: Any) {
        self.moreDetailsView.isHidden = true
        self.lblSearch.isHidden = false
        self.ivShop.image = nil
        self.edtMoreDetails.text = ""
        self.lblPickupLocation.text = ""
        self.searchField.text = ""
        self.ivShop.isHidden = true
        self.viewShopDetails.isHidden = true
        self.viewClearField.isHidden = true
        self.gMap?.clear()
        self.getShopsList(radius: Float(Constants.DEFAULT_RADIUS), rating: 0)
        
        self.lblShopName.text = ""
        self.shopNameHeight.constant = 0
        self.viewPin.isHidden = false
        self.viewSuggest.isHidden = true
        
        let camera = GMSCameraPosition.camera(withLatitude: self.latitude ?? 0.0, longitude: self.longitude ?? 0.0, zoom: 11.0)
        self.gMap?.animate(to: camera)
    }
    
    
    
    @IBAction func becomeDriverAction(_ sender: Any) {
        self.openShopList()
    }
    
    @IBAction func googleSearchAction(_ sender: Any) {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        
        let filter = GMSAutocompleteFilter()
        filter.country = "KW"
        autocompleteController.primaryTextColor = UIColor.black
        autocompleteController.secondaryTextColor = UIColor.black
        autocompleteController.tintColor = UIColor.black
        autocompleteController.autocompleteFilter = filter
        
        //        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        
        
        present(autocompleteController, animated: true, completion: nil)
    }
    
    @IBAction func checkMenuAction(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc : ShopMenuVC = storyboard.instantiateViewController(withIdentifier: "ShopMenuVC") as! ShopMenuVC
        vc.shopId = self.orderModel?.shop?.id ?? 0
        vc.selectedItems = self.selectedItems
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func showShopsList(_ sender: Any) {
        self.showShopsList()
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
            
            let shopData = ShopData(nearbyDriversCount: 0, id: self.orderModel?.shop?.id ?? 0, name: self.orderModel?.shop?.name ?? "", address: self.orderModel?.shop?.address ?? "", latitude: self.orderModel?.shop?.latitude ?? 0.0, longitude: self.orderModel?.shop?.longitude ?? 0.0, phoneNumber: self.orderModel?.shop?.phoneNumber ?? "", workingHours: self.orderModel?.shop?.workingHours ?? "", images: self.orderModel?.shop?.images ?? [String](), rate: self.orderModel?.shop?.rate ?? 0.0, type: self.orderModel?.shop?.type ?? TypeClass(id: 0, name: "",image: "", selectedIcon: "", icon: ""), ownerId: self.orderModel?.shop?.ownerId ?? "",googlePlaceId:  self.orderModel?.shop?.googlePlaceId ?? "", openNow: self.orderModel?.shop?.openNow ?? false)
            shopData.placeId = self.orderModel?.shop?.placeId ?? ""
            
            vc.shop = shopData
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
                let dataShop = DataShop(id: response.shopData?.id ?? 0, name: response.shopData?.name ?? "", address: response.shopData?.address ?? "", latitude: response.shopData?.latitude ?? 0.0, longitude: response.shopData?.longitude ?? 0.0, phoneNumber: response.shopData?.phoneNumber ?? "", workingHours: response.shopData?.workingHours ?? "", images: response.shopData?.images ?? [String](), rate: response.shopData?.rate ?? 0.0, type: response.shopData?.type ?? TypeClass(id: 0, name: "",image: "", selectedIcon: "", icon: ""),ownerId: response.shopData?.ownerId ?? "", googlePlaceId: response.shopData?.googlePlaceId ?? "", openNow : response.shopData?.openNow ?? false, NearbyDriversCount : response.shopData?.nearbyDriversCount ?? 0)
                self.orderModel?.shop = dataShop
                self.orderModel?.pickUpAddress = response.shopData?.name ?? ""
                self.orderModel?.pickUpLatitude = response.shopData?.latitude ?? 0.0
                self.orderModel?.pickUpLongitude = response.shopData?.longitude ?? 0.0
                
                self.lblShopName.text = response.shopData?.name ?? ""
                self.shopNameHeight.constant = 20
                
                self.moreDetailsView.isHidden = false
                self.lblSearch.isHidden = true
                self.viewShopDetails.isHidden = false
                self.viewClearField.isHidden = false
                
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
                self.singleMarker?.icon = UIImage(named: "ic_shop_empty_selected")
                // snuff1
                let url = URL(string: "\(Constants.IMAGE_URL)\(response.shopData?.type?.selectedIcon ?? "")")
                self.applyMarkerImage(from: url!, to: self.singleMarker!)
                self.singleMarker?.map = self.gMap
                
                self.handleOpenNow(shop: response.shopData)
                
                let camera = GMSCameraPosition.camera(withLatitude: self.orderModel?.pickUpLatitude ?? 0.0, longitude: self.orderModel?.pickUpLongitude ?? 0.0, zoom: 15.0)
                self.gMap?.animate(to: camera)
                
                if (self.orderModel?.shop?.id ?? 0 > 0) {
                    self.btnCheckMenu.isHidden = false
                    self.viewCheckMenu.isHidden = false
                    self.checkMenuAction(self)
                }else {
                    self.btnCheckMenu.isHidden = true
                    self.viewCheckMenu.isHidden = true
                    
                }
                if (self.orderModel?.selectedItems?.count ?? 0 > 0) {
                    self.selectedItems.append(contentsOf: self.orderModel?.selectedItems ?? [ShopMenuItem]())
                }
            }
            
            return true
        } else {
            return true
        }
        
    }
    
    
    func handleOpenNow(shop : ShopData?) {
        if (shop?.googlePlaceId?.count ?? 0 > 0) {
            let isOpen = shop?.openNow ?? false
            if (isOpen == false) {
                self.showBanner(title: "alert".localized, message: "this_shop_is_closed".localized, style: UIColor.INFO)
            }
        }else {
            let hours = shop?.workingHours?.split(separator: ",")
            let dayWeek = self.getWeekDay(shop : shop)
            if (hours?.count ?? 0 > dayWeek) {
                
                let hoursWithoutSpace = hours?[dayWeek].replacingOccurrences(of: " ", with: "")
                let hoursSplit = hoursWithoutSpace?.split(separator: "-")
                
                if (hoursSplit?.count ?? 0 > 0) {
                    let fromHour = hoursSplit?[0]
                    let toHour = hoursSplit?[1]
                    
                    let currentHour = self.getCurrentHour()
                    
                    
                    let fromHourOnly = String(fromHour?.prefix(2) ?? "00")
                    let fromHourInt = Int(fromHourOnly) ?? 0
                    
                    
                    let toHourOnly = String(toHour?.prefix(2) ?? "00")
                    let toHourInt = Int(toHourOnly) ?? 0
                    
                    if (currentHour <= toHourInt && currentHour >= fromHourInt) {
                        
                    }else {
                        self.showBanner(title: "alert".localized, message: "this_shop_is_closed".localized, style: UIColor.INFO)
                        
                    }
                }else {
                    
                }
                
            }else if (hours?.count ?? 0 > 0) {
                
            }
        }
    }
    
    
    func getWeekDay(shop : ShopData?) -> Int {
        var calendar = Calendar.current
        calendar.locale = Locale(identifier: "KW")
        var dayOfWeek = 0
        if (self.isArabic()) {
            if (shop?.googlePlaceId?.count ?? 0 > 0) {
                dayOfWeek = calendar.component(.weekday, from: Date()) + 2 - calendar.firstWeekday
            }else {
                dayOfWeek = calendar.component(.weekday, from: Date())  - calendar.firstWeekday
            }
            
        }else {
            dayOfWeek = calendar.component(.weekday, from: Date()) - calendar.firstWeekday
        }
        if dayOfWeek <= 0 {
            dayOfWeek += 7
        }
        return dayOfWeek
    }
    
    func getCurrentHour() -> Int {
        let date = Date()// Aug 25, 2017, 11:55 AM
        let calendar = Calendar.current
        
        let hour = calendar.component(.hour, from: date)
        
        return hour
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
        self.viewSuggest.isHidden = true
        
        self.ivShop.image = nil
        self.edtMoreDetails.text = ""
        self.ivShop.isHidden = true
        self.viewShopDetails.isHidden = true
        self.viewClearField.isHidden = true
        
    }
    
}

extension DeliveryStep1: UITextFieldDelegate {
    
    //    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    //
    //        //        if textField == self.searchField {
    //        //            let maxLength = 100
    //        //            let currentString: NSString = textField.text as NSString? ?? ""
    //        //            let newString: NSString =
    //        //                currentString.replacingCharacters(in: range, with: string) as NSString
    //        //            if (newString.length >= 3) {
    //        //                self.getShopsByName(name: newString as String, latitude: self.latitude ?? 0.0, longitude: self.longitude ?? 0.0, radius: Float(Constants.DEFAULT_RADIUS))
    //        //
    //        //                // self.getShopByPlaces(name: newString as String, latitude: self.latitude ?? 0.0, longitude: self.longitude ?? 0.0)
    //        //            }
    //        //            if (newString.length == 0) {
    //        //                self.gMap?.clear()
    //        //                self.getShopsList(radius: Float(Constants.DEFAULT_RADIUS), rating: 0)
    //        //            }
    //        //            return newString.length <= maxLength
    //        //        }
    //
    //        return false
    //    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if (textField == self.searchField) {
            let query = self.searchField.text ?? ""
            if (query.count > 0) {
                self.getShopsByName(name: query, latitude: self.latitude ?? 0.0, longitude: self.longitude ?? 0.0, radius: Float(Constants.DEFAULT_RADIUS))
            }else {
                self.gMap?.clear()
                self.getShopsList(radius: Float(Constants.DEFAULT_RADIUS), rating: 0)
            }
            textField.resignFirstResponder()
            return true
        }
        return false
    }
}

extension DeliveryStep1: GMSAutocompleteViewControllerDelegate {
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        //        let camera = GMSCameraPosition.camera(withLatitude:place.coordinate.latitude, longitude:place.coordinate.longitude, zoom: 17.0)
        dismiss(animated: true, completion: {
            
            self.searchField.text = ""
            self.orderModel?.pickUpLatitude = place.coordinate.latitude ?? 0.0
            self.orderModel?.pickUpLongitude = place.coordinate.longitude ?? 0.0
            self.orderModel?.shop = nil
            self.orderModel?.pickUpAddress = place.formattedAddress ?? ""
            self.lblPickupLocation.text = place.name ?? ""
            self.lblShopName.text = place.name ?? ""
            self.lblPickupLocation.textColor = UIColor.appDarkBlue
            
            self.moreDetailsView.isHidden = false
            self.viewShopDetails.isHidden = true
            self.viewClearField.isHidden = true
            self.lblSearch.isHidden = true
            
            self.view.endEditing(true)
            
            for marker in self.shopMarkers {
                marker.map = nil
            }
            
            self.singleMarker?.map = nil
            self.singleMarker = GMSMarker()
            self.singleMarker?.position = CLLocationCoordinate2D(latitude: place.coordinate.latitude , longitude: place.coordinate.longitude)
            self.singleMarker?.title =  "\(0)"
            self.singleMarker?.snippet = "\("")"
            self.singleMarker?.icon = UIImage(named: "ic_map_shop_selected")
            
            self.singleMarker?.map = self.gMap
            
            self.ivShop.isHidden = false
            
            self.ivShop.image = UIImage(named: "placeholder_order")
            
            
            self.edtMoreDetails.text = "\(place.name ?? "")\n\(place.formattedAddress ?? "")"
            
            self.lblShopName.text = place.name ?? ""
            self.shopNameHeight.constant = 20
            self.viewPin.isHidden = false
            self.viewSuggest.isHidden = true
            
            
            let camera = GMSCameraPosition.camera(withLatitude: self.orderModel?.pickUpLatitude ?? 0.0, longitude: self.orderModel?.pickUpLongitude ?? 0.0, zoom: 15.0)
            self.gMap?.animate(to: camera)
            
            
        })
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print("Error: ", error.localizedDescription)
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}

extension DeliveryStep1: ShopMenuDelegate {
    func onDone(items: [ShopMenuItem], total: Double) {
        var text = ""
        for item in items {
            var itemQuantity = item.quantity ?? 0
            if (itemQuantity == 0) {
                itemQuantity = item.count ?? 0
            }
            let doubleQuantity = Double(itemQuantity)
            let doublePrice = item.price ?? 0.0
            let total = doubleQuantity * doublePrice
            text = "\(text)\(itemQuantity) x (\(item.name ?? "")) -> (\(total)) \("currency".localized).\n"
        }
        self.orderModel?.selectedTotal = total
        self.orderModel?.edtOrderDetailsText = text
        self.selectedItems.removeAll()
        self.selectedItems.append(contentsOf: items)
    }
}
