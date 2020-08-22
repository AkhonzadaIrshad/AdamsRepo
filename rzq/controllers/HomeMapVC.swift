//
//  HomeMapVC.swift
//  rzq
//
//  Created by Zaid najjar on 3/31/19.
//  Copyright © 2019 technzone. All rights reserved.
//

import UIKit
import MaterialComponents
import FittedSheets
import GoogleMaps
import GooglePlaces
import MapKit
import CoreLocation
import SnapKit
import Firebase

class HomeMapVC: BaseViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var edtSearch: MyUITextField!
    
    @IBOutlet weak var mapView: UIView!
    
    @IBOutlet weak var btnMenu: UIButton!
    
    @IBOutlet weak var btnAbout: UIButton!
    @IBOutlet weak var btnLocation: UIButton!
    @IBOutlet weak var lblLocation: MyUILabel!
    
    @IBOutlet weak var viewOnTheWay: UIView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var navBar: NavBar!
    @IBOutlet weak var searchView: CardView!
    @IBOutlet weak var fullAdressTextView: UITextView!
    
    @IBOutlet weak var locationPartTextField: UITextField!
    @IBOutlet weak var streetTextField: UITextField!
    @IBOutlet weak var houseTextField: UITextField!
    
    // MARK: - Properties - public
    
    let cameraZoom : Float = 15.0
    
    var selectedRoute: NSDictionary!
    
    var markerLocation: GMSMarker?
    var currentZoom: Float = 0.0
    var gMap : GMSMapView?
    
    var latitude : Double?
    var longitude : Double?
    
    var shops = [DataShop]()
    var items = [DatumDel]()
    var shopMarkers = [GMSMarker]()
        
    var mModel : FilterModel?
    
    var polyline : GMSPolyline?
    var pickMarker : GMSMarker?
    var dropMarker : GMSMarker?
    
    var collectionViewFlowLayout : UICollectionViewFlowLayout?
    var timerDispatchSourceTimer : DispatchSourceTimer?
    
    weak var timer: Timer?
    
    // MARK: - Methodes - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        gMap = GMSMapView()
        self.navBar.delegate = self
        if DataManager.loadUser().data?.roles?.contains(find: "Driver") ?? false {
            self.navBar.isHidden = false
        } else {
            self.navBar.isHidden = true
        }
        self.btnMenu.addTarget(self, action: #selector(BaseViewController.onSlideMenuButtonPressed(_:)), for: UIControl.Event.touchUpInside)
        
        self.btnAbout.addTarget(self, action: #selector(BaseViewController.onAboutPressed(_:)), for: UIControl.Event.touchUpInside)
        
        self.edtSearch.delegate = self
        
        self.lblLocation.isHidden = true
        self.btnLocation.isHidden = true
        
        //snuff
        ApiService.updateRegId(Authorization: DataManager.loadUser().data?.accessToken ?? "", regId: Messaging.messaging().fcmToken ?? "not_avaliable") { (response) in
            
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(appCameToForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        
        self.validateDriverDueAmount()
        
        if (self.isProvider()) {
            self.getDriverOnGoingDeliveries()
        }
        self.setupLocationFields()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        LabasLocationManager.shared.delegate = self
        if (self.latitude ?? 0.0 == 0.0 || self.longitude ?? 0.0 == 0.0) {
            self.loadLastLocation()
            LabasLocationManager.shared.startUpdatingLocation()
        }else {
            self.setUpGoogleMap()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navBar.refreshCounters()
        self.checkForDeepLinkValues()
        self.handleNotification()
        
        let openMenu = UserDefaults.standard.value(forKey: Constants.OPEN_MENU) as? Bool ?? false
        if (openMenu) {
            UserDefaults.standard.setValue(false, forKey: Constants.OPEN_MENU)
            self.onSlideMenuButtonPressed(self.btnMenu)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionViewFlowLayout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout
    }
    
    // if appropriate, make sure to stop your timer in `deinit`
    deinit {
        stopTimer()
    }
    
    // MARK: - Methodes - UI Actions
    
    @IBAction func goToCurrentLocation(_ sender: Any) {
        let camera = GMSCameraPosition.camera(withLatitude: self.latitude ?? 0.0, longitude: self.longitude ?? 0.0, zoom: self.cameraZoom)
        self.gMap?.animate(to: camera)
    }
    
    @IBAction func openShopsFilter(_ sender: Any) {
        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FilterShopsVC") as? FilterShopsVC {
            vc.delegate = self
            vc.latitude = self.latitude
            vc.longitude = self.longitude
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func filterAction(_ sender: Any) {
        let sheetContent = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FilterSheet") as! FilterSheet
        
        sheetContent.delegate = self
        sheetContent.mModel = self.mModel
        let sheet = SheetViewController(controller: sheetContent, sizes: [.fullScreen, .fixed(self.view.frame.size.height - 50)])
        sheet.willDismiss = { _ in
            // This is called just before the sheet is dismissed
        }
        sheet.didDismiss = { _ in
            // This is called after the sheet is dismissed
        }
        self.present(sheet, animated: false, completion: nil)
    }
    
    @IBAction func onTheWayAction(_ sender: Any) {
        if (self.isLoggedIn()) {
            if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DeliveryStep1") as? DeliveryStep1 {
                vc.latitude = self.latitude
                vc.longitude = self.longitude
                vc.orderModel = OTWOrder()
                var address = self.fullAdressTextView.text ?? ""
                if let street = self.streetTextField.text {
                    address +=  " " + street
                }
                if let house = self.houseTextField.text {
                    address += " " + house
                }
                if let piece = self.locationPartTextField.text {
                    address +=  " " + piece
                }
                vc.orderModel?.dropOffAddress = address
                vc.orderModel?.dropOffLatitude = self.latitude
                vc.orderModel?.dropOffLongitude = self.longitude
                vc.fromHome = true
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    @IBAction func servicesAction(_ sender: Any) {
        if (self.isLoggedIn()) {
            if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ServiceStep1") as? ServiceStep1 {
                vc.latitude = self.latitude
                vc.longitude = self.longitude
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    @IBAction func tendersAction(_ sender: Any) {
        if (self.isLoggedIn()) {
            if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TenderStep1") as? TenderStep1 {
                vc.latitude = self.latitude
                vc.longitude = self.longitude
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    // MARK: - Methodes - Helpers
    func setupLocationFields() {
        self.houseTextField.placeholder = "homeMapVC.house.placeholder".localized
        self.locationPartTextField.placeholder = "homeMapVC.piece.placeholder".localized
        self.streetTextField.placeholder = "homeMapVC.street.placeholder".localized
    }
    
    func getDriverOnGoingDeliveries() {
        self.showLoading()
        ApiService.getDriverOnGoingDeliveries(Authorization: DataManager.loadUser().data?.accessToken ?? "") { (response) in
            self.hideLoading()
            UserDefaults.standard.setValue(response.data?.count ?? 0, forKey: Constants.WORKING_ORDERS_COUNT)
        }
    }
    
    func checkForDeepLinkValues() {
        if (App.shared.deepLinkShopId != nil && Int(App.shared.deepLinkShopId ?? "0") ?? 0 > 0) {
            //open shop
            ApiService.getShopDetails(Authorization: DataManager.loadUser().data?.accessToken ?? "", id: Int(App.shared.deepLinkShopId ?? "0")!) { (response) in
                if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ShopDetailsVC") as? ShopDetailsVC {
                    vc.latitude = self.latitude ?? 0.0
                    vc.longitude = self.longitude ?? 0.0
                    vc.shop = response.shopData!
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
            App.shared.deepLinkShopId = "0"
        }
    }
    
    
    @objc func appCameToForeground() {
        self.handleNotification()
    }
    
    func handleNotification() {
        let type = App.shared.notificationType ?? "0"
        let itemId = App.shared.notificationValue ?? "0"
        let deliveryId = App.shared.notificationDeliveryId ?? "0"
        switch type {
        case "0":
            //regular
            App.shared.notificationValue = "0"
            App.shared.notificationType = "0"
            App.shared.notificationDeliveryId = "0"
            break
        case "11":
            //chat
            App.shared.notificationValue = "0"
            App.shared.notificationType = "0"
            App.shared.notificationDeliveryId = "0"
            
            ApiService.getDelivery(id: Int(itemId)!) { (response) in
                DispatchQueue.main.async {
                    let messagesVC: ZHCDemoMessagesViewController = ZHCDemoMessagesViewController.init()
                    messagesVC.presentBool = true
                    
                    let order = DatumDel(id: response.data?.id ?? 0, title: response.data?.title ?? "", status: response.data?.status ?? 0, statusString: response.data?.statusString ?? "", image: "", createdDate: response.data?.createdDate ?? "", chatId: response.data?.chatId ?? 0, fromAddress: response.data?.fromAddress ?? "", fromLatitude: response.data?.fromLatitude ?? 0.0, fromLongitude: response.data?.fromLongitude ?? 0.0, toAddress: response.data?.toAddress ?? "", toLatitude: response.data?.toLatitude ?? 0.0, toLongitude: response.data?.toLongitude ?? 0.0, providerID: response.data?.driverId, providerName: "", providerImage: "", providerRate: 0, time: response.data?.time ?? 0, price: response.data?.cost ?? 0.0, serviceName: "",paymentMethod: response.data?.paymentMethod ?? 0, items: response.data?.items ?? [ShopMenuItem](),isPaid: response.data?.isPaid ?? false, invoiceId : response.data?.invoiceId ?? "", toFemaleOnly: response.data?.toFemaleOnly ?? false, shopId: response.data?.shopId ?? 0, OrderPrice: response.data?.orderPrice ?? 0.0, KnetCommission: response.data?.KnetCommission ?? 0.0, ClientPhone: response.data?.ClientPhone ?? "", ProviderPhone : response.data?.ProviderPhone ?? "")
                    
                    messagesVC.order = order
                    messagesVC.user = DataManager.loadUser()
                    let nav: UINavigationController = UINavigationController.init(rootViewController: messagesVC)
                    nav.modalPresentationStyle = .fullScreen
                    messagesVC.modalPresentationStyle = .fullScreen
                    self.navigationController?.present(nav, animated: true, completion: nil)
                }
            }
            
            break
        case "1":
            App.shared.notificationValue = "0"
            App.shared.notificationType = "0"
            App.shared.notificationDeliveryId = "0"
            App.shared.notificationSegmentIndex = 1
            self.openViewControllerBasedOnIdentifier("NotificationsVC")
            break
        case "2":
            App.shared.notificationValue = "0"
            App.shared.notificationType = "0"
            App.shared.notificationDeliveryId = "0"
            App.shared.notificationSegmentIndex = 0
            self.openViewControllerBasedOnIdentifier("NotificationsVC")
            break
        case "3":
            App.shared.notificationValue = "0"
            App.shared.notificationType = "0"
            App.shared.notificationDeliveryId = "0"
            App.shared.notificationSegmentIndex = 1
            self.openViewControllerBasedOnIdentifier("NotificationsVC")
            break
        case "4":
            App.shared.notificationValue = "0"
            App.shared.notificationType = "0"
            App.shared.notificationDeliveryId = "0"
            App.shared.notificationSegmentIndex = 0
            self.openViewControllerBasedOnIdentifier("NotificationsVC")
            break
        case "5":
            App.shared.notificationValue = "0"
            App.shared.notificationType = "0"
            App.shared.notificationDeliveryId = "0"
            App.shared.notificationSegmentIndex = 0
            self.openViewControllerBasedOnIdentifier("NotificationsVC")
            
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RateDriverDialog") as! RateDriverDialog
            vc.deliveryId = Int(deliveryId)
            self.definesPresentationContext = true
            vc.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
            vc.view.backgroundColor = UIColor.clear
            self.present(vc, animated: true, completion: nil)
            break
            
        case "6":
            App.shared.notificationValue = "0"
            App.shared.notificationType = "0"
            App.shared.notificationDeliveryId = "0"
            App.shared.notificationSegmentIndex = 0
            self.openViewControllerBasedOnIdentifier("WorkingOrdersVC")
            break
            
        //services
        case "13":
            App.shared.notificationValue = "0"
            App.shared.notificationType = "0"
            App.shared.notificationDeliveryId = "0"
            App.shared.notificationSegmentIndex = 1
            self.openViewControllerBasedOnIdentifier("NotificationsVC")
            break
            
        case "14":
            App.shared.notificationValue = "0"
            App.shared.notificationType = "0"
            App.shared.notificationDeliveryId = "0"
            App.shared.notificationSegmentIndex = 1
            self.openViewControllerBasedOnIdentifier("NotificationsVC")
            break
            
        case "15":
            App.shared.notificationValue = "0"
            App.shared.notificationType = "0"
            App.shared.notificationDeliveryId = "0"
            App.shared.notificationSegmentIndex = 0
            self.openViewControllerBasedOnIdentifier("WorkingOrdersVC")
            break
            
        case "16":
            App.shared.notificationValue = "0"
            App.shared.notificationType = "0"
            App.shared.notificationDeliveryId = "0"
            App.shared.notificationSegmentIndex = 0
            self.openViewControllerBasedOnIdentifier("NotificationsVC")
            break
            
        case "17":
            App.shared.notificationValue = "0"
            App.shared.notificationType = "0"
            App.shared.notificationDeliveryId = "0"
            App.shared.notificationSegmentIndex = 0
            self.openViewControllerBasedOnIdentifier("NotificationsVC")
            break
            
        case "18":
            App.shared.notificationValue = "0"
            App.shared.notificationType = "0"
            App.shared.notificationDeliveryId = "0"
            App.shared.notificationSegmentIndex = 0
            self.openViewControllerBasedOnIdentifier("NotificationsVC")
            break
            
        case "19":
            App.shared.notificationValue = "0"
            App.shared.notificationType = "0"
            App.shared.notificationDeliveryId = "0"
            App.shared.notificationSegmentIndex = 0
            self.openViewControllerBasedOnIdentifier("NotificationsVC")
            break
            
        default:
            //regular
            App.shared.notificationValue = "0"
            App.shared.notificationType = "0"
            App.shared.notificationDeliveryId = "0"
            break
        }
        
    }
    
    func scrollToNearestVisibleCollectionViewCell() {
        let visibleCenterPositionOfScrollView = Float(collectionView.contentOffset.x + (self.collectionView!.bounds.size.width / 2))
        var closestCellIndex = -1
        var closestDistance: Float = .greatestFiniteMagnitude
        for i in 0..<collectionView.visibleCells.count {
            let cell = collectionView.visibleCells[i]
            let cellWidth = cell.bounds.size.width
            let cellCenter = Float(cell.frame.origin.x + cellWidth / 2)
            
            // Now calculate closest cell
            let distance: Float = fabsf(visibleCenterPositionOfScrollView - cellCenter)
            if distance < closestDistance {
                closestDistance = distance
                closestCellIndex = collectionView.indexPath(for: cell)!.row
            }
        }
        if closestCellIndex != -1 {
            self.collectionView!.scrollToItem(at: IndexPath(row: closestCellIndex, section: 0), at: .centeredHorizontally, animated: true)
        }
        self.updateVisibleCell()
    }
    
    func updateVisibleCell() {
        let visibleRect = CGRect(origin: self.collectionView.contentOffset, size: self.collectionView.bounds.size)
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        let visibleIndexPath = self.collectionView.indexPathForItem(at: visiblePoint)
        let cell = self.collectionView.cellForItem(at: visibleIndexPath!) as! PendingOrderCell
        
        let count = UserDefaults.standard.value(forKey: Constants.NOTIFICATION_CHAT_COUNT) as? Int ?? 0
        if (count > 0) {
            cell.ivDot.isHidden = false
        }else {
            cell.ivDot.isHidden = true
        }
        
        let item = self.items[(visibleIndexPath?.row)!]
        self.getDriverLocation(item: item)
    }
            
    func stopTimer() {
        timer?.invalidate()
        timerDispatchSourceTimer?.cancel()
    }
    
    func getDriverLocation(item : DatumDel) {
        stopTimer()
        self.getDriverLocationAPI(item: item)
        if #available(iOS 10.0, *) {
            timer = Timer.scheduledTimer(withTimeInterval: Constants.TRACK_TIMER_DOUBLE, repeats: true) { [weak self] _ in
                // do something here
                self?.getDriverLocationAPI(item: item)
            }
            
        } else {
            // Fallback on earlier versions
            timerDispatchSourceTimer = DispatchSource.makeTimerSource(flags: [], queue: DispatchQueue.main)
            timerDispatchSourceTimer?.scheduleRepeating(deadline: .now(), interval: .seconds(Constants.TRACK_TIMER))
            timerDispatchSourceTimer?.setEventHandler{
                // do something here
                self.getDriverLocationAPI(item: item)
                
            }
            timerDispatchSourceTimer?.resume()
        }
    }
    
    
    func getDriverLocationAPI(item : DatumDel) {
        let visibleRect = CGRect(origin: self.collectionView.contentOffset, size: self.collectionView.bounds.size)
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        let visibleIndexPath = self.collectionView.indexPathForItem(at: visiblePoint)
        if (self.collectionView.visibleCells.count == 0) {
            return
        }
        guard let cell = self.collectionView.cellForItem(at: visibleIndexPath!) as? PendingOrderCell else {
            return
        }
        
        let count = UserDefaults.standard.value(forKey: Constants.NOTIFICATION_CHAT_COUNT) as? Int ?? 0
        if (count > 0) {
            cell.ivDot.isHidden = false
        }else {
            cell.ivDot.isHidden = true
        }
        
        ApiService.getOrderLocation(Authorization: DataManager.loadUser().data?.accessToken ?? "", deliveryId: item.id ?? 0) { (response) in
            let myLatLng = CLLocation(latitude: self.latitude ?? 0.0, longitude: self.longitude ?? 0.0)
            let driverLatLng = CLLocation(latitude: response.locationData?.latitude ?? 0.0, longitude: response.locationData?.longitude ?? 0.0)
            let distanceInMeters = driverLatLng.distance(from: myLatLng)
            let distanceInKM = distanceInMeters / 1000.0
            let distanceStr = String(format: "%.2f", distanceInKM)
            
            cell.lblDistance.text = "\(distanceStr) \("km".localized)"
            cell.lblTime.text = "\(String(format: "%.2f", (distanceInKM * 1.1))) \("minutes".localized)"
            if (response.locationData != nil) {
                if (item.status == Constants.ORDER_ON_THE_WAY) {
                    self.drawLocationLine(driverLocation: response.locationData!, order: item)
                }else if (item.status == Constants.ORDER_PROCESSING) {
                    if (item.time ?? 0 <= 1) {
                        self.drawLocationLine(driverLocation: response.locationData!, order: item)
                    }else {
                        self.polyline?.map = nil
                        self.pickMarker?.map = nil
                        self.dropMarker?.map = nil
                    }
                }else {
                    self.polyline?.map = nil
                    self.pickMarker?.map = nil
                    self.dropMarker?.map = nil
                }
            }
        }
    }
    
    
    func drawLocationLine(driverLocation : LocationData, order : DatumDel) {
        var fromLatitude : Double?
        var fromLongitude : Double?
        var toLatitude : Double?
        var toLongitude : Double?
        
        fromLatitude = driverLocation.latitude ?? 0.0
        fromLongitude = driverLocation.longitude ?? 0.0
        toLatitude = order.toLatitude ?? 0.0
        toLongitude = order.toLongitude ?? 0.0
        
        self.gMap?.clear()
        
        let pickUpPosition = CLLocationCoordinate2D(latitude: fromLatitude ?? 0.0, longitude: fromLongitude ?? 0.0)
        self.pickMarker = GMSMarker(position: pickUpPosition)
        self.pickMarker?.title = "track"
        self.pickMarker?.icon = UIImage(named: "ic_map_driver")
        self.pickMarker?.map = self.gMap
        
        
        let dropOffPosition = CLLocationCoordinate2D(latitude: toLatitude ?? 0.0, longitude: toLongitude ?? 0.0)
        self.dropMarker = GMSMarker(position: dropOffPosition)
        self.dropMarker?.title = "track"
        self.dropMarker?.icon = UIImage(named: "ic_location")
        self.dropMarker?.map = self.gMap
        
        var bounds = GMSCoordinateBounds()
        bounds = bounds.includingCoordinate(self.pickMarker?.position ?? CLLocationCoordinate2D(latitude: self.latitude ?? 0.0, longitude: self.longitude ?? 0.0))
        bounds = bounds.includingCoordinate(self.dropMarker?.position ?? CLLocationCoordinate2D(latitude: self.latitude ?? 0.0, longitude: self.longitude ?? 0.0))
        self.gMap?.animate(with: GMSCameraUpdate.fit(bounds, withPadding: 155.0))
        
    }
    
    
    func getShopsList(radius : Float, rating : Double, types : Int) {
        ApiService.getShops(latitude: self.latitude ?? 0.0, longitude: self.longitude ?? 0.0, radius: radius, rating : rating, types : types) { (response) in
            self.shops.removeAll()
            self.shops.append(contentsOf: response.dataShops ?? [DataShop]())
            self.addShopsMarkers()
        }
    }
    
    func getShopsByName(name : String, latitude : Double, longitude: Double, radius : Float) {
        ApiService.getShopsByName(name: name, latitude: latitude, longitude: longitude, radius: radius) { (response) in
            self.shops.removeAll()
            self.shops.append(contentsOf: response.dataShops ?? [DataShop]())
            self.addShopsMarkers()
        }
    }
    
    func showShopDetailsSheet(shop : ShopData) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ShopDetailsSheet") as! ShopDetailsSheet
        
        self.definesPresentationContext = true
        vc.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        vc.view.backgroundColor = UIColor.clear
        vc.delegate = self
        vc.shop = shop
        vc.latitude = self.latitude ?? 0.0
        vc.longitude = self.longitude ?? 0.0
        
        self.present(vc, animated: true, completion: nil)
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

    func loadLastLocation() {
        self.latitude = UserDefaults.standard.value(forKey: Constants.LAST_LATITUDE) as? Double ?? 0.0
        self.longitude = UserDefaults.standard.value(forKey: Constants.LAST_LONGITUDE) as? Double ?? 0.0
        
        let cllLocation = CLLocation(latitude: self.latitude ?? 0.0, longitude: self.longitude ?? 0.0)
        self.lblLocation.isHidden = false
        self.btnLocation.isHidden = false
        self.GetAnnotationUsingCoordinated(cllLocation)
        
        let camera = GMSCameraPosition.camera(withLatitude: self.latitude ?? 0.0, longitude: self.longitude ?? 0.0, zoom: self.cameraZoom)
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
        self.loadTracks()
    }
    
    func setUpGoogleMap() {
        let camera = GMSCameraPosition.camera(withLatitude: self.latitude ?? 0.0, longitude: self.longitude ?? 0.0, zoom: self.cameraZoom)
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
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.loadTracks()
        }
    }
    
    func encryptDriverName(name: String) -> String {
        var stars = ""
        let count = name.count - 2
        for _ in 1...count {
            stars = "\(stars)*"
        }
        let firstChar = name.first!
        let lastChar = name.last!
        let final = "\(String(firstChar))\(stars)\(String(lastChar))"
        return final
    }
    
    
    func loadTracks() {
        ApiService.getOnGoingDeliveries(Authorization: DataManager.loadUser().data?.accessToken ?? "") { (response) in
            self.items.removeAll()
            UserDefaults.standard.setValue(response.data?.count ?? 0, forKey: Constants.ORDERS_COUNT)
            for item in response.data ?? [DatumDel]() {
                if (item.status! == Constants.ORDER_ON_THE_WAY || item.status! == Constants.ORDER_PROCESSING) {
                    // if (item.status! == Constants.ORDER_ON_THE_WAY) {
                    self.items.append(item)
                }
            }
            if (self.items.count > 0) {
                self.collectionView.isHidden = false
                self.collectionView.delegate = self
                self.collectionView.dataSource = self
                self.collectionView.reloadData()
               // self.viewOnTheWay.isHidden = true
                self.viewOnTheWay.isHidden = false
                
                
                
                //snuff33
                let itm = self.items[0]
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.getDriverLocationAPI(item: itm)
                }
            }else {
                self.stopTimer()
                self.collectionView.isHidden = true
                self.polyline?.map = nil
                self.pickMarker?.map = nil
                self.dropMarker?.map = nil
                self.viewOnTheWay.isHidden = false
                //back to false when u want to show them
                self.stopTimer()
            }
            
        }
    }
    
    func validateDriverDueAmount() {
        if (self.isProvider()) {
            let check = DataManager.loadUser().data?.exceededDueAmount ?? false
            if (check) {
                //show alert
                self.showAlertOK(title: "alert".localized, message: "due_amount".localized, actionTitle: "ok".localized)
            }
        }
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
                        
                        self.lblLocation.text = strAddresMain
                        self.fullAdressTextView.text = strAddresMain
                    }
                    else {
                        
                        self.lblLocation.text = "Loading".localized
                    }
                }
                else {
                    
                    self.lblLocation.text = "Loading".localized
                }
            }
            else {
                self.lblLocation.text = "Loading".localized
            }
        }
    }
    
}

// MARK: - GMSMapViewDelegate

extension HomeMapVC : GMSMapViewDelegate {
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        let id = marker.title ?? "0"
        if (id.contains(find: "track")) {
            return true
        }
        if (id.contains(find: "my_location")) {
            return true
        }
        if (id == "0" || id == "") {
            return true
        }
        for mark in self.shopMarkers {
            mark.icon = UIImage(named: "ic_map_shop")
        }
        
        marker.icon = UIImage(named: "ic_map_shop_selected")
        let camera = GMSCameraPosition.camera(withLatitude: marker.position.latitude, longitude: marker.position.longitude, zoom: self.cameraZoom)
        self.gMap?.animate(to: camera)
        ApiService.getShopDetails(Authorization: DataManager.loadUser().data?.accessToken ?? "", id: Int(id)!) { (response) in
            self.showShopDetailsSheet(shop: response.shopData!)
        }
        
        return true
    }
    
}

// MARK: - UITextFieldDelegate

extension HomeMapVC: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField == self.edtSearch {
            let maxLength = 20
            let currentString: NSString = textField.text as NSString? ?? ""
            let newString: NSString =
                currentString.replacingCharacters(in: range, with: string) as NSString
            if (newString.length >= 3) {
                self.getShopsByName(name : newString as String, latitude: self.latitude ?? 0.0, longitude: self.longitude ?? 0.0, radius: Float(Constants.DEFAULT_RADIUS))
            }
            if (newString.length == 0) {
                self.gMap?.clear()
                self.getShopsList(radius: Float(Constants.DEFAULT_RADIUS), rating: 0, types : 0)
            }
            return newString.length <= maxLength
        }
        
        return false
    }
    
}

// MARK: - NavBarDelegate

extension HomeMapVC: NavBarDelegate {
    func goToHomeScreen() {
        self.slideMenuItemSelectedAtIndex(1)
    }
    
    func goToOrdersScreen() {
        self.slideMenuItemSelectedAtIndex(99)
    }
    
    func goToNotificationsScreen() {
        self.slideMenuItemSelectedAtIndex(3)
    }
    
    func goToProfileScreen() {
        self.slideMenuItemSelectedAtIndex(12)
    }
}

// MARK: - CollectionView delegates

extension HomeMapVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.bounds.width - 60.0, height: self.collectionView.bounds.height)
        
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
        return self.items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: PendingOrderCell = collectionView.dequeueReusableCell(withReuseIdentifier: "pendingordercell", for: indexPath as IndexPath) as! PendingOrderCell
        
        let count = UserDefaults.standard.value(forKey: Constants.NOTIFICATION_CHAT_COUNT) as? Int ?? 0
        if (count > 0) {
            cell.ivDot.isHidden = false
        }else {
            cell.ivDot.isHidden = true
        }
        
        let item = self.items[indexPath.row]
        let url = URL(string: "\(Constants.IMAGE_URL)\(item.providerImage ?? "")")
        cell.ivLogo.kf.setImage(with: url)
        
        cell.lblDriverName.text = self.encryptDriverName(name: item.providerName ?? "")
        cell.ratingView.rating = item.providerRate ?? 0.0
        
        cell.lblPrice.text = "\(item.price ?? 0.0) \("currency".localized)"
        cell.lblPayment.text = "cash".localized
        
        cell.onChat = {
            DispatchQueue.main.async {
                let messagesVC: ZHCDemoMessagesViewController = ZHCDemoMessagesViewController.init()
                messagesVC.presentBool = true
                messagesVC.order = item
                messagesVC.user = DataManager.loadUser()
                let nav: UINavigationController = UINavigationController.init(rootViewController: messagesVC)
                nav.modalPresentationStyle = .fullScreen
                messagesVC.modalPresentationStyle = .fullScreen
                self.navigationController?.present(nav, animated: true, completion: nil)
            }
        }
        
        self.getDriverLocation(item: item)
        
        return cell
        
    }
}

