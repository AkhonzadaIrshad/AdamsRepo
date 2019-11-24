//
//  ShopDetailsVC.swift
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
import Cosmos
import Branch

class ShopDetailsVC: BaseVC, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var viewBecomeDriver: CardView!
    
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    @IBOutlet weak var mapView: UIView!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var infoView: UIView!
    
    @IBOutlet weak var viewRegister: CardView!
    
    @IBOutlet weak var ivLogo: UIImageView!
    @IBOutlet weak var lblName: MyUILabel!
    @IBOutlet weak var lblAddress: MyUILabel!
    @IBOutlet weak var ratingView: CosmosView!
    @IBOutlet weak var lblDistance: MyUILabel!
    @IBOutlet weak var lblWorkingHours: MyUILabel!
    @IBOutlet weak var lblNearbyDrivers: MyUILabel!
    
    @IBOutlet weak var ivHandle: UIImageView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var collectionViewHright: NSLayoutConstraint!
    
    @IBOutlet weak var lblImages: MyUILabel!
    
    @IBOutlet weak var ivShare: UIButton!
    
    var latitude : Double?
    var longitude : Double?
    
    @IBOutlet weak var segmentHeight: NSLayoutConstraint!
    
    @IBOutlet weak var ivEdit: UIButton!
    
    @IBOutlet weak var lblOpenNow: MyUILabel!
    
    
    var currentZoom: Float = 0.0
    var gMap : GMSMapView?
    
    var shop : ShopData?
    
    var items = [ShopDelDatum]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (self.isArabic()) {
            self.ivHandle.image = UIImage(named: "ic_back_arabic")
        }
        self.infoView.isHidden = false
        gMap = GMSMapView()
        self.setUpGoogleMap()
        if ((self.loadUser().data?.roles?.contains(find: "Driver"))!) {
            self.viewBecomeDriver.isHidden = true
            self.segmentControl.isHidden = false
            self.tableView.isHidden = false
            
            self.viewRegister.isHidden = false
            
            ApiService.getShopPendingDeliveries(Authorization: self.loadUser().data?.accessToken ?? "", shopId: self.shop?.id ?? 0) { (response) in
                self.items.append(contentsOf: response.shopDelData ?? [ShopDelDatum]())
                self.tableView.delegate = self
                self.tableView.dataSource = self
                self.tableView.reloadData()
            }
        }else {
            self.tableView.isHidden = true
            self.viewBecomeDriver.isHidden = false
            self.segmentControl.isHidden = true
            self.segmentHeight.constant = 0
            
            self.viewRegister.isHidden = true
        }
        
        if (self.shop?.images?.count ?? 0 > 0) {
            let url = URL(string: "\(Constants.IMAGE_URL)\(self.shop?.images?[0] ?? "")")
            self.ivLogo.kf.setImage(with: url)
        }else if (self.shop?.type?.image?.count ?? 0 > 0){
            let url = URL(string: "\(Constants.IMAGE_URL)\(self.shop?.type?.image ?? "")")
            self.ivLogo.kf.setImage(with: url)
        }else {
            self.ivLogo.image = UIImage(named: "ic_place_store")
        }
        
        self.lblName.text = self.shop?.name ?? ""
        self.lblAddress.text = self.shop?.address ?? ""
        self.ratingView.rating = self.shop?.rate ?? 0.0
        self.lblDistance.text = self.getShopDistance()
        
        
        self.lblNearbyDrivers.text = "\((self.shop?.nearbyDriversCount ?? 0 + 10)) \("drivers".localized)"
        // Do any additional setup after loading the view.
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(enlargeImage))
        self.ivLogo.isUserInteractionEnabled = true
        self.ivLogo.addGestureRecognizer(singleTap)
        
        
        if (self.shop?.images?.count ?? 0 > 0) {
            self.collectionView.delegate = self
            self.collectionView.dataSource = self
            self.collectionView.reloadData()
        }else {
            self.collectionViewHright.constant = 0
            self.lblImages.isHidden = true
        }
        
        if (self.shop?.ownerId?.elementsEqual(self.loadUser().data?.userID ?? "") ?? false) {
            self.ivEdit.isHidden = false
        }else {
            self.ivEdit.isHidden = true
        }
        
        if (self.shop?.id == 0) {
            self.ivShare.isHidden = true
        }else {
            self.ivShare.isHidden = false
        }
        
        if (self.shop?.id ?? 0 == 0 && self.shop?.placeId ?? "" == "") {
            self.viewRegister.isHidden = true
            
        } else {
            if ((self.loadUser().data?.roles?.contains(find: "Driver"))!) {
                self.viewRegister.isHidden = false
            }else {
                self.viewRegister.isHidden = true
            }
            
        }
        
        if (self.shop?.googlePlaceId?.count ?? 0 > 0) {
            self.loadShopHours()
        }else {
            let hours = self.shop?.workingHours?.split(separator: ",")
            let dayWeek = self.getWeekDay()
            if (hours?.count ?? 0 > dayWeek) {
                self.lblWorkingHours.text = self.getTimeIn12HourFormat(item: String(hours?[dayWeek] ?? ""))
                
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
                        self.handleOpenNowViews(isOpen: true, show: true)
                    }else {
                        self.showBanner(title: "alert".localized, message: "this_shop_is_closed".localized, style: UIColor.INFO)
                        self.handleOpenNowViews(isOpen: false, show: true)
                    }
                }else {
                    self.lblWorkingHours.text = "---"
                    self.handleOpenNowViews(isOpen: false, show: false)
                }
                
            }else if (hours?.count ?? 0 > 0) {
                self.lblWorkingHours.text = "---"
                self.handleOpenNowViews(isOpen: false, show: false)
            }
        }
        
    }
    
    func loadShopHours() {
        self.showLoading()
        ApiService.getPlaceDetails(placeid: self.shop?.googlePlaceId ?? "") { (response) in
            self.hideLoading()
            let dayWeek = self.getWeekDay()
            let arr = response.detailsResult?.openingHours?.weekdayText
            if (arr?.count ?? 0 > dayWeek) {
                let item = response.detailsResult?.openingHours?.weekdayText?[dayWeek]
                self.lblWorkingHours.text = self.getTimeIn12HourFormat(item: item ?? "")
            }else {
                self.lblWorkingHours.text = "---"
                self.handleOpenNowViews(isOpen: false, show: false)
            }
            let bool = response.detailsResult?.openingHours?.openNow ?? false
            if (!bool) {
                self.showBanner(title: "alert".localized, message: "this_shop_is_closed".localized, style: UIColor.INFO)
                self.handleOpenNowViews(isOpen: false, show: true)
            }else {
                self.handleOpenNowViews(isOpen: true, show: true)
            }
        }
    }
    
    //collection delegates
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 80.0, height: 80.0)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.shop?.images?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ImageSliderVC") as? ImageSliderVC
        {
            vc.orderImages = self.shop?.images ?? [String]()
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: ShopImageCell = collectionView.dequeueReusableCell(withReuseIdentifier: "shopimagecell", for: indexPath as IndexPath) as! ShopImageCell
        
        let url = URL(string: "\(Constants.IMAGE_URL)\(self.shop?.images?[indexPath.row] ?? "")")
        cell.ivLogo.kf.setImage(with: url)
        
        return cell
        
    }
    
    func getTimeIn12HourFormat(item : String) -> String{
        if (item.count > 5) {
            var fromTime12Format = ""
            var toTime12Format = ""
            
            let times = item.split(separator: "-")
            let fromTime = String(times[0]).trim()
            let toTime = String(times[1]).trim()
            
            let fromSplit = fromTime.split(separator: ":")
            let fromHour = String(fromSplit[0])
            let fromMin = String(fromSplit[1])
            
            let integerFromHour = Int(fromHour) ?? 0
            if (integerFromHour < 12) {
                fromTime12Format = "\(integerFromHour):\(fromMin) \("am".localized)"
            }else if (integerFromHour > 12){
                fromTime12Format = "\(integerFromHour - 12):\(fromMin) \("pm".localized)"
            }else {
                fromTime12Format = "12:\(fromMin) \("pm".localized)"
            }
            
            
            
            let toSplit = toTime.split(separator: ":")
            let toHour = String(toSplit[0])
            let toMin = String(toSplit[1])
            
            let integerToHour = Int(toHour) ?? 0
            if (integerToHour < 12) {
                toTime12Format = "\(integerToHour):\(toMin) \("am".localized)"
            }else if (integerToHour > 12){
                toTime12Format = "\(integerToHour - 12):\(toMin) \("pm".localized)"
            }else {
                toTime12Format = "12:\(toMin) \("pm".localized)"
            }
            
            return "\(fromTime12Format) - \(toTime12Format)"
        }else {
            return item
        }
    }
    
    
    
    @objc func enlargeImage() {
        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ImageSliderVC") as? ImageSliderVC
        {
            var images = [String]()
            if (self.shop?.images?.count ?? 0 > 0) {
                images.append("\(self.shop?.images?[0] ?? "")")
            }else {
                images.append("\(self.shop?.type?.image ?? "")")
            }
            
            vc.orderImages = images
            self.navigationController?.pushViewController(vc, animated: true)
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
    
    func generateDeepLink() {
        
        var shareText = ""
        shareText = "shop_on_rzq".localized
        
        
        let buo = BranchUniversalObject.init(canonicalIdentifier: "rzqapp/\(self.shop?.id ?? 0)")
        buo.title = "\(self.shop?.name ?? "")"
        buo.contentDescription = shareText
        buo.imageUrl = "\(Constants.IMAGE_URL)\(self.shop?.images?[0] ?? "")"
        buo.publiclyIndex = true
        buo.locallyIndex = true
        buo.contentMetadata.customMetadata["ShopId"] = self.shop?.id ?? 0
        
        
        let lp: BranchLinkProperties = BranchLinkProperties()
        lp.channel = ""
        lp.feature = "sharing"
        lp.campaign = "Rzq App"
        lp.tags = ["Rzq App"]
        
        
        buo.getShortUrl(with: lp) { (url, error) in
            buo.showShareSheet(with: lp, andShareText: shareText, from: self) { (activityType, completed) in
            }
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 138.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = self.items[indexPath.row]
        
        let cell : DriverOrderCell = tableView.dequeueReusableCell(withIdentifier: "driverordercell", for: indexPath) as! DriverOrderCell
        
        cell.lblTitle.text = item.title ?? ""
        cell.lblMoney.text = "\(item.price ?? 0.0) \("currency".localized)"
        if (item.time ?? 0 > 0) {
            cell.lblTime.text = "\(item.time ?? 0) \("hours".localized)"
        }else {
            cell.lblTime.text = "asap".localized
        }
        
        
        let driverLatLng = CLLocation(latitude: self.latitude ?? 0.0, longitude: self.longitude ?? 0.0)
        let dropOffLatLng = CLLocation(latitude: item.toLatitude ?? 0.0, longitude: item.toLongitude ?? 0.0)
        let distanceInMeters = dropOffLatLng.distance(from: driverLatLng)
        let distanceInKM = distanceInMeters / 1000.0
        let distanceStr = String(format: "%.2f", distanceInKM)
        
        cell.lblDistance.text = "\(distanceStr) \("km".localized)"
        
        cell.onTake = {
            if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TakeOrderVC") as? TakeOrderVC
            {
                vc.deliveryId = item.id ?? 0
                vc.latitude = self.latitude
                vc.longitude = self.longitude
                
                vc.fromLatitude = item.fromLatitude ?? 0.0
                vc.fromLongitude = item.fromLongitude ?? 0.0
                vc.toLatitude = item.toLatitude ?? 0.0
                vc.toLongitude = item.toLongitude ?? 0.0
                vc.fromAddress = item.fromAddress ?? ""
                vc.toAddress = item.toAddress ?? ""
                vc.desc = item.title ?? ""
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        
        return cell
        
    }
    
    func setUpGoogleMap() {
        let camera = GMSCameraPosition.camera(withLatitude: self.shop?.latitude ?? 0.0, longitude: self.shop?.longitude ?? 0.0, zoom: 15.0)
        gMap = GMSMapView.map(withFrame: CGRect(x: 0, y: 0, width: self.mapView.frame.width, height: self.mapView.frame.height), camera: camera)
        gMap?.delegate = self
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: self.shop?.latitude ?? 0.0, longitude: self.shop?.longitude ?? 0.0)
        marker.title =  self.shop?.name ?? ""
        marker.icon = UIImage(named: "ic_map_shop")
        marker.snippet = self.shop?.address ?? ""
        marker.map = gMap
        
        self.mapView.addSubview(gMap!)
        gMap?.bindFrameToSuperviewBounds()
        self.view.layoutSubviews()
        
    }
    
    func getShopDistance() -> String {
        let userLatLng = CLLocation(latitude: self.latitude ?? 0.0, longitude: self.longitude ?? 0.0)
        let shopLatLng = CLLocation(latitude: self.shop?.latitude ?? 0.0, longitude: self.shop?.longitude ?? 0.0)
        let distanceInMeters = shopLatLng.distance(from: userLatLng)
        let distanceInKM = distanceInMeters / 1000.0
        let distanceStr = String(format: "%.2f", distanceInKM)
        return "\(distanceStr) \("km".localized)"
    }
    
    
    @IBAction func segmentChanged(_ sender: Any) {
        if (self.segmentControl.selectedSegmentIndex == 0) {
            self.infoView.isHidden = false
            self.tableView.isHidden = true
        }else {
            self.infoView.isHidden = true
            self.tableView.isHidden = false
        }
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func becomeDriverAction(_ sender: Any) {
        if (self.isLoggedIn()) {
            if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RegisterDriverVC") as? RegisterDriverVC
            {
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    @IBAction func workingHoursAction(_ sender: Any) {
        if (self.shop?.googlePlaceId?.count ?? 0 > 0) {
            
            self.showLoading()
            ApiService.getPlaceDetails(placeid: self.shop?.googlePlaceId ?? "") { (response) in
                self.hideLoading()
                let arr = response.detailsResult?.openingHours?.weekdayText ?? [String]()
                
                if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WorkingHoursVC") as? WorkingHoursVC
                {
                    vc.items = arr
                    if (self.shop?.googlePlaceId?.count ?? 0 > 0) {
                        vc.isGooglePlace = true
                    }else {
                        vc.isGooglePlace = false
                    }
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
            
            
        }else {
            let hours = (self.shop?.workingHours?.split(separator: ","))!
            var items = [String]()
            for hour in hours {
                items.append(String(hour))
            }
            if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WorkingHoursVC") as? WorkingHoursVC
            {
                vc.items = items
                if (self.shop?.googlePlaceId?.count ?? 0 > 0) {
                    vc.isGooglePlace = true
                }else {
                    vc.isGooglePlace = false
                }
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    @IBAction func shareAction(_ sender: Any) {
        self.generateDeepLink()
    }
    
    @IBAction func registerAction(_ sender: Any) {
        if (self.shop?.id ?? 0 > 0) {
            self.subscribeToShop()
        }else if (self.shop?.placeId?.count ?? 0 > 0) {
            self.subscribeToPlace()
        }else {
            self.showBanner(title: "alert".localized, message: "cant_subscribe", style: UIColor.INFO)
        }
        
    }
    
    
    func subscribeToPlace() {
        self.showLoading()
        ApiService.subscribeToPlace(Authorization: self.loadUser().data?.accessToken ?? "", id: shop?.placeId ?? "", name: shop?.name ?? "", address: shop?.address ?? "", latitude: shop?.latitude ?? 0.0, longitude: shop?.longitude ?? 0.0, phoneNumber: shop?.phoneNumber ?? "", workingHours: shop?.workingHours ?? "", image: "", rate: 0) { (response) in
            self.hideLoading()
            if (response.errorCode == 0) {
                self.showBanner(title: "alert".localized, message: "registered_to_shop".localized, style: UIColor.SUCCESS)
            }else {
                self.showBanner(title: "alert".localized, message: response.errorMessage ?? "", style: UIColor.INFO)
            }
        }
    }
    
    func subscribeToShop() {
        self.showLoading()
        ApiService.subscribeToShop(Authorization: self.loadUser().data?.accessToken ?? "", shopId: self.shop?.id ?? 0) { (response) in
            self.hideLoading()
            if (response.errorCode == 0) {
                self.showBanner(title: "alert".localized, message: "registered_to_shop".localized, style: UIColor.SUCCESS)
            }else {
                // self.showBanner(title: "alert".localized, message: response.errorMessage ?? "", style: UIColor.INFO)
                self.showBanner(title: "alert".localized, message: "registered_to_shop".localized, style: UIColor.SUCCESS)
            }
        }
    }
    
    
    @IBAction func editShopAction(_ sender: Any) {
        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "EditShopVC") as? EditShopVC
        {
            vc.shop = self.shop
            vc.latitude = self.latitude ?? 0.0
            vc.longitude = self.longitude ?? 0.0
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func getWeekDay() -> Int {
        var calendar = Calendar.current
        calendar.locale = Locale(identifier: "KW")
        var dayOfWeek = 0
        if (self.isArabic()) {
            if (self.shop?.googlePlaceId?.count ?? 0 > 0) {
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
    
    func handleOpenNowViews(isOpen : Bool, show: Bool) {
        if (show == false) {
            self.lblOpenNow.isHidden = true
            return
        }
        self.lblOpenNow.isHidden = false
        
        if (isOpen) {
            self.lblOpenNow.text = "open_now".localized
            self.lblOpenNow.textColor = UIColor.app_green
        }else {
            self.lblOpenNow.text = "closed_now".localized
            self.lblOpenNow.textColor = UIColor.app_red
        }
    }
    
}

extension ShopDetailsVC : GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        
    }
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        
    }
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        
        return true
    }
    
}
