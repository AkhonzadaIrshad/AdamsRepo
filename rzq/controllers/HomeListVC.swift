//
//  HomeListVC.swift
//  rzq
//
//  Created by Zaid najjar on 4/2/19.
//  Copyright © 2019 technzone. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation
import GoogleMaps
import GooglePlaces
import FittedSheets

class HomeListVC: BaseViewController, UITableViewDelegate, UITableViewDataSource,LabasLocationManagerDelegate,FilterSheetDelegate {

    @IBOutlet weak var btnMenu: UIButton!
    
    @IBOutlet weak var searchField: MyUITextField!
    
    @IBOutlet weak var btnABout: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var lblLocation: MyUILabel!
    @IBOutlet weak var btnLocation: UIButton!
    
    var shops = [DataShop]()
    
    var latitude : Double?
    var longitude : Double?
    var mModel : FilterModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
         self.btnMenu.addTarget(self, action: #selector(BaseViewController.onSlideMenuButtonPressed(_:)), for: UIControl.Event.touchUpInside)
        
         self.btnABout.addTarget(self, action: #selector(BaseViewController.onAboutPressed(_:)), for: UIControl.Event.touchUpInside)
        
        self.searchField.delegate = self
        
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 110.0
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        
        LabasLocationManager.shared.delegate = self
        LabasLocationManager.shared.startUpdatingLocation()
        
      
        ApiService.updateRegId(Authorization: self.loadUser().data?.accessToken ?? "", regId: Messaging.messaging().fcmToken ?? "not_avaliable") { (response) in
            
        }
        
         NotificationCenter.default.addObserver(self, selector: #selector(appCameToForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        
        self.validateDriverDueAmount()
        
    }
    
    func validateDriverDueAmount() {
        if (self.isProvider()) {
            let check = self.loadUser().data?.exceededDueAmount ?? false
            if (check) {
                //show alert
                self.showAlertOK(title: "alert".localized, message: "due_amount".localized, actionTitle: "ok".localized)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.checkForDeepLinkValues()
        self.handleNotification()
    }
    func checkForDeepLinkValues() {
        if (App.shared.deepLinkShopId != nil && Int(App.shared.deepLinkShopId ?? "0") ?? 0 > 0) {
            //open shop
            ApiService.getShopDetails(Authorization: self.loadUser().data?.accessToken ?? "", id: Int(App.shared.deepLinkShopId ?? "0")!) { (response) in
                if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ShopDetailsVC") as? ShopDetailsVC
                {
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
        switch type {
        case "0":
            //regular
            App.shared.notificationValue = "0"
            App.shared.notificationType = "0"
            break
        case "11":
            //chat
            App.shared.notificationValue = "0"
            App.shared.notificationType = "0"
            
            ApiService.getDelivery(id: Int(itemId)!) { (response) in
                DispatchQueue.main.async {
                    let messagesVC: ZHCDemoMessagesViewController = ZHCDemoMessagesViewController.init()
                    messagesVC.presentBool = true
                    
//                    let order = DatumDel(driverID: "", canReport: false, canTrack: false, id: response.data?.id ?? 0, chatId: response.data?.chatId ?? 0, fromAddress: response.data?.fromAddress ?? "", toAddress: response.data?.toAddress ?? "", title: response.data?.title ?? "", status: response.data?.status ?? 0, price: response.data?.cost ?? 0.0, time: response.data?.time ?? 0, statusString: response.data?.statusString ?? "", image: "", createdDate: response.data?.createdDate ?? "", toLatitude: response.data?.toLatitude ?? 0.0, toLongitude: response.data?.toLatitude ?? 0.0, fromLatitude: response.data?.fromLatitude ?? 0.0, fromLongitude: response.data?.fromLongitude ?? 0.0, driverName: "", driverImage: "", driverRate: 0, canRate: false, canCancel: false, canChat: false)
                    
                    let order = DatumDel(id: response.data?.id ?? 0, title: response.data?.title ?? "", status: response.data?.status ?? 0, statusString: response.data?.statusString ?? "", image: "", createdDate: response.data?.createdDate ?? "", chatId: response.data?.chatId ?? 0, fromAddress: response.data?.fromAddress ?? "", fromLatitude: response.data?.fromLatitude ?? 0.0, fromLongitude: response.data?.fromLongitude ?? 0.0, toAddress: response.data?.toAddress ?? "", toLatitude: response.data?.toLatitude ?? 0.0, toLongitude: response.data?.toLongitude ?? 0.0, providerID: response.data?.driverId, providerName: "", providerImage: "", providerRate: 0, time: response.data?.time ?? 0, price: response.data?.cost ?? 0.0, serviceName: "", paymentMethod: response.data?.paymentMethod ?? 0, items: response.data?.items ?? [ShopMenuItem](), isPaid: response.data?.isPaid ?? false, invoiceId: response.data?.invoiceId ?? "", toFemaleOnly: response.data?.toFemaleOnly ?? false, shopId: response.data?.shopId ?? 0, OrderPrice: response.data?.orderPrice ?? 0.0, KnetCommission: response.data?.KnetCommission ?? 0.0)
                    
                    
                    messagesVC.order = order
                    messagesVC.user = self.loadUser()
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
            self.openViewControllerBasedOnIdentifier("NotificationsVC")
            break
        case "2":
            App.shared.notificationValue = "0"
            App.shared.notificationType = "0"
            self.openViewControllerBasedOnIdentifier("NotificationsVC")
            break
        case "3":
            App.shared.notificationValue = "0"
            App.shared.notificationType = "0"
            self.openViewControllerBasedOnIdentifier("NotificationsVC")
            break
        case "4":
            App.shared.notificationValue = "0"
            App.shared.notificationType = "0"
            self.openViewControllerBasedOnIdentifier("NotificationsVC")
            break
        case "5":
            App.shared.notificationValue = "0"
            App.shared.notificationType = "0"
            self.openViewControllerBasedOnIdentifier("NotificationsVC")
            break
        case "6":
            App.shared.notificationValue = "0"
            App.shared.notificationType = "0"
            self.openViewControllerBasedOnIdentifier("OrdersVC")
            break
        default:
            //regular
            App.shared.notificationValue = "0"
            App.shared.notificationType = "0"
            break
        }
        
    }
    
    
    //tableview delegates
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.shops.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let shop = self.shops[indexPath.row]
        self.showLoading()
        ApiService.getShopDetails(Authorization: self.loadUser().data?.accessToken ?? "", id: shop.id ?? 0, completion: { (response) in
            self.hideLoading()
            if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ShopDetailsVC") as? ShopDetailsVC
            {
                vc.latitude = self.latitude ?? 0.0
                vc.longitude = self.longitude ?? 0.0
                vc.shop = response.shopData
                self.navigationController?.pushViewController(vc, animated: true)
            }
        })
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
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : ShopCell = tableView.dequeueReusableCell(withIdentifier: "shopcell", for: indexPath) as! ShopCell
        
        let shop = self.shops[indexPath.row]
        
        if (shop.images?.count ?? 0 > 0) {
            let url = URL(string: "\(Constants.IMAGE_URL)\(shop.images?[0] ?? "")")
            cell.ivLogo.kf.setImage(with: url)
        }else {
            let url = URL(string: "\(Constants.IMAGE_URL)\(shop.type?.image ?? "")")
            cell.ivLogo.kf.setImage(with: url)
        }
        
        
        cell.lblName.text = shop.name ?? ""
        cell.lblAddress.text = shop.address ?? ""
        cell.lblRate.text = "\(shop.rate ?? 0.0)"
        cell.lblType.text = self.getShopType(type : shop.type?.id ?? 0)
        cell.lblDistance.text = self.getShopDistance(latitude: shop.latitude ?? 0.0, longitude: shop.longitude ?? 0.0)
        
        return cell
    }
    
    
    @IBAction func onTheWayAction(_ sender: Any) {
        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DeliveryStep1") as? DeliveryStep1
        {
            vc.orderModel = OTWOrder()
            vc.fromHome = true
            vc.latitude = self.latitude ?? 0.0
            vc.longitude = self.longitude ?? 0.0
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    
    func getShopType(type : Int) -> String {
        switch type {
        case Constants.PLACE_BAKERY:
            return "bakery".localized
        case Constants.PLACE_BOOK_STORE:
            return "book_store".localized
        case Constants.PLACE_CAFE:
            return "cafe".localized
        case Constants.PLACE_MEAL_DELIVERY:
            return "meal_delivery".localized
        case Constants.PLACE_MEAL_TAKEAWAY:
            return "meal_takeaway".localized
        case Constants.PLACE_PHARMACY:
            return "pharmacy".localized
        case Constants.PLACE_RESTAURANT:
            return "restaurant".localized
        case Constants.PLACE_SHOPPING_MALL:
            return "shopping_mall".localized
        case Constants.PLACE_STORE:
            return "store".localized
        case Constants.PLACE_SUPERMARKET:
            return "super_market".localized
        default:
            return "shop".localized
        }
    }
    
    
    func labasLocationManager(didUpdateLocation location: CLLocation) {
        if (self.latitude ?? 0.0 == 0.0 || self.longitude ?? 0.0 == 0.0) {
            self.latitude = location.coordinate.latitude
            self.longitude = location.coordinate.longitude
            self.hideLoading()
            
            if (self.isProvider()) {
                ApiService.updateLocation(Authorization: self.loadUser().data?.accessToken ?? "", latitude: location.coordinate.latitude, longitude: location.coordinate.longitude) { (response) in
                    
                }
            }
            
            let cllLocation = CLLocation(latitude: self.latitude ?? 0.0, longitude: self.longitude ?? 0.0)
            self.lblLocation.isHidden = false
            self.btnLocation.isHidden = false
            self.GetAnnotationUsingCoordinated(cllLocation)
            
            self.getShopsList(radius: Float(Constants.DEFAULT_RADIUS), rating: 0, types : 0)
            
        }
    }
    
    func getShopDistance(latitude : Double, longitude : Double) -> String {
        let userLatLng = CLLocation(latitude: self.latitude ?? 0.0, longitude: self.longitude ?? 0.0)
        let shopLatLng = CLLocation(latitude: latitude, longitude: longitude)
        let distanceInMeters = shopLatLng.distance(from: userLatLng)
        let distanceInKM = distanceInMeters / 1000.0
        let distanceStr = String(format: "%.2f", distanceInKM)
        return "\(distanceStr) \("km".localized)"
    }
    
    func getShopsList(radius : Float, rating : Double, types : Int) {
        ApiService.getShops(latitude: self.latitude ?? 0.0, longitude: self.longitude ?? 0.0, radius: radius, rating : rating, types : types) { (response) in
            self.shops.removeAll()
            self.shops.append(contentsOf: response.dataShops ?? [DataShop]())
            self.tableView.reloadData()
        }
    }
    
    func getShopsByName(name : String, latitude : Double, longitude: Double, radius : Float) {
        ApiService.getShopsByName(name: name, latitude: latitude, longitude: longitude, radius: radius) { (response) in
            self.shops.removeAll()
            self.shops.append(contentsOf: response.dataShops ?? [DataShop]())
            self.tableView.reloadData()
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
    
    
    @IBAction func filterAction(_ sender: Any) {
        let sheetContent = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FilterSheet") as! FilterSheet
        //        // Do any additional setup after loading the view, typically from a nib.
        //        let bottomSheet = MDCBottomSheetController(contentViewController: sheetContent)
        //
        //        bottomSheet.preferredContentSize = CGSize(width: self.view.frame.size.width, height: self.view.frame.size.height - 50)
        //        self.present(bottomSheet, animated: true, completion: nil)
        
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
    
    func onApply(radius: Float, rating: Double, types : Int, model : FilterModel) {
        self.mModel = model
        self.getShopsList(radius: radius, rating: rating, types : types)
    }
    
    func onClear() {
        self.mModel = FilterModel()
        self.getShopsList(radius: Float(Constants.DEFAULT_RADIUS), rating: 0, types : 0)
    }
    
}

extension HomeListVC: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField == self.searchField {
            let maxLength = 20
            let currentString: NSString = textField.text as NSString? ?? ""
            let newString: NSString =
                currentString.replacingCharacters(in: range, with: string) as NSString
            if (newString.length >= 3) {
                self.getShopsByName(name : newString as String, latitude: self.latitude ?? 0.0, longitude: self.longitude ?? 0.0, radius: Float(Constants.DEFAULT_RADIUS))
            }
            if (newString.length == 0) {
                self.getShopsList(radius: Float(Constants.DEFAULT_RADIUS), rating: 0, types : 0)
            }
            return newString.length <= maxLength
        }
        
        return false
    }
    
}
