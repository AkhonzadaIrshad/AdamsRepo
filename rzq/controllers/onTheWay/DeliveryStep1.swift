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
import MultilineTextField
import Branch

class Cell: ScalingCarouselCell {}

class DeliveryStep1: BaseVC , Step3Delegate, AllShopDelegate, ImagePickerDelegate, UITextViewDelegate, LabasLocationManagerDelegate {
   
    // MARK: - Outlets
    
    @IBOutlet weak var ShopsCarouselView: ScalingCarouselView!
    @IBOutlet weak var searchByKeyWordsBackgroundView: UIView!
    @IBOutlet weak var searchByKeywordTableView: UITableView!
    @IBOutlet weak var searchByKeyWordsView: UIView!
    @IBOutlet weak var shopNaleKabel: MyUILabel!
    @IBOutlet weak var lblImages: MyUILabel!
    @IBOutlet weak var viewImages: UIView!
    @IBOutlet weak var viewRecording: UIView!
    @IBOutlet weak var bgRecord: UIImageView!
    @IBOutlet weak var edtOrderDetails: MultilineTextField!
    @IBOutlet weak var btnRecord: UIButton!
    @IBOutlet weak var btnPlay: UIButton!
    @IBOutlet weak var gif: UIImageView!
    @IBOutlet weak var buttomSheet: UIView!
    @IBOutlet weak var actionSheetConstraintBottom: NSLayoutConstraint!
    @IBOutlet weak var customAlert: CustomAlert!
    
    var imagePicker: UIImagePickerController!
    var audioPlayer: AVAudioPlayer?
    var selectedImages = [UIImage]()
    let recorder = KAudioRecorder.shared
    var isZoomed: Bool = false
    var place: GMSPlace?

    @IBOutlet weak var lblPickupLocation: MyUILabel!
    @IBOutlet weak var mapView: UIView!
    //@IBOutlet weak var edtMoreDetails: MyUITextField!
    @IBOutlet weak var searchField: SearchTextField!
    @IBOutlet weak var viewParentSearch: CardView!
    @IBOutlet weak var ivHandle: UIImageView!
    @IBOutlet weak var ivShop: CircleImage!
    @IBOutlet weak var viewShopDetails: CardView!
    @IBOutlet weak var viewClearField: CardView!
    @IBOutlet weak var viewCheckMenu: CardView!
    @IBOutlet weak var viewSuggest: UIStackView!
    @IBOutlet weak var viewPin: UIStackView!
    
    @IBOutlet weak var btnCurrentLocation: UIButton!
    @IBOutlet weak var ivIndicator: UIImageView!
    @IBOutlet weak var lblSearch: MyUILabel!
    @IBOutlet weak var viewBecomeDriver: UIView!
    @IBOutlet weak var ivGoogle: UIButton!
    @IBOutlet weak var btnListView: UIButton!
    @IBOutlet weak var lblViewList: UILabel!
    @IBOutlet weak var btnCheckMenu: MyUIButton!
    @IBOutlet weak var viewPop: UIView!
    @IBOutlet weak var collectionCategories: UICollectionView!
    
    @IBOutlet weak var shopsSearchTableView: UITableView!
    @IBOutlet weak var searchShopsTextField: UITextField!
    
    @IBOutlet weak var catFilterSearchStack: UIStackView!
    
    // MARK: - Variables
    let locationManager = CLLocationManager()
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
    var selectedCarouselShops = [DataShop]() {
        didSet {
            self.ShopsCarouselView.reloadData()
        }
    }
    var shops = [DataShop]() {
        didSet {
            self.shopsSearchTableView.reloadData()
        }
    }
    var allShops = [DataShop]()
    var selectAllCategory: Bool = false
    var isFromSearch: Bool = false
    var fromdeepLink: Bool = false
    var shopeID: Int?
    var filterShops = [DataShop]()
    var shopMarkers = [GMSMarker]()
    var selectdCategory: TypeClass?
    var selectedItems = [ShopMenuItem]()
    var categories = [TypeClass]()
    var searchedShops: [DataShop] {
        self.shops.filter({
            return ($0.name?.uppercased().contains(find: self.searchedText?.uppercased() ?? "") ?? false ) && $0.type?.id == self.selectdCategory?.id
        })
    }
    var searchedText: String?
    var edtMoreDetails: String?
    var autocompleteResults :[GApiResponse.Autocomplete] = []
    var myscale = CGFloat()
    let dispatchGroup = DispatchGroup()


    // MARK: - Methods
 
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        ShopsCarouselView.deviceRotated()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        ShopsCarouselView.deviceRotated()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        searchField.clearButtonMode = .whileEditing
        ShopsCarouselView.backgroundColor = .clear
        var displayToolView =  UserDefaults.standard.value(forKey: "displayToolView") as? Int ?? 0
        if displayToolView < 2 {
            displayToolView += 1
            let gradientColor = UIColor.colorPrimary
            let gradientColor2 = UIColor.colorPrimary
            let preference = ToolTipPreferences()
            preference.drawing.bubble.gradientColors = [gradientColor, gradientColor2]
            btnCurrentLocation.showToolTip(identifier: "", message: "tool.message".localized, arrowPosition: .right, preferences: preference, delegate: nil)
            UserDefaults.standard.set(displayToolView, forKey: "displayToolView")
        }
        
        let nib = UINib.init(nibName: "FilterSearchCell", bundle: nil)
        searchByKeywordTableView?.register(nib, forCellReuseIdentifier: "filtersearchcell")
      
        let nibCarousel = UINib.init(nibName: "ScalingCarouselCell", bundle: nil)
        ShopsCarouselView.register(nibCarousel, forCellWithReuseIdentifier: "ScalingCarouselCell")
        
        searchByKeywordTableView?.rowHeight = UITableView.automaticDimension
        searchByKeywordTableView?.estimatedRowHeight = 45.0
        