// MARK: - FilterSheetDelegate

extension HomeMapVC: FilterSheetDelegate {
    func onApply(radius: Float, rating: Double, types : Int, model : FilterModel) {
        gMap?.clear()
        self.mModel = FilterModel()
        self.mModel = model
        self.getShopsList(radius: radius, rating: rating, types : types)
    }
    
    func onClear() {
        gMap?.clear()
        self.mModel = FilterModel()
        self.getShopsList(radius: Float(Constants.DEFAULT_RADIUS), rating: 0, types : 0)
    }
}

// MARK: - ShopSheetDelegate

extension HomeMapVC: ShopSheetDelegate {
    func onOrder(order: OTWOrder) {
        if (self.isLoggedIn()) {
            if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DeliveryStep1") as? DeliveryStep1
            {
                vc.orderModel = OTWOrder()
                vc.orderModel = order
                vc.latitude = self.latitude
                vc.longitude = self.longitude
                vc.fromHome = true
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    func onDetails(shopData: ShopData) {
        self.hideLoading()
        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ShopDetailsVC") as? ShopDetailsVC
        {
            vc.latitude = self.latitude ?? 0.0
            vc.longitude = self.longitude ?? 0.0
            vc.shop = shopData
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

// MARK: - UIScrollViewDelegate

extension HomeMapVC: UIScrollViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollToNearestVisibleCollectionViewCell()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            scrollToNearestVisibleCollectionViewCell()
        }
    }
}

//MARK: - FilterListDelegate

extension HomeMapVC: FilterListDelegate {
    func onClick(shop: DataShop) {
        let camera = GMSCameraPosition.camera(withLatitude: shop.latitude ?? 0.0, longitude: shop.longitude ?? 0.0, zoom: self.cameraZoom)
        self.gMap?.animate(to: camera)
        // marker.icon = UIImage(named: "ic_map_shop_selected")
        ApiService.getShopDetails(Authorization: DataManager.loadUser().data?.accessToken ?? "", id: shop.id ?? 0) { (response) in
            self.showShopDetailsSheet(shop: response.shopData!)
        }
    }
}

//MARK: - LabasLocationManagerDelegate

extension HomeMapVC: LabasLocationManagerDelegate {
    
    func labasLocationManager(didUpdateLocation location: CLLocation) {
        
        self.latitude = location.coordinate.latitude
        self.longitude = location.coordinate.longitude
        
        UserDefaults.standard.setValue(self.latitude, forKey: Constants.LAST_LATITUDE)
        UserDefaults.standard.setValue(self.longitude, forKey: Constants.LAST_LONGITUDE)
        
        if (self.latitude ?? 0.0 == 0.0 || self.longitude ?? 0.0 == 0.0) {
            
            self.latitude = location.coordinate.latitude
            self.longitude = location.coordinate.longitude
            
            UserDefaults.standard.setValue(self.latitude, forKey: Constants.LAST_LATITUDE)
            UserDefaults.standard.setValue(self.longitude, forKey: Constants.LAST_LONGITUDE)
            
            self.hideLoading()
            self.setUpGoogleMap()
        }
        
        if (self.isProvider()) {
            ApiService.updateLocation(Authorization: DataManager.loadUser().data?.accessToken ?? "", latitude: location.coordinate.latitude, longitude: location.coordinate.longitude) { (response) in
                
            }
        }
        
        let cllLocation = CLLocation(latitude: self.latitude ?? 0.0, longitude: self.longitude ?? 0.0)
        self.lblLocation.isHidden = false
        self.btnLocation.isHidden = false
        self.GetAnnotationUsingCoordinated(cllLocation)
    }
}
