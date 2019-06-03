//
//  NotificationsVC.swift
//  rzq
//
//  Created by Zaid najjar on 4/3/19.
//  Copyright © 2019 technzone. All rights reserved.
//

import UIKit
import CoreLocation
import Sheeeeeeeeet

class NotificationsVC: BaseViewController, UITableViewDelegate, UITableViewDataSource,LabasLocationManagerDelegate, AcceptBidDelegate, RateDriverDelegate {
    
    @IBOutlet weak var btnMenu: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var emptyView: EmptyView!
    
    @IBOutlet weak var btnAbout: UIButton!
    
    @IBOutlet weak var lblSortBy: MyUILabel!
    
    var items = [DatumNot]()
    
    var latitude : Double?
    var longitude : Double?
    
    var sortBy : Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.lblSortBy.text = "date".localized
        
        self.btnMenu.addTarget(self, action: #selector(BaseViewController.onSlideMenuButtonPressed(_:)), for: UIControl.Event.touchUpInside)
        
          self.btnAbout.addTarget(self, action: #selector(BaseViewController.onAboutPressed(_:)), for: UIControl.Event.touchUpInside)
        
        LabasLocationManager.shared.delegate = self
        LabasLocationManager.shared.startUpdatingLocation()
        
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 138.0
        
        // Do any additional setup after loading the view.
    }
    
    func updateNotifications() {
        self.items.removeAll()
        ApiService.getAllNotifications(Authorization: self.loadUser().data?.accessToken ?? "", sortBy: self.sortBy ?? 1) { (response) in
            self.items.removeAll()
            self.items.append(contentsOf: response.data ?? [DatumNot]())
            if (self.items.count > 0) {
                self.emptyView.isHidden = true
                self.tableView.delegate = self
                self.tableView.dataSource = self
                self.tableView.reloadData()
            }else {
                self.emptyView.isHidden = false
            }
      }
    }
    
    @IBAction func sortByAction(_ sender: Any) {
        let actionSheet = createSortSheet()
        actionSheet.appearance.title.textColor = UIColor.colorPrimary
        actionSheet.present(in: self, from: self.view)
    }
    
    func createSortSheet() -> ActionSheet {
        let title = ActionSheetTitle(title: "sort_notifications_by".localized)
        
        let appearance = ActionSheetAppearance()
        
        appearance.title.font = UIFont(name: self.getFontName(), size: 16)
        appearance.sectionTitle.font = UIFont(name: self.getFontName(), size: 14)
        appearance.sectionTitle.subtitleFont = UIFont(name: self.getFontName(), size: 14)
        appearance.item.subtitleFont = UIFont(name: self.getFontName(), size: 14)
        appearance.item.font = UIFont(name: self.getFontName(), size: 14)
        
        let item1 = ActionSheetItem(title: "date".localized, value: 1, image: UIImage(named: "ic_sheet_date"))
        let item2 = ActionSheetItem(title: "distance".localized, value: 2, image: UIImage(named: "ic_sheet_distance"))
        let item3 = ActionSheetItem(title: "price".localized, value: 3, image: UIImage(named: "ic_sheet_price"))
        
        let actionSheet = ActionSheet(items: [title,item1,item2,item3]) { sheet, item in
            if let value = item.value as? Int {
                switch (value) {
                case 1:
                    //nearby
                    self.lblSortBy.text = "date".localized
                    self.sortBy = 1
                    self.updateNotifications()
                    break
                case 2:
                    //low price
                    self.lblSortBy.text = "distance".localized
                    self.sortBy = 2
                    self.updateNotifications()
                    break
                case 3:
                    //rating
                    self.lblSortBy.text = "price".localized
                    self.sortBy = 3
                    self.updateNotifications()
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
    

    func labasLocationManager(didUpdateLocation location: CLLocation) {
        if (self.latitude ?? 0.0 == 0.0 || self.longitude ?? 0.0 == 0.0) {
            self.latitude = location.coordinate.latitude
            self.longitude = location.coordinate.longitude
            self.updateNotifications()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        ApiService.getAllNotifications(Authorization: self.loadUser().data?.accessToken ?? "", sortBy: self.sortBy ?? 1) { (response) in
            self.items.removeAll()
            self.items.append(contentsOf: response.data ?? [DatumNot]())
            if (self.items.count > 0) {
              self.emptyView.isHidden = true
                self.tableView.delegate = self
                self.tableView.dataSource = self
                self.tableView.reloadData()
            }else {
              self.emptyView.isHidden = false
            }
            
        }
        UserDefaults.standard.setValue(0, forKey: Constants.NOTIFICATION_COUNT)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        let item = self.items[indexPath.row]
//        switch item.type {
//        case Constants.DELIVERY_CREATED:
//            return 138.0
//        case Constants.BID_CREATED:
//            return 138.0
//        default:
//            return 78.0
//        }
//    }
    
    func reloadFromRateDriver() {
        self.refreshNotifications()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let item = self.items[indexPath.row]
//        if (item.type == Constants.DELIVERY_COMPLETED) {
//            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RateDriverDialog") as! RateDriverDialog
//            vc.deliveryId = item.deliveryID ?? 0
//            self.definesPresentationContext = true
//            vc.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
//            vc.view.backgroundColor = UIColor.clear
//            self.present(vc, animated: true, completion: nil)
//        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = self.items[indexPath.row]
        switch item.type {
        case Constants.DELIVERY_CREATED:
            let cell : DriverOrderCell = tableView.dequeueReusableCell(withIdentifier: "driverordercell", for: indexPath) as! DriverOrderCell
            
            let dict = item.data?.convertToDictionary()
            
            let fromLatitude = dict?["FromLatitude"] as? Double ?? 0.0
            let fromLongitude = dict?["FromLongitude"] as? Double ?? 0.0
            let toLatitude = dict?["ToLatitude"] as? Double ?? 0.0
            let toLongitude = dict?["ToLongitude"] as? Double ?? 0.0
            let fromAddress = dict?["FromAddress"] as? String ?? ""
            let toAddress = dict?["ToAddress"] as? String ?? ""
            let desc = dict?["Description"] as? String ?? ""
            let clientName = dict?["UserName"] as? String ?? ""
            let shopImage = dict?["ShopImage"] as? String ?? ""
            
            if (shopImage.count > 0) {
                let url = URL(string: "\(Constants.IMAGE_URL)\(shopImage)")
                cell.ivLogo.kf.setImage(with: url)
            }
            if (item.type == 1) {
                cell.ivType.image = UIImage(named: "ic_drive")
            }else {
                cell.ivType.image = UIImage(named: "ic_tool")
            }
            
            cell.lblTitle.text = desc
            let price = dict?["EstimatedPrice"] as? Double ?? 0.0
            if (price > 10) {
                cell.lblMoney.text = "> 10 \("currency".localized)"
            }else {
                cell.lblMoney.text = "< 10 \("currency".localized)"
            }
//            cell.lblMoney.text = "\(dict?["EstimatedPrice"] as? Double ?? 0.0) \("currency".localized)"
            let time = dict?["EstimatedTime"] as? Int ?? 0
            
            if (time > 0) {
             cell.lblTime.text = "\(dict?["EstimatedTime"] as? Int ?? 0) \("hours".localized)"
            }else {
                cell.lblTime.text = "asap".localized
            }
            
            let driverLatLng = CLLocation(latitude: self.latitude ?? 0.0, longitude: self.longitude ?? 0.0)
            let dropOffLatLng = CLLocation(latitude: toLatitude, longitude: toLongitude)
            let distanceInMeters = dropOffLatLng.distance(from: driverLatLng)
            let distanceInKM = distanceInMeters / 1000.0
            let distanceStr = String(format: "%.2f", distanceInKM)
            
            cell.lblDistance.text = "\(distanceStr) \("km".localized)"
            
            cell.onTake = {
                if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TakeOrderVC") as? TakeOrderVC
                {
                    vc.deliveryId = item.orderID ?? 0
                    vc.latitude = self.latitude
                    vc.longitude = self.longitude
                    
                    vc.fromLatitude = fromLatitude
                    vc.fromLongitude = fromLongitude
                    vc.toLatitude = toLatitude
                    vc.toLongitude = toLongitude
                    vc.fromAddress = fromAddress
                    vc.toAddress = toAddress
                    vc.clientsName = clientName
                    vc.desc = desc
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
            
            return cell
        case Constants.DELIVERY_CANCELLED:
            let cell : RegularAlertCell = tableView.dequeueReusableCell(withIdentifier: "regularalertcell", for: indexPath) as! RegularAlertCell
            
            let dict = item.data?.convertToDictionary()
            
            let arabicTitle = dict?["ArabicTitle"] as? String ?? ""
            let englishTitle = dict?["EnglishTitle"] as? String ?? ""
            
            let arabicBody = dict?["ArabicBody"] as? String ?? ""
            let englishBody = dict?["EnglishBody"] as? String ?? ""
            
            if (self.isArabic()) {
                cell.lblTitle.text = arabicTitle
                cell.lblDescription.text = arabicBody
            }else {
                cell.lblTitle.text = englishTitle
                cell.lblDescription.text = englishBody
            }
            
            return cell
        case Constants.BID_CREATED:
            let cell : DriverBidCell = tableView.dequeueReusableCell(withIdentifier: "driverbidcell", for: indexPath) as! DriverBidCell
            
            let dict = item.data?.convertToDictionary()
            
            let shopImage = dict?["ShopImage"] as? String ?? ""
            
            if (shopImage.count > 0) {
                let url = URL(string: "\(Constants.IMAGE_URL)\(shopImage)")
                cell.ivLogo.kf.setImage(with: url)
            }
            
            
            var desc = ""
            if (self.isArabic()) {
              desc = dict?["ArabicBody"] as? String ?? ""
            }else {
              desc = dict?["EnglishBody"] as? String ?? ""
            }
            let distance = dict?["Distance"] as? Double ?? 0.0
            
            cell.lblTitle.text = desc
            cell.lblMoney.text = "\(dict?["Price"] as? Double ?? 0.0) \("currency".localized)"
            let time = dict?["Time"] as? Int ?? 0
            if (time > 0) {
                cell.lblTime.text = "\(dict?["Time"] as? Int ?? 0) \("hours".localized)"
            }else {
                cell.lblTime.text = "asap".localized
            }
            
            let distanceStr = String(format: "%.2f", (distance / 1000.0))
            
            cell.lblDistance.text = "\(distanceStr) \("km".localized)"
            
            cell.onCheck = {
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AcceptBidDialog") as! AcceptBidDialog
                self.definesPresentationContext = true
                vc.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
                vc.view.backgroundColor = UIColor.clear
              let notificationId = dict?["Id"] as? Int ?? 0
                vc.item = item
                vc.notificationId = notificationId
                vc.delegate = self
                
                self.present(vc, animated: true, completion: nil)
            }
            
            return cell
        case Constants.ON_THE_WAY:
            let cell : RegularAlertCell = tableView.dequeueReusableCell(withIdentifier: "regularalertcell", for: indexPath) as! RegularAlertCell
            
            let dict = item.data?.convertToDictionary()
            
            let arabicTitle = dict?["ArabicTitle"] as? String ?? ""
            let englishTitle = dict?["EnglishTitle"] as? String ?? ""
            
            let arabicBody = dict?["ArabicBody"] as? String ?? ""
            let englishBody = dict?["EnglishBody"] as? String ?? ""
            
            if (self.isArabic()) {
                cell.lblTitle.text = arabicTitle
                cell.lblDescription.text = arabicBody
            }else {
                cell.lblTitle.text = englishTitle
                cell.lblDescription.text = englishBody
            }
            
            return cell
            
        case Constants.DELIVERY_COMPLETED:
            let cell : OrderCompletedCell = tableView.dequeueReusableCell(withIdentifier: "ordercompletedcell", for: indexPath) as! OrderCompletedCell
            
            let dict = item.data?.convertToDictionary()
            
            let arabicTitle = dict?["ArabicTitle"] as? String ?? ""
            let englishTitle = dict?["EnglishTitle"] as? String ?? ""
            
            let arabicBody = dict?["ArabicBody"] as? String ?? ""
            let englishBody = dict?["EnglishBody"] as? String ?? ""
            
            if (self.isArabic()) {
                cell.lblTitle.text = arabicTitle
                cell.lblDesc.text = arabicBody
            }else {
                cell.lblTitle.text = englishTitle
                cell.lblDesc.text = englishBody
            }
            cell.btnRate.setTitle("rate_driver".localized, for: .normal)
            
            cell.onRate = {
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RateDriverDialog") as! RateDriverDialog
                vc.deliveryId = item.orderID ?? 0
                vc.delegate = self
                vc.notificationId = item.id ?? 0
                self.definesPresentationContext = true
                vc.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
                vc.view.backgroundColor = UIColor.clear
                self.present(vc, animated: true, completion: nil)
            }
            
            return cell
        case Constants.BID_ACCEPTED:
            let cell : RegularAlertCell = tableView.dequeueReusableCell(withIdentifier: "regularalertcell", for: indexPath) as! RegularAlertCell
            
            let dict = item.data?.convertToDictionary()
            
            let arabicTitle = dict?["ArabicTitle"] as? String ?? ""
            let englishTitle = dict?["EnglishTitle"] as? String ?? ""
            
            let arabicBody = dict?["ArabicBody"] as? String ?? ""
            let englishBody = dict?["EnglishBody"] as? String ?? ""
            
            if (self.isArabic()) {
                cell.lblTitle.text = arabicTitle
                cell.lblDescription.text = arabicBody
            }else {
                cell.lblTitle.text = englishTitle
                cell.lblDescription.text = englishBody
            }
            return cell
            
            //service
        case Constants.SERVICE_CREATED:
            let cell : DriverOrderCell = tableView.dequeueReusableCell(withIdentifier: "driverordercell", for: indexPath) as! DriverOrderCell
            
            let dict = item.data?.convertToDictionary()
            
            let toLatitude = dict?["ToLatitude"] as? Double ?? 0.0
            let toLongitude = dict?["ToLongitude"] as? Double ?? 0.0
            var serviceName = ""
            if (self.isArabic()) {
               serviceName = dict?["ServiceArabicName"] as? String ?? ""
            }else {
               serviceName = dict?["ServiceEnglishName"] as? String ?? ""
            }
            let toAddress = dict?["ToAddress"] as? String ?? ""
            let desc = dict?["Description"] as? String ?? ""
            let clientName = dict?["UserName"] as? String ?? ""
            let serviceImage = dict?["ServiceImage"] as? String ?? ""
            
            if (serviceImage.count > 0) {
                let url = URL(string: "\(Constants.IMAGE_URL)\(serviceImage)")
                cell.ivLogo.kf.setImage(with: url)
            }
            
            if (item.type == 1) {
                cell.ivType.image = UIImage(named: "ic_drive")
            }else {
                cell.ivType.image = UIImage(named: "ic_tool")
            }
            
            cell.lblTitle.text = desc
            let price = dict?["EstimatedPrice"] as? Double ?? 0.0
            if (price > 10) {
                cell.lblMoney.text = "> 10 \("currency".localized)"
            }else {
                cell.lblMoney.text = "< 10 \("currency".localized)"
            }
            //            cell.lblMoney.text = "\(dict?["EstimatedPrice"] as? Double ?? 0.0) \("currency".localized)"
            let time = dict?["EstimatedTime"] as? Int ?? 0
            
            if (time > 0) {
                cell.lblTime.text = "\(dict?["EstimatedTime"] as? Int ?? 0) \("hours".localized)"
            }else {
                cell.lblTime.text = "asap".localized
            }
            
            let driverLatLng = CLLocation(latitude: self.latitude ?? 0.0, longitude: self.longitude ?? 0.0)
            let dropOffLatLng = CLLocation(latitude: toLatitude, longitude: toLongitude)
            let distanceInMeters = dropOffLatLng.distance(from: driverLatLng)
            let distanceInKM = distanceInMeters / 1000.0
            let distanceStr = String(format: "%.2f", distanceInKM)
            
            cell.lblDistance.text = "\(distanceStr) \("km".localized)"
            
            cell.onTake = {
                if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TakeServiceOrderVC") as? TakeServiceOrderVC
                {
                    vc.deliveryId = item.orderID ?? 0
                    vc.latitude = self.latitude
                    vc.longitude = self.longitude
                    vc.toLatitude = toLatitude
                    vc.toLongitude = toLongitude
                    vc.toAddress = toAddress
                    vc.clientsName = clientName
                    vc.desc = desc
                    vc.serviceName = serviceName
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
            
            return cell
            
            
        case Constants.SERVICE_BID_CREATED:
            let cell : DriverBidCell = tableView.dequeueReusableCell(withIdentifier: "driverbidcell", for: indexPath) as! DriverBidCell
            
            let dict = item.data?.convertToDictionary()
            
            let shopImage = dict?["ServiceImage"] as? String ?? ""
            
            if (shopImage.count > 0) {
                let url = URL(string: "\(Constants.IMAGE_URL)\(shopImage)")
                cell.ivLogo.kf.setImage(with: url)
            }
            
            
            var desc = ""
            if (self.isArabic()) {
                desc = dict?["ArabicBody"] as? String ?? ""
            }else {
                desc = dict?["EnglishBody"] as? String ?? ""
            }
            
            let Droplatitude = dict?["Latitude"] as? Double ?? 0.0
            let Droplongitude = dict?["Longitude"] as? Double ?? 0.0
            
            cell.lblTitle.text = desc
            cell.lblMoney.text = "\(dict?["Price"] as? Double ?? 0.0) \("currency".localized)"
            let time = dict?["Time"] as? Int ?? 0
            if (time > 0) {
                cell.lblTime.text = "\(dict?["Time"] as? Int ?? 0) \("hours".localized)"
            }else {
                cell.lblTime.text = "asap".localized
            }
            
            let driverLatLng = CLLocation(latitude: self.latitude ?? 0.0, longitude: self.longitude ?? 0.0)
            let dropOffLatLng = CLLocation(latitude: Droplatitude, longitude: Droplongitude)
            let distanceInMeters = dropOffLatLng.distance(from: driverLatLng)
            let distanceInKM = distanceInMeters / 1000.0
            
            let distanceStr = String(format: "%.2f", distanceInKM)
            
            cell.lblDistance.text = "\(distanceStr) \("km".localized)"
            
            cell.onCheck = {
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AcceptBidDialog") as! AcceptBidDialog
                self.definesPresentationContext = true
                vc.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
                vc.view.backgroundColor = UIColor.clear
                let notificationId = dict?["Id"] as? Int ?? 0
                vc.item = item
                vc.notificationId = notificationId
                vc.delegate = self
                
                self.present(vc, animated: true, completion: nil)
            }
            
            return cell
            
        case Constants.SERVICE_COMPLETED:
            let cell : OrderCompletedCell = tableView.dequeueReusableCell(withIdentifier: "ordercompletedcell", for: indexPath) as! OrderCompletedCell
            
            let dict = item.data?.convertToDictionary()
            
            let arabicTitle = dict?["ArabicTitle"] as? String ?? ""
            let englishTitle = dict?["EnglishTitle"] as? String ?? ""
            
            let arabicBody = dict?["ArabicBody"] as? String ?? ""
            let englishBody = dict?["EnglishBody"] as? String ?? ""
            
            if (self.isArabic()) {
                cell.lblTitle.text = arabicTitle
                cell.lblDesc.text = arabicBody
            }else {
                cell.lblTitle.text = englishTitle
                cell.lblDesc.text = englishBody
            }
            
            cell.btnRate.setTitle("rate_provider".localized, for: .normal)
            
            cell.onRate = {
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RateDriverDialog") as! RateDriverDialog
                vc.deliveryId = item.orderID ?? 0
                vc.delegate = self
                vc.notificationId = item.id ?? 0
                self.definesPresentationContext = true
                vc.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
                vc.view.backgroundColor = UIColor.clear
                self.present(vc, animated: true, completion: nil)
            }
            
            return cell
            
            
            
            
            
            
            
            
        default:
            let cell : RegularAlertCell = tableView.dequeueReusableCell(withIdentifier: "regularalertcell", for: indexPath) as! RegularAlertCell
            
            let dict = item.data?.convertToDictionary()
            
            let arabicTitle = dict?["ArabicTitle"] as? String ?? ""
            let englishTitle = dict?["EnglishTitle"] as? String ?? ""
            
            let arabicBody = dict?["ArabicBody"] as? String ?? ""
            let englishBody = dict?["EnglishBody"] as? String ?? ""
            
            if (self.isArabic()) {
                cell.lblTitle.text = arabicTitle
                cell.lblDescription.text = arabicBody
            }else {
                cell.lblTitle.text = englishTitle
                cell.lblDescription.text = englishBody
            }
            
            return cell
        }
        
    }
    
    func refreshNotifications() {
        ApiService.getAllNotifications(Authorization: self.loadUser().data?.accessToken ?? "", sortBy: self.sortBy ?? 1) { (response) in
            self.items.removeAll()
            self.items.append(contentsOf: response.data ?? [DatumNot]())
            if (self.items.count > 0) {
                self.emptyView.isHidden = true
                self.tableView.delegate = self
                self.tableView.dataSource = self
                self.tableView.reloadData()
            }else {
                self.emptyView.isHidden = false
            }
            
        }
    }
    
    
    func onAccept() {
        let mainStoryboardIpad : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let initialViewControlleripad : UIViewController = mainStoryboardIpad.instantiateViewController(withIdentifier: self.getHomeView()) as! UINavigationController
        self.present(initialViewControlleripad, animated: true, completion: {})
    }
    
    
}