        self.locationManager.delegate = self
        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()
        self.edtOrderDetails.delegate = self
            
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        self.btnCheckMenu.setTitle("Check Menu".localized, for: .normal)
        viewLoad()
        let swipeDownGesture = UISwipeGestureRecognizer(target: self, action: #selector(self.hideActionSheet))
        swipeDownGesture.direction = .down
        self.buttomSheet.addGestureRecognizer(swipeDownGesture)
        
        let swipeUpGesture = UISwipeGestureRecognizer(target: self, action: #selector(self.showActionSheet))
        swipeUpGesture.direction = .up
        self.buttomSheet.addGestureRecognizer(swipeUpGesture)
        self.customAlert.configureAsStep1()
        self.shopsSearchTableView.delegate = self
        self.shopsSearchTableView.dataSource = self
        self.searchShopsTextField.delegate = self
        self.searchShopsTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        if !fromdeepLink {
            self.setUpGoogleMap()
            self.hideActionSheet()

        } else {
            self.setUpGoogleMap()
            displayShop(shopId: shopeID ?? 0)
        }

        if DataManager.loadUser().data?.roles?.contains(find: "Driver") == true {
            latitude = LabasLocationManager.shared.currentLocation?.coordinate.latitude ?? 0
            longitude = LabasLocationManager.shared.currentLocation?.coordinate.longitude ?? 0
        } else {
            if (self.latitude ?? 0.0 == 0.0 || self.longitude ?? 0.0 == 0.0) {
                self.showLoading()
                LabasLocationManager.shared.delegate = self
                LabasLocationManager.shared.startUpdatingLocation()
            }else {
                self.setUpGoogleMap()
            }
               // self.latitude = UserDefaults.standard.value(forKey: Constants.LAST_LATITUDE) as? Double ?? 0.0
               // self.longitude = UserDefaults.standard.value(forKey: Constants.LAST_LONGITUDE) as? Double ?? 0.0
        }
    }
    
    @objc func textFieldDidChange() {
        self.searchedText = self.searchShopsTextField.text
        if searchShopsTextField.text?.isEmpty ?? true {
            self.shopsSearchTableView.isHidden = true
        } else {
            self.shopsSearchTableView.isHidden = false
            self.shopsSearchTableView.reloadData()
        }
    }
    @objc func hideActionSheet() {
        self.actionSheetConstraintBottom.constant = 55 - self.buttomSheet.frame.height
    }
    
    @objc func showActionSheet() {
        self.actionSheetConstraintBottom.constant = 0
    }
    
    func textViewDidChange(_ textView: UITextView) {
        self.orderModel?.orderDetails = textView.text
    }
    
    @objc public func textDidChanged(_ textField: MyUITextField) {
        self.orderModel?.orderDetails = textField.text
    }
    
    func viewLoad() {
           self.edtOrderDetails.text = self.orderModel?.orderDetails
           
           edtOrderDetails.placeholder = "order_details".localized
           edtOrderDetails.placeholderColor = UIColor.appLightGray
           edtOrderDetails.isPlaceholderScrollEnabled = true
           
           self.viewRecording.isHidden = true
           
           if (self.orderModel?.voiceRecord?.count ?? 0 > 0) {
               self.viewRecording.isHidden = false
           }
           
       }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.getShopsList(radius: Float(Constants.DEFAULT_RADIUS), rating: 0)

        handleImagesView()
        self.ShopsCarouselView.isHidden = true
        self.buttomSheet.isHidden = false
        
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .authorizedAlways, .authorizedWhenInUse:
                locationManager.delegate = self
                locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
                locationManager.startUpdatingLocation()
                self.loadData()
            case .notDetermined:
                // For use in foreground
                self.locationManager.requestWhenInUseAuthorization()
            default:
                self.showAlert(title: "Enable Location Services", message: "", buttonText: "Setting") {
                    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
                }
            }
        } else {
            self.showAlert(title: "Enable Location Services", message: "", buttonText: "Setting") {
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
    
    }
    
    private func loadData() {
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
        if (self.isArabic()) {
            //  self.ivHandle.image = UIImage(named: "ic_back_arabic")
            self.ivIndicator.image = UIImage(named: "ic_arrow_login_white_arabic")
            self.collectionCategories.semanticContentAttribute = UISemanticContentAttribute.forceRightToLeft
            self.ShopsCarouselView.semanticContentAttribute = .forceLeftToRight
            self.collectionCategories.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        }
        if (self.orderModel == nil) {
            self.orderModel = OTWOrder()
        }
        self.searchField.delegate = self
        
        if (self.latitude ?? 0.0 == 0.0 || self.longitude ?? 0.0 == 0.0) {
            self.showLoading()
        }else {
            self.setUpGoogleMap()
        }
        
        if (self.orderModel?.shop?.id ?? 0 > 0) {
            //self.moreDetailsView.isHidden = false
            self.ivShop.isHidden = false
            self.lblSearch.isHidden = true
            self.lblPickupLocation.text = self.orderModel?.pickUpAddress ?? ""
            self.lblPickupLocation.textColor = UIColor.appDarkBlue
            //  self.edtMoreDetails = self.orderModel?.pickUpAddress ?? ""
            
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
            
            
            self.viewShopDetails.isHidden = false
            self.viewClearField.isHidden = false
            
            if (self.orderModel?.shop?.images?.count ?? 0 > 0) {
                let url = URL(string: "\(Constants.IMAGE_URL)\(self.orderModel?.shop?.images?[0] ?? "")")
                self.ivShop.kf.setImage(with: url)
            }else {
                let url = URL(string: "\(Constants.IMAGE_URL)\(self.orderModel?.shop?.type?.image ?? "")")
                self.ivShop.kf.setImage(with: url)
            }
            
            self.edtMoreDetails = "\(self.orderModel?.shop?.name ?? "")\n\(self.orderModel?.shop?.address ?? "")"
            
            
            //self.lblShopName.text = self.orderModel?.shop?.name ?? ""
            //self.shopNameHeight.constant = 20
            
            self.viewPin.isHidden = false
            self.viewSuggest.isHidden = true
            
        }
        
        ApiService.updateRegId(Authorization: DataManager.loadUser().data?.accessToken ?? "", regId: Messaging.messaging().fcmToken ?? "not_avaliable") { (response) in
        }
        
        let flag = App.shared.config?.configSettings?.flag ?? false
        if (flag == false) {
            self.checkForUpdates()
        }
        
        
        if (self.isProvider()) {
            self.getDriverOnGoingDeliveries()
        }
        
        viewSuggest.isHidden = true
        
        self.viewPop.isHidden = true
        
        self.collectionCategories.delegate = self
        self.collectionCategories.dataSource = self
        
    }
    
    func openShopList() {
        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AllShopsVC") as? AllShopsVC
        {
            vc.delegate = self
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func displayShop(shopId: Int) {
        self.showLoading()
        self.viewPin.isHidden = false
        self.viewSuggest.isHidden = true
        self.showActionSheet()
        ApiService.getShopDetails(Authorization: DataManager.loadUser().data?.accessToken ?? "", id: shopId) { (response) in
            self.hideLoading()
            self.pinMarker?.map = nil
            self.lblPickupLocation.textColor = UIColor.appDarkBlue
            self.lblPickupLocation.text = response.shopData?.name ?? ""
            let dataShop = DataShop(id: response.shopData?.id ?? 0, name: response.shopData?.name ?? "", address: response.shopData?.address ?? "", latitude: response.shopData?.latitude ?? 0.0, longitude: response.shopData?.longitude ?? 0.0, phoneNumber: response.shopData?.phoneNumber ?? "", workingHours: response.shopData?.workingHours ?? "", images: response.shopData?.images ?? [String](), rate: response.shopData?.rate ?? 0.0, type: response.shopData?.type ?? TypeClass(id: 0, name: "",image: "", selectedIcon: "", icon: ""),ownerId: response.shopData?.ownerId ?? "", googlePlaceId: response.shopData?.googlePlaceId ?? "", openNow : response.shopData?.openNow ?? false, NearbyDriversCount : response.shopData?.nearbyDriversCount ?? 0, hasOwner: response.shopData?.hasOwner ?? true)
            self.orderModel?.shop = dataShop
            self.orderModel?.pickUpAddress = response.shopData?.name ?? ""
            self.orderModel?.pickUpLatitude = response.shopData?.latitude ?? 0.0
            self.orderModel?.pickUpLongitude = response.shopData?.longitude ?? 0.0
            
            self.ivShop.isHidden = false
            
            self.lblSearch.isHidden = true
            self.viewShopDetails.isHidden = false
            self.viewClearField.isHidden = false
            
            
            self.edtMoreDetails = "\(response.shopData?.name ?? "")\n\(response.shopData?.address ?? "")"
            
            /** step 1 - comment all logic of shop details image  */
            
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
            self.singleMarker?.position = CLLocationCoordinate2D(latitude: dataShop.latitude ?? 0.0, longitude: dataShop.longitude ?? 0.0)
            self.singleMarker?.title =  "\(dataShop.id ?? 0)"
            self.singleMarker?.snippet = ""
            self.singleMarker?.icon = UIImage(named: "ic_shop_empty_selected")
            // snuff1
            let url = URL(string: "\(Constants.IMAGE_URL)\(response.shopData?.type?.selectedIcon ?? "")")
            self.applyMarkerImage(from: url!, to: self.singleMarker!)
            self.singleMarker?.map = self.gMap
            
            self.handleOpenNow(shop: response.shopData)
            
            let camera = GMSCameraPosition.camera(withLatitude: self.orderModel?.pickUpLatitude ?? 0.0, longitude: self.orderModel?.pickUpLongitude ?? 0.0, zoom: 15.0)
            self.gMap?.animate(to: camera)
            self.checkMenuAction(self)
        }
    }
    
    func onSelect(shop: DataShop) {
        self.showLoading()
        self.viewPin.isHidden = false
        self.viewSuggest.isHidden = true
        self.ShopsCarouselView.isHidden = true
        self.buttomSheet.isHidden = false
        self.showActionSheet()
        ApiService.getShopDetails(Authorization: DataManager.loadUser().data?.accessToken ?? "", id: shop.id ?? 0) { (response) in
            self.hideLoading()
            self.pinMarker?.map = nil
            self.lblPickupLocation.textColor = UIColor.appDarkBlue
            self.lblPickupLocation.text = response.shopData?.name ?? ""
            let dataShop = DataShop(id: response.shopData?.id ?? 0, name: response.shopData?.name ?? "", address: response.shopData?.address ?? "", latitude: response.shopData?.latitude ?? 0.0, longitude: response.shopData?.longitude ?? 0.0, phoneNumber: response.shopData?.phoneNumber ?? "", workingHours: response.shopData?.workingHours ?? "", images: response.shopData?.images ?? [String](), rate: response.shopData?.rate ?? 0.0, type: response.shopData?.type ?? TypeClass(id: 0, name: "",image: "", selectedIcon: "", icon: ""),ownerId: response.shopData?.ownerId ?? "", googlePlaceId: response.shopData?.googlePlaceId ?? "", openNow : response.shopData?.openNow ?? false, NearbyDriversCount : response.shopData?.nearbyDriversCount ?? 0, hasOwner: response.shopData?.hasOwner ?? true)
            self.orderModel?.shop = dataShop
            self.orderModel?.pickUpAddress = response.shopData?.name ?? ""
            self.orderModel?.pickUpLatitude = response.shopData?.latitude ?? 0.0
            self.orderModel?.pickUpLongitude = response.shopData?.longitude ?? 0.0
            
            self.ivShop.isHidden = false
            
            self.lblSearch.isHidden = true
            self.viewShopDetails.isHidden = false
            self.viewClearField.isHidden = false
            
            
            self.edtMoreDetails = "\(response.shopData?.name ?? "")\n\(response.shopData?.address ?? "")"
            
            /** step 1 - comment all logic of shop details image  */
            
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
           // self.singleMarker?.icon = UIImage(named: "ic_shop_empty_selected")
            // snuff1
            let url = URL(string: "\(Constants.IMAGE_URL)\(response.shopData?.type?.image ?? "")")
            self.applyMarkerImage(from: url!, to: self.singleMarker!)
           // self.singleMarker?.map = self.gMap
            
            self.handleOpenNow(shop: response.shopData)
            
            let camera = GMSCameraPosition.camera(withLatitude: self.orderModel?.pickUpLatitude ?? 0.0, longitude: self.orderModel?.pickUpLongitude ?? 0.0, zoom: 15.0)
            self.gMap?.animate(to: camera)
            self.checkMenuAction(self)
        }
    }
    
    func showSearchFieldToolTip() {
        let popTip = PopTip()
        popTip.bubbleColor = UIColor.processing
        popTip.textColor = UIColor.white
        popTip.show(text: "searchfield_tooltip".localized, direction: .down, maxWidth: 900, in: self.view, from: self.viewParentSearch.frame)
    }
    
    func getDriverOnGoingDeliveries() {
        self.showLoading()
        ApiService.getDriverOnGoingDeliveries(Authorization: DataManager.loadUser().data?.accessToken ?? "") { (response) in
            self.hideLoading()
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
        return true
    }
    
    func validateOrderDetail() -> Bool { //TODO:- add to next action
        if (self.orderModel?.orderDetails?.count ?? 0 == 0) {
            self.showBanner(title: "alert".localized, message: "enter_order_details".localized, style: UIColor.INFO)
            return false
        }
        
        return true
    }
    
    func onDone(images: [UIImage]) {
        self.selectedImages = images
        self.handleImagesView()
    }
    
    func updateModel(model: OTWOrder) {
        self.orderModel = model
    }
    
    func setUpGoogleMap() {
        
        if DataManager.loadUser().data?.roles?.contains(find: "Driver") == true {
            let camera = GMSCameraPosition.camera(withLatitude: self.latitude ?? 0.0, longitude: self.longitude ?? 0.0, zoom: 11.0)
            gMap = GMSMapView.map(withFrame: CGRect(x: 0, y: 0, width: self.mapView.frame.width, height: self.mapView.frame.height), camera: camera)
            gMap?.delegate = self
            gMap?.isMyLocationEnabled = true
            
            
            self.mapView.addSubview(gMap!)
            gMap?.bindFrameToSuperviewBounds()
            self.view.layoutSubviews()
            
            //self.getShopsList(radius: Float(Constants.DEFAULT_RADIUS), rating: 0)

        } else {
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
            
          //  self.getShopsList(radius: Float(Constants.DEFAULT_RADIUS), rating: 0)
        }

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
                        
                        //self.shopNameHeight.constant = 20
                       // self.lblShopName.text = strAddresMain
                        
                        self.lblPickupLocation.text = strAddresMain
                        self.lblPickupLocation.textColor = UIColor.appDarkBlue
                        self.orderModel?.pickUpAddress = strAddresMain
                        
                    }
                    else {
                       // self.shopNameHeight.constant = 0
                        //self.lblShopName.text = ""
                        self.lblPickupLocation.text = "Loading".localized
                        self.lblPickupLocation.textColor = UIColor.appDarkBlue
                        self.orderModel?.pickUpAddress = ""
                    }
                }
                else {
                    //self.shopNameHeight.constant = 0
                   // self.lblShopName.text = ""
                    self.lblPickupLocation.text = "Loading".localized
                    self.lblPickupLocation.textColor = UIColor.appDarkBlue
                    self.orderModel?.pickUpAddress = ""
                }
            }
            else {
              //  self.shopNameHeight.constant = 0
               // self.lblShopName.text = ""
                self.lblPickupLocation.text = "Loading".localized
                self.orderModel?.pickUpAddress = ""
            }
        }
    }
    
    func getShopsList(radius : Float, rating : Double) {
        self.showLoading()
        ApiService.getAllTypes { (response) in
            let category = TypeClass(id: 0, name: "all_shops".localized, image: "", selectedIcon: "", icon: "")
            category.isChecked = true
            self.categories.removeAll()
            self.categories.append(contentsOf: response.data ?? [TypeClass]())
            self.categories.append(category)

        }
 
        ApiService.getShops(latitude: self.latitude ?? 29.306856, longitude: self.longitude ?? 47.698692, radius: radius, rating : rating, types : 0) { (response) in
            self.shops.removeAll()
            self.shops.append(contentsOf: response.dataShops ?? [DataShop]())
            self.allShops = self.shops
            print("shops : \(self.shops.count)")
            if self.categories.count > 0 {
                self.hideLoading()
                self.collectionCategories.reloadData()
            } else {
                ApiService.getAllTypes { (response) in
                    let category = TypeClass(id: 0, name: "all_shops".localized, image: "", selectedIcon: "", icon: "")
                    category.isChecked = true
                    self.categories.removeAll()
                    self.categories.append(category)
                    self.categories.append(contentsOf: response.data ?? [TypeClass]())
                    self.collectionCategories.reloadData()
                    
                    if self.shops.count > 0 {
                        self.hideLoading()
                    } else {
                        ApiService.getShops(latitude: self.latitude ?? 29.306856, longitude: self.longitude ?? 47.698692, radius: radius, rating : rating, types : 0) { (response) in
                            self.shops.removeAll()
                            self.shops.append(contentsOf: response.dataShops ?? [DataShop]())
                            self.hideLoading()

                        }
                    }
                }

            }
//            self.addShopsMarkers()
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
    
    @IBAction func recordPress(_ sender: Any) {
        if (recorder.isRecording) {
            //stop
            self.bgRecord.isHidden = true
            self.btnRecord.setImage(UIImage(named: "ic_microphone"), for: .normal)
            self.gif.isHidden = true
            recorder.stop()
            if (recorder.time > 1) {
                self.viewRecording.isHidden = false
            }else {
                self.viewRecording.isHidden = true
            }
        }else {
            //record
            self.bgRecord.isHidden = false
            self.btnRecord.setImage(UIImage(named: "ic_recording"), for: .normal)
            self.gif.isHidden = false
            recorder.recordName = "order_file"
            recorder.record()
        }
    }
    var filterShopsWithDispanceItems = [SearchTextFieldItem]()

    func getShopsByName(name : String, latitude : Double, longitude: Double, radius : Float) {
        ApiService.getShopsByName(name: name,latitude: latitude, longitude: longitude, radius: radius) { (response) in
            self.shops.removeAll()
            
            self.filterShops.removeAll()
            self.filterShops.append(contentsOf: response.dataShops ?? [DataShop]())
            
            for shop in self.filterShops {
                let item1 = SearchTextFieldItem(title: "\(shop.name ?? "")  \(self.getShopDistance(latitude: shop.latitude ?? 0.0, longitude: shop.longitude ?? 0.0))", subtitle: shop.address ?? "", image: UIImage(named: "ic_location"))
                self.filterShopsWithDispanceItems.append(item1)
            }
            self.shopsSearchTableView.reloadData()
            self.searchByKeywordTableView.reloadData()
            self.searchByKeyWordsBackgroundView.isHidden = false
            self.searchByKeyWordsView.isHidden = false
            self.searchField.theme.font = UIFont.systemFont(ofSize: 13)
            self.searchField.forceNoFiltering = true
           // self.searchField.filterItems(filterShopsWithDispanceItems)
            self.searchField.itemSelectionHandler = { filteredResults, itemPosition in
                // Just in case you need the item position
                let shop = self.filterShops[itemPosition]
                self.searchField.text = shop.name ?? ""
                self.orderModel?.pickUpLatitude = shop.latitude ?? 0.0
                self.orderModel?.pickUpLongitude = shop.longitude ?? 0.0
                self.orderModel?.shop = shop
                self.orderModel?.pickUpAddress = shop.name ?? ""
                self.lblPickupLocation.text = shop.name ?? ""
                //self.lblShopName.text = shop.name ?? ""
                self.lblPickupLocation.textColor = UIColor.appDarkBlue
                
                //self.moreDetailsView.isHidden = false
                self.ivShop.isHidden = false
                
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
                //snuff1
                let url = URL(string: "\(Constants.IMAGE_URL)\(shop.type?.selectedIcon ?? "")")
                self.applyMarkerImage(from: url!, to: self.singleMarker!)
                self.singleMarker?.map = self.gMap
                
                
                self.viewShopDetails.isHidden = false
                self.viewClearField.isHidden = false
                
                
                // same thing shop image was removed
                if (shop.images?.count ?? 0 > 0) {
                    let url = URL(string: "\(Constants.IMAGE_URL)\(shop.images?[0] ?? "")")
                    self.ivShop.kf.setImage(with: url)
                }else if (shop.type?.image?.count ?? 0 > 0){
                    let url = URL(string: "\(Constants.IMAGE_URL)\(shop.type?.image ?? "")")
                    self.ivShop.kf.setImage(with: url)
                }else {
                    self.ivShop.image = UIImage(named: "ic_place_store")
                }
                
                self.edtMoreDetails = "\(shop.name ?? "")\n\(shop.address ?? "")"
                
                // self.lblShopName.text = shop.name ?? ""
               // self.shopNameHeight.constant = 20
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
                let dataShop = DataShop(id: 0, name: prediction.name ?? "", address: prediction.vicinity ?? "", latitude: prediction.geometry?.location?.lat ?? 0.0, longitude: prediction.geometry?.location?.lng ?? 0.0, phoneNumber: "", workingHours: "", images: [String](), rate: prediction.rating ?? 0.0, type: TypeClass(id: 0, name: prediction.types?[0] ?? "", image: "", selectedIcon: "", icon: ""), ownerId: "", googlePlaceId: prediction.placeID ?? "", openNow: prediction.openingHours?.openNow ?? false, NearbyDriversCount : 0, hasOwner: true)
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
             //   self.lblShopName.text = shop.name ?? ""
                self.lblPickupLocation.textColor = UIColor.appDarkBlue
                
                //self.moreDetailsView.isHidden = false
                self.ivShop.isHidden = false
                
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
                
                
                self.edtMoreDetails = "\(shop.name ?? "")\n\(shop.address ?? "")"
                
                self.viewPin.isHidden = false
                self.viewSuggest.isHidden = true
                
                
                let camera = GMSCameraPosition.camera(withLatitude: self.orderModel?.pickUpLatitude ?? 0.0, longitude: self.orderModel?.pickUpLongitude ?? 0.0, zoom: 15.0)
                self.gMap?.animate(to: camera)
                
            }
        }
    }
    

    
    func addShopsMarkers(useScale: Bool = false) {
        self.gMap?.clear()
        self.shopMarkers.removeAll()

        for center in self.shops {
            let marker = GMSMarker()
            marker.position = CLLocationCoordinate2D(latitude: center.latitude ?? 0.0, longitude: center.longitude ?? 0.0)
            marker.title =  "\(center.id ?? 0)"
            marker.snippet = "\(center.phoneNumber ?? "")"
            self.singleMarker?.icon = UIImage(named: "ic_shop_empty")
            // snuff1
            let url = URL(string: "\(Constants.IMAGE_URL)\(center.type?.image ?? "")")
            self.applyMarkerImage(from: url!, to: marker,isScaled: useScale)
            self.singleMarker?.map = self.gMap
            //marker.map = gMap
            self.shopMarkers.append(marker)
        }
    }
    
    func addShopsInfoMarkers(useScale: Bool = false) {
        self.gMap?.clear()
        self.shopMarkers.removeAll()

        for center in self.shops {
            let marker = GMSMarker()
            marker.position = CLLocationCoordinate2D(latitude: center.latitude ?? 0.0, longitude: center.longitude ?? 0.0)
            marker.title =  "\(center.id ?? 0)"
            marker.snippet = "\(center.phoneNumber ?? "")"
            self.singleMarker?.icon = UIImage(named: "ic_shop_empty")
            // snuff1
            let url = URL(string: "\(Constants.IMAGE_URL)\(center.type?.image ?? "")")
            self.applyInfoMarkerImage(from: url!, to: marker, isScaled: useScale, dispalyShopeName: false, ShopeName: center.name ?? "")
            self.singleMarker?.map = self.gMap
            //marker.map = gMap
            self.shopMarkers.append(marker)
        }
    }
    
    func filterShopsMarkers(selectedShopTypeId: Int, isScaled: Bool = false, dispalyShopeName: Bool = false) {
        self.gMap?.clear()
        self.shopMarkers.removeAll()
        self.singleMarker?.map = nil
        
        let selectedShops = self.shops.filter({$0.type?.id == selectedShopTypeId})
        selectedCarouselShops.removeAll()
        selectedCarouselShops = self.shops.filter({$0.type?.id == selectedShopTypeId})
        self.ShopsCarouselView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .left, animated: true)
        for center in selectedShops {
            self.ShopsCarouselView.isHidden = false
            self.buttomSheet.isHidden = true
            let marker = GMSMarker()
            marker.position = CLLocationCoordinate2D(latitude: center.latitude ?? 0.0, longitude: center.longitude ?? 0.0)
            marker.title =  "\(center.id ?? 0)"
            marker.snippet = "\(center.phoneNumber ?? "")"
            //self.singleMarker?.icon = UIImage(named: "ic_shop_empty")
            // snuff1
            let url = URL(string: "\(Constants.IMAGE_URL)\(center.type?.image ?? "")")
            self.applyMarkerImage(from: url!, to: marker, isScaled: isScaled, dispalyShopeName: dispalyShopeName, ShopeName: center.name ?? "")

          //  self.singleMarker?.map = self.gMap
            self.shopMarkers.append(marker)
        }

    }
    
    func filterShopsInfoMarkers(selectedShopTypeId: Int, isScaled: Bool = false, dispalyShopeName: Bool = false) {
       
        self.gMap?.clear()
        self.shopMarkers.removeAll()
        self.singleMarker?.map = nil
        
        let selectedShops = self.shops.filter({$0.type?.id == selectedShopTypeId})
        for center in selectedShops {
            let marker = GMSMarker()
            marker.position = CLLocationCoordinate2D(latitude: center.latitude ?? 0.0, longitude: center.longitude ?? 0.0)
            marker.title =  "\(center.id ?? 0)"
            marker.snippet = "\(center.phoneNumber ?? "")"
            let url = URL(string: "\(Constants.IMAGE_URL)\(center.type?.image ?? "")")
            self.applyInfoMarkerImage(from: url!, to: marker, isScaled: isScaled, dispalyShopeName: dispalyShopeName, ShopeName: center.name ?? "")

           // self.singleMarker?.map = self.gMap
            self.shopMarkers.append(marker)
        }
    }
    
    func showShopsList() {
        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AllShopsVC") as? AllShopsVC
        {
            vc.delegate = self
            vc.selectedCategory = self.selectdCategory?.id
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func applyMarkerImage(from url: URL, to marker: GMSMarker, isScaled: Bool = false, dispalyShopeName: Bool = false, ShopeName: String = "") {
        
        let storeView = StoreMarkerView.instanceFromNib()
        
     //   DispatchQueue.main.async {
            if isScaled {
            storeView.transform = CGAffineTransform.identity.scaledBy(x: self.myscale, y: self.myscale);
            }

            storeView.storiImaView.layer.cornerRadius = 14
            marker.iconView = storeView
            marker.map = self.gMap
       // }
        
        DispatchQueue.global(qos: .background).async {
            guard let data = try? Data(contentsOf: url),
                // let image = UIImage(data: data)?.cropped()
                let image = UIImage(data: data)
                else { return }
            
            DispatchQueue.main.async {
               // marker.icon = self.imageWithImage(image: image, scaledToSize: CGSize(width: 48.0, height: 48.0))
//                let image = self.imageWithImage(image: image, scaledToSize: CGSize(width: 48.0, height: 48.0))
                storeView.storiImaView.image = image
            }
        }
    }
    
    func applyInfoMarkerImage(from url: URL, to marker: GMSMarker, isScaled: Bool = false, dispalyShopeName: Bool = false, ShopeName: String = "") {
        let storeView = MarkerInfo.instanceFromNib()

        DispatchQueue.main.async {
            if isScaled {
            storeView.transform = CGAffineTransform.identity.scaledBy(x: self.myscale, y: self.myscale);
            }

            storeView.storeNameLabel.text = ShopeName
            storeView.markerImageView.layer.cornerRadius = 17.5
            storeView.layer.borderWidth = 0.4
            storeView.layer.borderColor = UIColor.lightGray.cgColor
          //  storeView.dropShadow(color: .darkGray, opacity: 1, offSet: CGSize(width: -1, height: 1), radius: 3, scale: true)
            storeView.layer.cornerRadius = 5

            marker.iconView = storeView
            //  marker.icon = image
            marker.map = self.gMap
        }
        
        DispatchQueue.global(qos: .background).async {
            guard let data = try? Data(contentsOf: url),
                // let image = UIImage(data: data)?.cropped()
                let image = UIImage(data: data)
                else { return }
            
            DispatchQueue.main.async {
               // marker.icon = self.imageWithImage(image: image, scaledToSize: CGSize(width: 48.0, height: 48.0))
                let image = self.imageWithImage(image: image, scaledToSize: CGSize(width: 48.0, height: 48.0))
                storeView.markerImageView.image = image
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
            if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DeliveryStep3") as? DeliveryStep3
            {
                self.orderModel?.pickUpDetails = self.edtMoreDetails ?? ""
                vc.selectedImages = selectedImages
                vc.latitude = self.latitude
                vc.longitude = self.longitude
                vc.orderModel = self.orderModel
                vc.delegate = self
                vc.place = self.place
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    @IBAction func step3Action(_ sender: Any) {
        
    }
    
    @IBAction func nextAction(_ sender: Any) {
        
        self.orderModel?.orderDetails = self.edtOrderDetails.text
        
        
        if (self.validate() && validateOrderDetail()) {
            if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DeliveryStep3") as? DeliveryStep3
            {

                vc.orderModel?.dropOffAddress = self.orderModel?.dropOffAddress
                vc.latitude = self.latitude == 0 ? LabasLocationManager.shared.currentLocation?.coordinate.latitude : self.latitude
                vc.selectedImages = selectedImages
                vc.longitude = self.longitude == 0 ? LabasLocationManager.shared.currentLocation?.coordinate.longitude : self.longitude
                vc.orderModel = self.orderModel
                vc.delegate = self
                vc.place = self.place
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
        //self.moreDetailsView.isHidden = true
        self.ivShop.image = nil
        self.ivShop.isHidden = true
        self.lblSearch.isHidden = true
        self.shopNaleKabel.text = ""

        self.edtMoreDetails = ""
        self.lblPickupLocation.text = ""
        self.searchField.text = ""
        
        self.viewShopDetails.isHidden = true
        self.viewClearField.isHidden = true
        self.gMap?.clear()
        self.getShopsList(radius: Float(Constants.DEFAULT_RADIUS), rating: 0)
        
        //self.lblShopName.text = ""
       // self.shopNameHeight.constant = 0
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
        //self.moreDetailsView.isHidden = true
        self.hideActionSheet()
        self.orderModel?.reset()
        
        self.ivShop.image = nil
        self.ivShop.isHidden = true
        self.lblSearch.isHidden = true
        self.shopNaleKabel.text = ""
        self.edtMoreDetails = ""
        self.lblPickupLocation.text = ""
        self.searchField.text = ""
        
        self.viewShopDetails.isHidden = true
        self.viewClearField.isHidden = true
        self.gMap?.clear()
        self.getShopsList(radius: Float(Constants.DEFAULT_RADIUS), rating: 0)
        
      //  self.lblShopName.text = ""
       // self.shopNameHeight.constant = 0
        self.viewPin.isHidden = false
        self.viewSuggest.isHidden = true
        
        let camera = GMSCameraPosition.camera(withLatitude: self.latitude ?? 0.0, longitude: self.longitude ?? 0.0, zoom: 11.0)
        self.gMap?.animate(to: camera)
        self.viewCheckMenu.isHidden = true
        self.selectedItems.removeAll()
    }
    
    @IBAction func clearFieldAction2(_ sender: Any) {
        //self.moreDetailsView.isHidden = true
        self.hideActionSheet()
        self.orderModel?.reset()
        
        self.ivShop.image = nil
        self.ivShop.isHidden = true
        
        self.lblSearch.isHidden = true
        
        self.edtMoreDetails = ""
        self.clearDetailFieldAction(self)
        self.lblPickupLocation.text = ""
        self.searchField.text = ""
        self.selectedItems = []
        self.selectdCategory = nil
        self.viewShopDetails.isHidden = true
        self.viewClearField.isHidden = true
        self.btnCheckMenu.isHidden = true
        self.viewCheckMenu.isHidden = true
        self.gMap?.clear()
        self.getShopsList(radius: Float(Constants.DEFAULT_RADIUS), rating: 0)
        self.shopNaleKabel.text = ""
        //self.lblShopName.text = ""
        // self.shopNameHeight.constant = 0
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
        self.handleCheckMenuAction(showPopUpIfEmpty: true)
    }
    
    private func handleCheckMenuAction(showPopUpIfEmpty: Bool) {
        self.showLoading()
        ApiService.getMenuByShopId(Authorization: DataManager.loadUser().data?.accessToken ?? "", id: self.orderModel?.shop?.id ?? 0) { (response) in
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc : ShopMenuVC = storyboard.instantiateViewController(withIdentifier: "ShopMenuVC") as! ShopMenuVC
            vc.shopId = self.orderModel?.shop?.id ?? 0
            vc.selectedItems = self.selectedItems
            vc.delegate = self
            
            self.hideLoading()
            vc.categories.removeAll()
            vc.categories.append(contentsOf: response.shopMenuData ?? [ShopMenuDatum]())
            if (vc.categories.count == 0) {
                if showPopUpIfEmpty {
                    self.showBanner(title: "alert".localized, message: "no_menu".localized, style: UIColor.INFO)
                }
            } else {
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    @IBAction func showShopsList(_ sender: Any) {
        self.showShopsList()
    }
    
    @IBAction func myLocationAction(_ sender: Any) {
        self.showActionSheet()
        edtOrderDetails.placeholder = "order_details_dorToDor".localized
        var bounds = GMSCoordinateBounds()
        var locationArray = [[String: Any]]()
        locationArray.append(["latitude": self.latitude ?? 0.0,
                              "longitude": self.longitude ?? 0.0,
                              "image": "fromLocation"])
        locationArray.append(["latitude": self.locationManager.location?.coordinate.latitude ?? 0.0, "longitude": self.locationManager.location?.coordinate.longitude ?? 0.0,
                              "image": "toLocation"])
        
        self.orderModel?.pickUpLatitude = self.locationManager.location?.coordinate.latitude ?? 0.0
        self.orderModel?.pickUpLongitude = self.locationManager.location?.coordinate.longitude ?? 0.0
        self.GetAnnotationUsingCoordinated(self.locationManager.location ?? CLLocation(latitude: 0.0, longitude: 0.0))
        for location in locationArray
        {
            let latitude = location["latitude"] as! Double
            let longitude = location["longitude"] as! Double
            let icon = location["image"] as! String
           
            let image = self.imageWithImage(image: UIImage(named: icon)!, scaledToSize: CGSize(width: 48.0, height: 48.0))
            let imagewithShadow = image.withShadow()
            let marker = GMSMarker()
            marker.position = CLLocationCoordinate2D(latitude: latitude , longitude: longitude)
            marker.map = self.gMap
            marker.icon = imagewithShadow
            bounds = bounds.includingCoordinate(marker.position)
        }

        self.gMap?.setMinZoom(1, maxZoom: 15)//prevent to over zoom on fit and animate if bounds be too small

        let update = GMSCameraUpdate.fit(bounds, withPadding: 50)
        self.gMap?.animate(with: update)

        self.gMap?.setMinZoom(1, maxZoom: 20) // allow the user zoom in more than level 15 again
//        let camera = GMSCameraPosition.camera(withLatitude: c, longitude: self.locationManager.location?.coordinate.longitude ?? 0.0, zoom: 10.0)
//
//        if let coordinate = self.locationManager.location?.coordinate {
//            self.addPickerOnDropOffLocation(coordinate: coordinate)
//        }
//        self.gMap?.animate(to: camera)
    }
    
    @IBAction func shopDetailsAction(_ sender: Any) {
        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ShopDetailsVC") as? ShopDetailsVC
        {
            vc.latitude = self.latitude ?? 0.0
            vc.longitude = self.longitude ?? 0.0
            
            let shopData = ShopData(nearbyDriversCount: 0, id: self.orderModel?.shop?.id ?? 0, name: self.orderModel?.shop?.name ?? "", address: self.orderModel?.shop?.address ?? "", latitude: self.orderModel?.shop?.latitude ?? 0.0, longitude: self.orderModel?.shop?.longitude ?? 0.0, phoneNumber: self.orderModel?.shop?.phoneNumber ?? "", workingHours: self.orderModel?.shop?.workingHours ?? "", images: self.orderModel?.shop?.images ?? [String](), rate: self.orderModel?.shop?.rate ?? 0.0, type: self.orderModel?.shop?.type ?? TypeClass(id: 0, name: "",image: "", selectedIcon: "", icon: ""), ownerId: self.orderModel?.shop?.ownerId ?? "",googlePlaceId:  self.orderModel?.shop?.googlePlaceId ?? "", openNow: self.orderModel?.shop?.openNow ?? false, hasOwner: self.orderModel?.shop?.hasOwner ?? true)
            shopData.placeId = self.orderModel?.shop?.placeId ?? ""
            
            vc.shop = shopData
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

// MARK: - GMSMapViewDelegate

extension DeliveryStep1 : GMSMapViewDelegate {
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        toolTipView?.removeFromSuperview()
    }
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        if !isFromSearch {
        if selectAllCategory {
            if position.zoom >= 12 && isZoomed == false {
                 isZoomed = true
               // addShopsInfoMarkers()
             } else if position.zoom < 12 && isZoomed == true {
                 isZoomed = false
                //addShopsMarkers()
             }
        } else {
            if position.zoom >= 12 && isZoomed == false {
                 isZoomed = true
               //  filterShopsInfoMarkers(selectedShopTypeId: self.selectdCategory?.id ?? 0)
             } else if position.zoom < 12 && isZoomed == true {
                 isZoomed = false
               //  filterShopsMarkers(selectedShopTypeId: self.selectdCategory?.id ?? 0, isScaled: false)
             }
        }
        } else {
            isFromSearch = false
        }
        print(position.zoom)
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        let id = marker.title ?? "0"
        isZoomed = true
        if (id.contains(find: "my_location")) {
            return true
        }
        if (id == "0" || id == "") {
            return true
        }
        if (Int(id) ?? 0 > 0) {
            self.showLoading()
            self.ShopsCarouselView.isHidden = true
            self.buttomSheet.isHidden = false
            self.viewPin.isHidden = false
            self.viewSuggest.isHidden = true
            self.showActionSheet()
            self.edtOrderDetails.placeholder = "order_details".localized
            ApiService.getShopDetails(Authorization: DataManager.loadUser().data?.accessToken ?? "", id: Int(id)!) { (response) in
                self.hideLoading()
                self.pinMarker?.map = nil
                self.lblPickupLocation.textColor = UIColor.appDarkBlue
                self.lblPickupLocation.text = response.shopData?.name ?? ""
                let dataShop = DataShop(id: response.shopData?.id ?? 0, name: response.shopData?.name ?? "", address: response.shopData?.address ?? "", latitude: response.shopData?.latitude ?? 0.0, longitude: response.shopData?.longitude ?? 0.0, phoneNumber: response.shopData?.phoneNumber ?? "", workingHours: response.shopData?.workingHours ?? "", images: response.shopData?.images ?? [String](), rate: response.shopData?.rate ?? 0.0, type: response.shopData?.type ?? TypeClass(id: 0, name: "",image: "", selectedIcon: "", icon: ""),ownerId: response.shopData?.ownerId ?? "", googlePlaceId: response.shopData?.googlePlaceId ?? "", openNow : response.shopData?.openNow ?? false, NearbyDriversCount : response.shopData?.nearbyDriversCount ?? 0, hasOwner: response.shopData?.hasOwner ?? true)
                self.orderModel?.shop = dataShop
                self.orderModel?.pickUpAddress = response.shopData?.name ?? ""
                self.orderModel?.pickUpLatitude = response.shopData?.latitude ?? 0.0
                self.orderModel?.pickUpLongitude = response.shopData?.longitude ?? 0.0
                
                self.ivShop.isHidden = false
                self.shopNaleKabel.text = "\(response.shopData?.name ?? "")"
                self.shopNaleKabel.font_type = "15,5"
                self.lblSearch.isHidden = true
                self.viewShopDetails.isHidden = false
                self.viewClearField.isHidden = false
                
                self.edtMoreDetails = "\(response.shopData?.name ?? "")\n\(response.shopData?.address ?? "")"
                
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
                let url = URL(string: "\(Constants.IMAGE_URL)\(response.shopData?.type?.image ?? "")")
                self.applyMarkerImage(from: url!, to: self.singleMarker!, ShopeName: response.shopData?.name ?? "")
              //  self.singleMarker?.map = self.gMap
                
                self.handleOpenNow(shop: response.shopData)
                
                let camera = GMSCameraPosition.camera(withLatitude: self.orderModel?.pickUpLatitude ?? 0.0, longitude: self.orderModel?.pickUpLongitude ?? 0.0, zoom: 15.0)
                self.gMap?.animate(to: camera)
                
                if (self.orderModel?.shop?.id ?? 0 > 0) {
                    self.btnCheckMenu.isHidden = false
                    self.viewCheckMenu.isHidden = false
                    self.handleCheckMenuAction(showPopUpIfEmpty: false)
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
        } else {
            let hours = shop?.workingHours?.split(separator: ",")
            let dayWeek = self.getWeekDay(shop : shop)
            if (hours?.count ?? 0 > dayWeek) {
                
                let hoursWithoutSpace = hours?[dayWeek].replacingOccurrences(of: " ", with: "")
                let hoursSplit = hoursWithoutSpace?.split(separator: "-")
                
                if hoursWithoutSpace?.contains(find: "Open24") == false {
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
                    
                } } else {
                    
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
        self.addPickerOnDropOffLocation(coordinate: coordinate)
    }
    
    func addPickerOnDropOffLocation(coordinate: CLLocationCoordinate2D) {
        self.gMap?.clear()
        self.ShopsCarouselView.isHidden = true
        self.buttomSheet.isHidden = false

        if let currentLocation = self.locationManager.location {
            if CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude).distance(from: currentLocation ) < 65 {
                       self.edtOrderDetails.placeholder = "deliveryStep1.edtDetails.yourLocation.placeholder".localized
                   } else {
                       //self.edtOrderDetails.placeholder = "order_details".localized
                    self.edtOrderDetails.placeholder = "deliveryStep1.edtDetails.yourLocation.placeholder".localized
                   }
        }
        self.edtOrderDetails.placeholder = "deliveryStep1.edtDetails.yourLocation.placeholder".localized
        self.showActionSheet()
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
        
        self.viewSuggest.isHidden = true
        
        self.ivShop.image = nil
        self.ivShop.isHidden = true
        
        self.edtMoreDetails = ""
        
        self.viewShopDetails.isHidden = true
        self.viewClearField.isHidden = true
    }
}

// MARK: UITextFieldDelegate

extension DeliveryStep1: UITextFieldDelegate {
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        hideResults()
        self.shops = allShops
        return true
    }
    
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        textField.resignFirstResponder()
//        hideResults() ; return true
//    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {        let text = textField.text! as NSString
        let fullText = text.replacingCharacters(in: range, with: string)
        let searchText = fullText //fullText.filter ({!" ".contains($0) })
        if (range.length > 0)
          {
            // We're deleting
             if searchText.count <= 3 {
                hideResults()
                self.shops = allShops
            }
          }
          else
          {
            // We're adding
            if searchText.count == 5 || searchText.count >= 10 {
                showResults(string:fullText)
                self.getShopsByName(name: searchText, latitude: self.latitude ?? 0.0, longitude: self.longitude ?? 0.0, radius: Float(Constants.DEFAULT_RADIUS))

              
            }else if searchText.count < 5 {
                hideResults()
                self.shops = allShops
            }

          }

        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if (textField == self.searchField) {
            let query = self.searchField.text ?? ""
            if (query.count > 0) {
                self.getShopsByName(name: query, latitude: self.latitude ?? 0.0, longitude: self.longitude ?? 0.0, radius: Float(Constants.DEFAULT_RADIUS))
            } else if textField  == self.searchShopsTextField {
                self.shopsSearchTableView.isHidden = true
            } else {
                self.gMap?.clear()
                self.getShopsList(radius: Float(Constants.DEFAULT_RADIUS), rating: 0)
            }
            textField.resignFirstResponder()
            return true
        }
        return false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.shopsSearchTableView.isHidden = true
    }
}

// MARK: - Search by keywords

extension DeliveryStep1 {
    func hideResults(){
        searchByKeyWordsView.isHidden = true
        searchByKeyWordsBackgroundView.isHidden = true
        autocompleteResults.removeAll()
        filterShopsWithDispanceItems.removeAll()
        searchByKeywordTableView.reloadData()
    }
    
    func showResults(string: String){
        var input = GInput()
        input.keyword = string
        let lati = "\(self.latitude ?? 0)"
        let long = "\(self.longitude ?? 0)"
        
        GoogleApi.shared.callApi(input: input,lati: lati, long: long) { (response) in
            if response.isValidFor(.autocomplete) {
                DispatchQueue.main.async {
                    self.searchByKeyWordsView.isHidden = false
                    self.searchByKeyWordsBackgroundView.isHidden = false
                    self.autocompleteResults = response.data as! [GApiResponse.Autocomplete]
                    self.searchByKeywordTableView.reloadData()
                }
            } else { print(response.error ?? "ERROR") }
        }
    }
}
// MARK: - GMSAutocompleteViewControllerDelegate

extension DeliveryStep1: GMSAutocompleteViewControllerDelegate {
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        self.showActionSheet()
        dismiss(animated: true, completion: {
            
            self.searchField.text = ""
            self.orderModel?.pickUpLatitude = place.coordinate.latitude ?? 0.0
            self.orderModel?.pickUpLongitude = place.coordinate.longitude ?? 0.0
            self.orderModel?.shop = nil
            self.orderModel?.pickUpAddress = place.formattedAddress ?? ""
            self.lblPickupLocation.text = place.name ?? ""
          //  self.lblShopName.text = place.name ?? ""
            self.lblPickupLocation.textColor = UIColor.appDarkBlue
            
            // hide details
            //self.moreDetailsView.isHidden = false
            self.ivShop.isHidden = false
            
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
                                    
            self.ivShop.image = UIImage(named: "placeholder_order")
            
            self.edtMoreDetails = "\(place.name ?? "")\n\(place.formattedAddress ?? "")"
            
           // self.lblShopName.text = place.name ?? ""
           // self.shopNameHeight.constant = 20
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

// MARK: - ShopMenuDelegate

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
            text += "\(itemQuantity) \(item.name ?? ""): \(total) \("currency".localized)\n"
            if isLatin(text: item.name ?? "") {
                self.edtOrderDetails.textAlignment = .left
            } else {
                self.edtOrderDetails.textAlignment = .right
            }
        }
        
        self.edtOrderDetails.text = text
        self.orderModel?.selectedTotal = total
        self.orderModel?.edtOrderDetailsText = text
        self.selectedItems.removeAll()
        self.selectedItems.append(contentsOf: items)
    }
    
    func isLatin(text: String) -> Bool {
        let upper = "ABCDEFGHIJKLMNOPQRSTUVWXYZ "

        for c in text.uppercased().trim().map({ String($0) }) {
            if !upper.contains(c) {
                return false
            }
        }

        return true
    }
}


// MARK: - CollectionView delegates
var oldSelectedShop: DataShop?
extension DeliveryStep1: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        ShopsCarouselView.didScroll()
        
        guard let currentCenterIndex = ShopsCarouselView.currentCenterCellIndex?.row else { return }
        let shop = selectedCarouselShops[currentCenterIndex]
        
        let url = URL(string: "\(Constants.IMAGE_URL)\(oldSelectedShop?.type?.image ?? "")")
       
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500), execute: {
            let camera = GMSCameraPosition.camera(withLatitude: shop.latitude ?? 0.0, longitude: shop.longitude ?? 0.0, zoom: 11.0)
            self.gMap?.animate(to: camera)
            var selectedMarker = GMSMarker()
            self.applyMarkerImage(from: url!, to:selectedMarker, ShopeName: oldSelectedShop?.name ?? "")
            for marker in self.shopMarkers {
                if let title = marker.title {
                    let id = Int(title)
                    if shop.id == id {
                        selectedMarker = marker
                        oldSelectedShop = shop
                        let view = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 20))
                        view.backgroundColor = .red
                        if marker.iconView is StoreMarkerView {
                            let markInfo = marker.iconView as! StoreMarkerView
                            markInfo.shopeMarkerImageView.image = UIImage(named: "selectedMarkerIcon")
                        }
                    } else {
                        if marker.iconView is StoreMarkerView {
                            let markInfo = marker.iconView as! StoreMarkerView
                            markInfo.shopeMarkerImageView.image = UIImage(named: "shopeMarker")
                        }
                    }
                }
            }
            })
        
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        if collectionView == ShopsCarouselView {
//            return CGSize(width: 0, height: 0)
//        } else {
//            let label = UILabel(frame: CGRect.zero)
//            label.text = self.categories[indexPath.row].name ?? ""
//            label.sizeToFit()
//            return CGSize(width: label.bounds.width + 8, height: self.collectionCategories.bounds.height - 8)
//        }
//
//    }
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
//        return UIEdgeInsets.zero
//    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView == ShopsCarouselView {
            return 0
        } else {
            return 10
        }    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView == ShopsCarouselView {
            return 0
        } else {
            return 10
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == ShopsCarouselView {
            return self.selectedCarouselShops.count
        } else {
            return self.categories.count

        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
       
        if collectionView == ShopsCarouselView {
            print("test click")
        } else {
          
            let selectedCat = self.categories[indexPath.row]
            self.selectdCategory = selectedCat
            if self.isArabic() {
                self.searchShopsTextField.textAlignment = .right
            } else {
                self.searchShopsTextField.textAlignment = .left
            }
    //        self.searchShopsTextField.placeholder = "step1.catFilter.search.placeholder".localized + " \(self.selectdCategory?.name ?? "")"
            
            self.catFilterSearchStack.isHidden = false
            self.hideActionSheet()
            self.orderModel?.reset()
            
            self.ivShop.image = nil
            self.ivShop.isHidden = true
            self.lblSearch.isHidden = true
            self.shopNaleKabel.text = ""
            self.edtMoreDetails = ""
            self.lblPickupLocation.text = ""
            self.searchField.text = ""
            
            self.viewShopDetails.isHidden = true
            self.viewClearField.isHidden = true
            self.gMap?.clear()
            
          //  self.lblShopName.text = ""
           // self.shopNameHeight.constant = 0
            self.viewPin.isHidden = false
            self.viewSuggest.isHidden = true
            
            let camera = GMSCameraPosition.camera(withLatitude: self.latitude ?? 0.0, longitude: self.longitude ?? 0.0, zoom: 11.0)
            self.gMap?.animate(to: camera)
            self.viewCheckMenu.isHidden = true
            self.selectedItems.removeAll()
            if selectedCat.id == 0 {
                selectAllCategory = true
                //self.addShopsMarkers(useScale: false)
                showShopsList()
                //self.filterShopsMarkers(selectedShopTypeId: selectedCat.id ?? 0)

            } else {
                selectAllCategory = false

                self.filterShopsMarkers(selectedShopTypeId: selectedCat.id ?? 0)
            }
        }
      
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == ShopsCarouselView {
            let shop = selectedCarouselShops[indexPath.row]
            let cell: ScalingCarouselCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ScalingCarouselCell", for: indexPath as IndexPath) as! ScalingCarouselCell
            cell.mainView.backgroundColor = .white
            cell.cornerRadius = 15
            cell.makeOrderButton.layer.cornerRadius = 5
            cell.shopName.text = shop.name
            cell.ratingLabe.text = "\(shop.rate ?? 4.0)"
            cell.ratingView.rating = shop.rate ?? 4
            if shop.hasOwner ?? true {
               // cell.ownThisShopButton.setTitle("", for: .normal)
                cell.ownThisShopButton.isUserInteractionEnabled = false
                cell.ownThisShopButton.isHidden = true
            } else {
                cell.ownThisShopButton.isHidden = false
                cell.ownThisShopButton.isUserInteractionEnabled = true
               // cell.ownThisShopButton.setTitle("carousel.ownThisPlace".localized, for: .normal)
            }
            
            cell.onShareShop = {
                self.generateDeepLink(shop: shop)
            }
            
            cell.onYourplaceAction = {
                self.customAlert.ownThisShop()
                self.customAlert.onOk = {
                if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SuggestShopVC") as? SuggestShopVC {
                            vc.latitude = shop.latitude ?? 0.0
                            vc.longitude = shop.longitude ?? 0.0
                            self.navigationController?.pushViewController(vc, animated: true)
                }
                }
            }
            
            cell.onMakeOrderAction = {
                let id = shop.id ?? 0
                self.isZoomed = true
               
               
                if (Int(id) > 0) {
                    self.showLoading()
                    self.ShopsCarouselView.isHidden = true
                    self.buttomSheet.isHidden = false

                    self.viewPin.isHidden = false
                    self.viewSuggest.isHidden = true
                    self.showActionSheet()
                    self.edtOrderDetails.placeholder = "order_details".localized
                    ApiService.getShopDetails(Authorization: DataManager.loadUser().data?.accessToken ?? "", id: id) { (response) in
                        self.hideLoading()
                        self.pinMarker?.map = nil
                        self.lblPickupLocation.textColor = UIColor.appDarkBlue
                        self.lblPickupLocation.text = response.shopData?.name ?? ""
                        let dataShop = DataShop(id: response.shopData?.id ?? 0, name: response.shopData?.name ?? "", address: response.shopData?.address ?? "", latitude: response.shopData?.latitude ?? 0.0, longitude: response.shopData?.longitude ?? 0.0, phoneNumber: response.shopData?.phoneNumber ?? "", workingHours: response.shopData?.workingHours ?? "", images: response.shopData?.images ?? [String](), rate: response.shopData?.rate ?? 0.0, type: response.shopData?.type ?? TypeClass(id: 0, name: "",image: "", selectedIcon: "", icon: ""),ownerId: response.shopData?.ownerId ?? "", googlePlaceId: response.shopData?.googlePlaceId ?? "", openNow : response.shopData?.openNow ?? false, NearbyDriversCount : response.shopData?.nearbyDriversCount ?? 0, hasOwner: response.shopData?.hasOwner ?? true)
                        self.orderModel?.shop = dataShop
                        self.orderModel?.pickUpAddress = response.shopData?.name ?? ""
                        self.orderModel?.pickUpLatitude = response.shopData?.latitude ?? 0.0
                        self.orderModel?.pickUpLongitude = response.shopData?.longitude ?? 0.0
                        
                        self.ivShop.isHidden = false
                        self.shopNaleKabel.text = "\(response.shopData?.name ?? "")"
                        self.shopNaleKabel.font_type = "15,5"
                        self.lblSearch.isHidden = true
                        self.viewShopDetails.isHidden = false
                        self.viewClearField.isHidden = false
                        
                        self.edtMoreDetails = "\(response.shopData?.name ?? "")\n\(response.shopData?.address ?? "")"
                        
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
                        self.singleMarker?.title =  "\(id)"
                        self.singleMarker?.snippet = ""
                        self.singleMarker?.icon = UIImage(named: "ic_shop_empty_selected")
                        // snuff1
                        let url = URL(string: "\(Constants.IMAGE_URL)\(response.shopData?.type?.image ?? "")")
                        self.applyMarkerImage(from: url!, to: self.singleMarker!, ShopeName: response.shopData?.name ?? "")
                      //  self.singleMarker?.map = self.gMap
                        
                        self.handleOpenNow(shop: response.shopData)
                        
                        let camera = GMSCameraPosition.camera(withLatitude: self.orderModel?.pickUpLatitude ?? 0.0, longitude: self.orderModel?.pickUpLongitude ?? 0.0, zoom: 15.0)
                        self.gMap?.animate(to: camera)
                        
                        if (self.orderModel?.shop?.id ?? 0 > 0) {
                            self.btnCheckMenu.isHidden = false
                            self.viewCheckMenu.isHidden = false
                            self.handleCheckMenuAction(showPopUpIfEmpty: false)
                        }else {
                            self.btnCheckMenu.isHidden = true
                            self.viewCheckMenu.isHidden = true
                            
                        }
                        if (self.orderModel?.selectedItems?.count ?? 0 > 0) {
                            self.selectedItems.append(contentsOf: self.orderModel?.selectedItems ?? [ShopMenuItem]())
                        }
                    }
                } else {
                    self.ShopsCarouselView.isHidden = false
                    self.buttomSheet.isHidden = true
                }
            }
            if let image = shop.images?.first {
                let url = URL(string: "\(Constants.IMAGE_URL)\(image)")
               // cell.shopeImageView.kf.setImage(with: url)
                cell.shopeImageView.kf.setImage(with: url, placeholder: UIImage(named: "splash_logo"))
            } else {
                cell.shopeImageView.image = UIImage(named: "splash_logo")
            }
          
            let urlString = "\(Constants.IMAGE_URL)\(shop.type?.image ?? "splash_logo")"
            let fileUrl = URL(fileURLWithPath: urlString)
           
//            DispatchQueue.global(qos: .background).async {
//                guard let data = try? Data(contentsOf: fileUrl),
//                    // let image = UIImage(data: data)?.cropped()
//                    let image = UIImage(data: data)
//                    else { return }
//                
//                DispatchQueue.main.async {
//                   // cell.shopeImageView.image = image
//                }
//            }

            DispatchQueue.main.async {
                cell.setNeedsLayout()
                cell.layoutIfNeeded()
            }
            return cell
        } else {
            let cell: Step1CatCell = collectionView.dequeueReusableCell(withReuseIdentifier: "Step1CatCell", for: indexPath as IndexPath) as! Step1CatCell
            
            let category = self.categories[indexPath.row]
            cell.lblName.text = category.name ?? ""
            if (self.isArabic()) {
                cell.lblName.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
            }
            
            if (category.image?.count ?? 0 > 0) {
                let url = URL(string: "\(Constants.IMAGE_URL)\(category.image ?? "")")
                cell.ivLogo.kf.setImage(with: url)
            }else {
                cell.ivLogo.image = UIImage(named: "type_holder")
            }
            return cell
        }
      
    }
    
    func generateDeepLink(shop: DataShop) {
        
        var shareText = ""
        shareText = "shop_on_rzq".localized
        
        
        let buo = BranchUniversalObject.init(canonicalIdentifier: "rzqapp/\(shop.id ?? 0)")
        buo.title = "\(shop.name ?? "")"
        buo.contentDescription = shareText
        if (shop.images?.count ?? 0 > 0) {
            buo.imageUrl = "\(Constants.IMAGE_URL)\(shop.images?[0] ?? "")"
        }
        buo.publiclyIndex = true
        buo.locallyIndex = true
        buo.contentMetadata.customMetadata["ShopId"] = shop.id ?? 0
        
        
        let lp: BranchLinkProperties = BranchLinkProperties()
        lp.channel = ""
        lp.feature = "sharing"
        lp.campaign = "Rzq App"
        lp.tags = ["Rzq App"]
        
        
        buo.getShortUrl(with: lp) { (url, error) in
            print(url as Any)
            let sessionParams = Branch.getInstance().getLatestReferringParams()
            print(sessionParams as Any)
            buo.showShareSheet(with: lp, andShareText: shareText, from: self) { (activityType, completed) in
            }
            
        }
        
    }

}

// MARK: - CLLocationManagerDelegate

extension DeliveryStep1: CLLocationManagerDelegate {
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    
        if (self.latitude ?? 0.0 == 0.0 || self.longitude ?? 0.0 == 0.0) {
            self.setUpGoogleMap()
        }
    }
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
                if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .authorizedAlways, .authorizedWhenInUse:
                locationManager.delegate = self
                locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
                locationManager.startUpdatingLocation()
                self.loadData()
            case .notDetermined:
                // For use in foreground
                self.locationManager.requestWhenInUseAuthorization()
            default:
                self.showAlert(title: "Enable Location Services", message: "", buttonText: "Setting") {
                    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
                }
            }
        } else {
            self.showAlert(title: "Enable Location Services", message: "", buttonText: "Setting") {
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
            }
        }
    }
}

// addition
extension DeliveryStep1 {
    
    @IBAction func playRecordAction(_ sender: Any) {
        if (self.orderModel?.voiceRecord?.count ?? 0 > 0) {
            let url = URL(string: ("\(Constants.IMAGE_URL)\(self.orderModel?.voiceRecord ?? "")"))
            self.downloadFileFromURL(url: url!)
        }else {
            if (recorder.isPlaying) {
                self.btnPlay.setImage(UIImage(named: "ic_play_record"), for: .normal)
                recorder.stopPlaying()
            }else {
                self.btnPlay.setImage(UIImage(named: "ic_pause"), for: .normal)
                recorder.play(name:"order_file")
            }
        }
    }
    
    @IBAction func deleteRecordAction(_ sender: Any) {
           recorder.delete(name: "order_file")
           self.btnRecord.setImage(UIImage(named: "ic_microphone"), for: .normal)
           self.gif.isHidden = true
           self.viewRecording.isHidden = true
       }
    
    @IBAction func clearDetailFieldAction(_ sender: Any) {
        self.edtOrderDetails.text = ""
        self.orderModel?.orderDetails = String()
    }
    
   
    
    @IBAction func recordAction(_ sender: Any) {
           self.bgRecord.isHidden = true
           self.btnRecord.setImage(UIImage(named: "ic_microphone"), for: .normal)
           self.gif.isHidden = true
           recorder.stop()
           if (recorder.time > 1) {
               self.viewRecording.isHidden = false
           }else {
               self.viewRecording.isHidden = true
           }
       }
       
      
    @IBAction func photoAction(_ sender: Any) {
           self.showAlertWithCancel(title: "add_image_pic_title".localized, message: "add_salon_pic_message".localized, actionTitle: "camera".localized, cancelTitle: "gallery".localized, actionHandler: {
               //camera
               guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
                   self.selectImageFrom(.photoLibrary)
                   return
               }
               self.selectImageFrom(.camera)
           }) {
               //gallery
               self.imagePicker =  UIImagePickerController()
               self.imagePicker.delegate = self
               self.imagePicker.sourceType = .photoLibrary
               self.present(self.imagePicker, animated: true, completion: nil)
           }
       }
    
}


extension DeliveryStep1 {
    func handleImagesView() {
        if (self.selectedImages.count > 0) {
            // self.viewImages.isHidden = false
            self.lblImages.text = "\(self.selectedImages.count) \("images".localized)"
        }else {
            // self.viewImages.isHidden = true
            self.lblImages.text = ""
        }
    }
}


extension DeliveryStep1: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
        imagePicker.dismiss(animated: true, completion: nil)
        guard let selectedImage = info[.originalImage] as? UIImage else {
            print("Image not found!")
            return
        }
        self.selectedImages.append(selectedImage)
        self.handleImagesView()
    }
}

import AVKit
extension DeliveryStep1: AVAudioPlayerDelegate {
  func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        DispatchQueue.main.async {
            self.btnPlay.setImage(UIImage(named: "ic_order_play"), for: .normal)
        }
    }
    
    
    func downloadFileFromURL(url:URL){
        
        var downloadTask:URLSessionDownloadTask
        downloadTask = URLSession.shared.downloadTask(with: url, completionHandler: { (url, response, error) in
            // self.play(url: url!)
            self.playRecord(path: url!)
        })
        
        downloadTask.resume()
        
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
    }
    
}

