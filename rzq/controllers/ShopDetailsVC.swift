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

class ShopDetailsVC: BaseVC, UITableViewDelegate, UITableViewDataSource {
    
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
    
    
    var latitude : Double?
    var longitude : Double?
    
    @IBOutlet weak var segmentHeight: NSLayoutConstraint!
    
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
        
        if (self.shop?.image?.count ?? 0 > 0) {
            let url = URL(string: "\(Constants.IMAGE_URL)\(self.shop?.image ?? "")")
            self.ivLogo.kf.setImage(with: url)
        }else {
            let url = URL(string: "\(Constants.IMAGE_URL)\(self.shop?.type?.image ?? "")")
            self.ivLogo.kf.setImage(with: url)
        }
       
        
        self.lblName.text = self.shop?.name ?? ""
        self.lblAddress.text = self.shop?.address ?? ""
        self.ratingView.rating = self.shop?.rate ?? 0.0
        self.lblDistance.text = self.getShopDistance()
        
        
        let hours = self.shop?.workingHours?.split(separator: ",")
        let dayWeek = Calendar.current.component(.weekday, from: Date()) + 1
        if (hours?.count ?? 0 > dayWeek) {
         self.lblWorkingHours.text = String(hours?[dayWeek] ?? "")
        }else if (hours?.count ?? 0 > 0) {
            self.lblWorkingHours.text = String(hours?[0] ?? "")
        }
        
        self.lblNearbyDrivers.text = "\((self.shop?.nearbyDriversCount ?? 0 + 10)) \("drivers".localized)"
        // Do any additional setup after loading the view.
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(enlargeImage))
        self.ivLogo.isUserInteractionEnabled = true
        self.ivLogo.addGestureRecognizer(singleTap)
        
    }
    @objc func enlargeImage() {
            if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ImageSliderVC") as? ImageSliderVC
            {
                var images = [String]()
                  if (self.shop?.image?.count ?? 0 > 0) {
                    images.append("\(Constants.IMAGE_URL)\(self.shop?.image ?? "")")
                  }else {
                    images.append("\(Constants.IMAGE_URL)\(self.shop?.type?.image ?? "")")
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
        buo.imageUrl = "\(Constants.IMAGE_URL)\(self.shop?.image ?? "")"
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
        let hours = (self.shop?.workingHours?.split(separator: ","))!
        var items = [String]()
        for hour in hours {
            items.append(String(hour))
        }
        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WorkingHoursVC") as? WorkingHoursVC
        {
            vc.items = items
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func shareAction(_ sender: Any) {
        self.generateDeepLink()
    }
    
    @IBAction func registerAction(_ sender: Any) {
        self.showLoading()
        ApiService.subscribeToShop(Authorization: self.loadUser().data?.accessToken ?? "", shopId: self.shop?.id ?? 0) { (response) in
            self.hideLoading()
            if (response.errorCode == 0) {
                self.showBanner(title: "alert".localized, message: "registered_to_shop".localized, style: UIColor.SUCCESS)
            }else {
                self.showBanner(title: "alert".localized, message: response.errorMessage ?? "", style: UIColor.INFO)
            }
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