enum ImageSource {
    case photoLibrary
    case camera
}

extension DeliveryStep1 {
    func selectImageFrom(_ source: ImageSource) {
        imagePicker =  UIImagePickerController()
        imagePicker.delegate = self
        switch source {
        case .camera:
            imagePicker.sourceType = .camera
        case .photoLibrary:
            imagePicker.sourceType = .photoLibrary
        }
        present(imagePicker, animated: true, completion: nil)
    }
}


extension DeliveryStep1 {
        
        @IBAction func openDialogPhotos(_ sender: Any) {
            if (self.selectedImages.count > 0) {
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ImagePickerDialog") as! ImagePickerDialog
                vc.selectedImages = self.selectedImages
                self.definesPresentationContext = true
                vc.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
                vc.view.backgroundColor = UIColor.clear
                vc.delegate = self
    
                self.present(vc, animated: true, completion: nil)
            }else {
                self.showAlertWithCancel(title: "add_image_pic_title".localized, message: "add_salon_pic_message".localized, actionTitle: "camera".localized, cancelTitle: "gallery".localized, actionHandler: {
                    //camera
                    guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
                        self.selectImageFrom(.photoLibrary)
                        return
                    }
                    self.selectImageFrom(.camera)
                }) {
                    //gallery
                    self.imagePicker =  UIImagePickerController()
                    self.imagePicker.delegate = self
                    self.imagePicker.sourceType = .photoLibrary
                    self.present(self.imagePicker, animated: true, completion: nil)
                }
            }
        }
        
    func labasLocationManager(didUpdateLocation location: CLLocation) {
        if (self.latitude ?? 0.0 == 0.0 || self.longitude ?? 0.0 == 0.0) {
            
            self.latitude = location.coordinate.latitude
            self.longitude = location.coordinate.longitude
            
            UserDefaults.standard.setValue(self.latitude, forKey: Constants.LAST_LATITUDE)
            UserDefaults.standard.setValue(self.longitude, forKey: Constants.LAST_LONGITUDE)
//            self.latitude = 29.273551
//            self.longitude = 47.936161
            
            self.setUpGoogleMap()
            
        }
    }
}


extension DeliveryStep1: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        let sectionView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 25))
        sectionView.backgroundColor = UIColor(white: 0, alpha: 0.1)

        let sectionName = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 25))
        if section == 0 {
            sectionName.text = "OurShops".localized
        } else {
            sectionName.text = "OtherShops".localized
        }
        sectionName.textColor = UIColor.black
        sectionName.font = UIFont.systemFont(ofSize: 14)

        sectionView.addSubview(sectionName)
        return sectionView
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            if tableView == searchByKeywordTableView {
                return filterShopsWithDispanceItems.count
            } else {
               return self.searchedShops.count
            }
        } else {
            if tableView == searchByKeywordTableView {
                return self.autocompleteResults.count
            } else {
               return self.searchedShops.count
            }
        }
       return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if tableView == searchByKeywordTableView {
                
                let cell : FilterSearchCell = tableView.dequeueReusableCell(withIdentifier: "filtersearchcell", for: indexPath) as! FilterSearchCell
                
                cell.lblTitle.text = filterShopsWithDispanceItems[indexPath.row].title
                cell.lblDesc.text = filterShopsWithDispanceItems[indexPath.row].subtitle
                return cell
                
            } else {
                let cell = UITableViewCell()
                cell.textLabel?.text = self.searchedShops[indexPath.row].name
                return cell
            }
        } else {
            if tableView == searchByKeywordTableView {
                
                let cell : FilterSearchCell = tableView.dequeueReusableCell(withIdentifier: "filtersearchcell", for: indexPath) as! FilterSearchCell
                
                cell.lblTitle.text = autocompleteResults[indexPath.row].formattedAddress
                cell.lblDesc.text = ""
                return cell
                
            } else {
                let cell = UITableViewCell()
                cell.textLabel?.text = self.searchedShops[indexPath.row].name
                return cell
            }
        }
       
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        isFromSearch = true
        if indexPath.section == 0 {
            if tableView == searchByKeywordTableView {
                getSelectedShopFromSearch(row: indexPath.row)
            } else {
                onSelect(shop: self.searchedShops[indexPath.row])
                self.searchedText = ""
                self.shopsSearchTableView.isHidden = true
                self.searchShopsTextField.text = ""
                self.searchShopsTextField.resignFirstResponder()
                self.catFilterSearchStack.isHidden = true
            }
        } else {
            if tableView == searchByKeywordTableView {
                getPlaceInfo(row: indexPath.row)
            } else {
                onSelect(shop: self.searchedShops[indexPath.row])
                self.searchedText = ""
                self.shopsSearchTableView.isHidden = true
                self.searchShopsTextField.text = ""
                self.searchShopsTextField.resignFirstResponder()
                self.catFilterSearchStack.isHidden = true
            }
        }
    }
    
    func getSelectedShopFromSearch(row: Int) {
        // Just in case you need the item position
        self.edtOrderDetails.placeholder = "order_details".localized

        self.showActionSheet()
        let itemPosition: SearchTextFieldItem = self.filterShopsWithDispanceItems[row]
        let shop = self.filterShops[row]
        let selectedCategoryFromShop = self.categories.filter { $0.id == shop.type?.id }
        self.selectdCategory = selectedCategoryFromShop.first
        if self.isArabic() {
            self.searchShopsTextField.textAlignment = .right
        } else {
            self.searchShopsTextField.textAlignment = .left
        }
//        self.searchShopsTextField.placeholder = "step1.catFilter.search.placeholder".localized + " \(self.selectdCategory?.name ?? "")"
        self.ShopsCarouselView.isHidden = true
        self.buttomSheet.isHidden = false
        self.catFilterSearchStack.isHidden = false
        self.searchField.text = shop.name ?? ""
        self.shopNaleKabel.text = "\(shop.name ?? "")"
        self.shopNaleKabel.font_type = "15,5"
        self.orderModel?.pickUpLatitude = shop.latitude ?? 0.0
        self.orderModel?.pickUpLongitude = shop.longitude ?? 0.0
        self.orderModel?.shop = shop
        self.orderModel?.pickUpAddress = shop.name ?? ""
        self.lblPickupLocation.text = shop.name ?? ""
        //self.lblShopName.text = shop.name ?? ""
        self.lblPickupLocation.textColor = UIColor.appDarkBlue
        if (self.orderModel?.shop?.id ?? 0 > 0) {
            self.btnCheckMenu.isHidden = false
            self.viewCheckMenu.isHidden = false
            self.handleCheckMenuAction(showPopUpIfEmpty: false)
        }else {
            self.btnCheckMenu.isHidden = true
            self.viewCheckMenu.isHidden = true
            
        }
        //self.moreDetailsView.isHidden = false
        self.ivShop.isHidden = false
        
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
       // self.singleMarker?.icon = UIImage(named: "ic_shop_empty_selected")
        //snuff1
       // let url = URL(string: "\(Constants.IMAGE_URL)\(shop.type?.image ?? "")")
     
       // self.singleMarker?.map = self.gMap
        
        
        self.viewShopDetails.isHidden = false
        self.viewClearField.isHidden = false
        DispatchQueue.main.async {
            self.searchByKeyWordsBackgroundView.isHidden = true
            self.searchByKeyWordsView.isHidden = true
            self.searchField.text = shop.name ?? ""
            self.searchField.endEditing(true)
            self.view.endEditing(true)
        }
        // same thing shop image was removed
        if (shop.images?.count ?? 0 > 0) {
            let url = URL(string: "\(Constants.IMAGE_URL)\(shop.images?[0] ?? "")")
            self.ivShop.kf.setImage(with: url)
        }else if (shop.type?.image?.count ?? 0 > 0){
            let url = URL(string: "\(Constants.IMAGE_URL)\(shop.type?.image ?? "")")
            self.ivShop.kf.setImage(with: url)
        }else {
            self.ivShop.image = UIImage(named: "ic_place_store")
        }
        
        self.edtMoreDetails = "\(shop.name ?? "")\n\(shop.address ?? "")"
        
        // self.lblShopName.text = shop.name ?? ""
       // self.shopNameHeight.constant = 20
        self.viewPin.isHidden = false
        self.viewSuggest.isHidden = true
        
        let url = URL(string: "\(Constants.IMAGE_URL)\(shop.type?.image ?? "")")

        self.applyMarkerImage(from: url!, to: self.singleMarker!, ShopeName: shop.name ?? "")
        
        let camera = GMSCameraPosition.camera(withLatitude: self.orderModel?.pickUpLatitude ?? 0.0, longitude: self.orderModel?.pickUpLongitude ?? 0.0, zoom: 15.0)
        self.gMap?.animate(to: camera)
        
    }
    
    func getPlaceInfo(row: Int) {
        
        //self.edtOrderDetails.placeholder = "deliveryStep1.edtDetails.yourLocation.placeholder".localized
        
        var input = GInput()
        input.keyword = autocompleteResults[row].placeId
        let lati = "\(self.latitude ?? 0)"
        let long = "\(self.longitude ?? 0)"
        self.ShopsCarouselView.isHidden = true
        self.buttomSheet.isHidden = false
        GoogleApi.shared.callApi(.placeInformation,input: input,lati: lati, long: long) { (response) in
            if let place =  response.data as? GApiResponse.PlaceInfo, response.isValidFor(.placeInformation) {
                DispatchQueue.main.async {
                    self.searchByKeyWordsBackgroundView.isHidden = true
                    self.searchByKeyWordsView.isHidden = true

                    if let lat = place.latitude, let lng = place.longitude{
                        for marker in self.shopMarkers {
                            marker.map = nil
                        }
                        self.searchField.text = place.formattedAddress ?? ""
                        self.searchField.endEditing(true)
                        self.view.endEditing(true)
                        self.orderModel?.pickUpLatitude = lat
                        self.orderModel?.pickUpLongitude = lng
                       //self.orderModel?.shop = shop
                        self.orderModel?.pickUpAddress = place.title ?? ""
                        self.singleMarker?.map = nil
                        self.singleMarker = GMSMarker()
                        self.singleMarker?.position = CLLocationCoordinate2D(latitude: lat , longitude: lng )
                       //self.singleMarker?.title =  "\(place.placeId ?? 0)"
                      //self.singleMarker?.snippet = "\(place.phoneNumber ?? "")"
                                           
                        self.viewShopDetails.isHidden = false
                        self.viewClearField.isHidden = false
                        
                        
                        // same thing shop image was removed
                
                            self.ivShop.image = UIImage(named: "ic_location_pin")
              
                        
                        self.edtMoreDetails = "\(place.title ?? "")\n\(place.formattedAddress)"
                        
                        // self.lblShopName.text = shop.name ?? ""
                       // self.shopNameHeight.constant = 20
                        self.viewPin.isHidden = false
                        self.viewSuggest.isHidden = true
                        self.viewSuggest.isHidden = true
                        
                        self.ivShop.isHidden = true
                        
                        self.edtMoreDetails = ""
                        
                        self.viewShopDetails.isHidden = true
                        self.viewClearField.isHidden = true
                        self.showActionSheet()
                        self.singleMarker?.icon = UIImage(named: "ic_location_pin")
                        //snuff1
                      //  let url = URL(string: "\(Constants.IMAGE_URL)\(shop.type?.selectedIcon ?? "")")
                       // self.applyMarkerImage(from: url!, to: self.singleMarker!)
                        self.singleMarker?.map = self.gMap
                        
                        let camera = GMSCameraPosition.camera(withLatitude: self.orderModel?.pickUpLatitude ?? 0.0, longitude: self.orderModel?.pickUpLongitude ?? 0.0, zoom: 15.0)
                        self.gMap?.animate(to: camera)
                    }
                }
            } else { print(response.error ?? "ERROR") }
        }
    }
}





