//
//  DeliveryStep2.swift
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
import AMPopTip

protocol Step2Delegate {
    func updateModel(model : OTWOrder)
}
class DeliveryStep2: BaseVC, Step3Delegate {
    
    @IBOutlet weak var lblPickupLocation: MyUILabel!
    
    @IBOutlet weak var lblDropLocation: MyUILabel!
    
    @IBOutlet weak var mapView: UIView!
    
    @IBOutlet weak var edtMoreDetails: MyUITextField!
    
    @IBOutlet weak var ivHandle: UIImageView!
    
    @IBOutlet weak var searchField: SearchTextField!
    
    
    @IBOutlet weak var moreDetailsView: UIView!
    
    @IBOutlet weak var lblDistance: UILabel!
    
    @IBOutlet weak var viewFromTo: CardView!
    
    var currentZoom: Float = 0.0
    var gMap : GMSMapView?
    
    var latitude : Double?
    var longitude : Double?
    
    var orderModel : OTWOrder?
    
    var dropLocation : CLLocation?
    
    var pinMarker : GMSMarker?
    var dropMarker :GMSMarker?
    
    var delegate : Step2Delegate?
    
    var selectedRoute: NSDictionary!
    
    var toolTipView : ToolTipView?
    
    var shops = [DataShop]()
    var filterShops = [DataShop]()
    
    @IBOutlet weak var lblSearch: MyUILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //        if (self.isArabic()) {
        //            self.ivHandle.image = UIImage(named: "ic_back_arabic")
        //        }
        gMap = GMSMapView()
        self.searchField.delegate = self
        self.lblPickupLocation.text = self.orderModel?.pickUpAddress ?? ""
        self.setUpGoogleMap()
        
        self.edtMoreDetails.text = self.orderModel?.dropOffDetails ?? ""
        
        
        let popTip = PopTip()
        popTip.bubbleColor = UIColor.processing
        popTip.textColor = UIColor.white
        
        popTip.show(text: "to_location_desc".localized, direction: .down, maxWidth: 260, in: self.view, from: self.viewFromTo.frame)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            popTip.hide()
        }
        
    }
    
    func googleSearchAction() {
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
    
    
    func selectDefaultDrop() {
        self.moreDetailsView.isHidden = false
        self.lblSearch.isHidden = true
        self.orderModel?.dropOffLatitude = self.latitude ?? 0.0
        self.orderModel?.dropOffLongitude = self.longitude ?? 0.0
        self.getAddressForMapCenter(location: CLLocation(latitude: self.latitude ?? 0.0, longitude: self.longitude ?? 0.0))
        self.drawLocationLine()
    }
    
    @IBAction func myLocationAction(_ sender: Any) {
        let camera = GMSCameraPosition.camera(withLatitude: self.latitude ?? 0.0, longitude: self.longitude ?? 0.0, zoom: 20.0)
        self.gMap?.animate(to: camera)
    }
    
    func updateModel(model: OTWOrder) {
        self.orderModel = model
    }
    
    func validate() -> Bool {
        if (self.orderModel?.dropOffLatitude ?? 0.0 == 0.0 || self.orderModel?.dropOffLongitude ?? 0.0 == 0.0) {
            self.showBanner(title: "alert".localized, message: "choose_drop_location".localized, style: UIColor.INFO)
            return false
        }
        //        if (self.edtMoreDetails.text?.count ?? 0 == 0) {
        //            self.showBanner(title: "alert".localized, message: "enter_dropoff_details".localized, style: UIColor.INFO)
        //            return false
        //        }
        return true
    }
    
    //    @IBAction func searchPlacesAction(_ sender: Any) {
    //        let autocompleteController = GMSAutocompleteViewController()
    //        autocompleteController.delegate = self
    //
    //        let filter = GMSAutocompleteFilter()
    //        filter.country = "KW"
    //        autocompleteController.primaryTextColor = UIColor.black
    //        autocompleteController.secondaryTextColor = UIColor.black
    //        autocompleteController.tintColor = UIColor.black
    //        autocompleteController.autocompleteFilter = filter
    //
    ////        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
    //
    //
    //        present(autocompleteController, animated: true, completion: nil)
    //    }
    
    @IBAction func searchAction(_ sender: Any) {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        present(autocompleteController, animated: true, completion: nil)
    }
    
    func setUpGoogleMap() {
        let camera = GMSCameraPosition.camera(withLatitude: self.latitude ?? 0.0, longitude: self.longitude ?? 0.0, zoom: 15.0)
        gMap = GMSMapView.map(withFrame: CGRect(x: 0, y: 0, width: self.mapView.frame.width, height: self.mapView.frame.height), camera: camera)
        gMap?.delegate = self
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: self.latitude ?? 0.0, longitude: self.longitude ?? 0.0)
        marker.title =  "my_location"
        marker.snippet = ""
        marker.map = gMap
        
        self.mapView.addSubview(gMap!)
        gMap?.bindFrameToSuperviewBounds()
        self.view.layoutSubviews()
        
        self.selectDefaultDrop()
    }
    
    @IBAction func step1Action(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func step2Action(_ sender: Any) {
        
    }
    
    @IBAction func step3Action(_ sender: Any) {
        if (self.validate()) {
            if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DeliveryStep3") as? DeliveryStep3
            {
                self.orderModel?.dropOffDetails = self.edtMoreDetails.text ?? ""
                vc.latitude = self.latitude
                vc.longitude = self.longitude
                vc.orderModel = self.orderModel
                vc.delegate = self
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    //    @IBAction func backAction(_ sender: Any) {
    //        self.saveBackModel()
    //    }
    
    func saveBackModel() {
        self.orderModel?.dropOffDetails = self.edtMoreDetails.text ?? ""
        self.delegate?.updateModel(model: self.orderModel!)
        self.navigationController?.popViewController(animated: true)
    }
    
    func drawLocationLine() {
        
        self.getFromToDistance()
        
        self.gMap?.clear()
        
        self.pinMarker?.map = nil
        let pickUpPosition = CLLocationCoordinate2D(latitude: self.orderModel?.pickUpLatitude ?? 0, longitude: self.orderModel?.pickUpLongitude ?? 0)
        self.pinMarker = GMSMarker(position: pickUpPosition)
        self.pinMarker?.title = "\(self.orderModel?.shop?.id ?? 0)"
        if (self.orderModel?.shop?.id ?? 0 > 0) {
            self.pinMarker?.icon = UIImage(named: "ic_map_shop")
            let url = URL(string: "\(Constants.IMAGE_URL)\(self.orderModel?.shop?.type?.selectedIcon ?? "")")
            self.applyMarkerImage(from: url!, to: self.pinMarker!)
        }else {
            self.pinMarker?.icon = UIImage(named: "ic_location_pin")
        }
        self.pinMarker?.map = self.gMap
        
        
        self.dropMarker?.map = nil
        let dropOffPosition = CLLocationCoordinate2D(latitude: self.orderModel?.dropOffLatitude ?? 0, longitude: self.orderModel?.dropOffLongitude ?? 0)
        self.dropMarker = GMSMarker(position: dropOffPosition)
        self.dropMarker?.title = "0"
        self.dropMarker?.icon = UIImage(named: "ic_location")
        self.dropMarker?.map = self.gMap
        
        self.getAddressForMapCenter()
        
        var bounds = GMSCoordinateBounds()
        bounds = bounds.includingCoordinate(self.pinMarker!.position)
        bounds = bounds.includingCoordinate(self.dropMarker!.position)
        self.gMap?.animate(with: GMSCameraUpdate.fit(bounds, withPadding: 155.0))
        
        //        let origin = "\(self.orderModel?.pickUpLatitude ?? 0),\(self.orderModel?.pickUpLongitude ?? 0)"
        //        let destination = "\(self.orderModel?.dropOffLatitude ?? 0),\(self.orderModel?.dropOffLongitude ?? 0)"
        //
        //        let urlString = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(destination)&mode=driving&key=\(Constants.GOOGLE_API_KEY)"
        //
        //        let url = URL(string: urlString)
        //        URLSession.shared.dataTask(with: url!, completionHandler: {
        //            (data, response, error) in
        //            if(error != nil){
        //                print("error")
        //            } else {
        //                do{
        //                    let json = try JSONSerialization.jsonObject(with: data!, options:.allowFragments) as! [String : AnyObject]
        //                    if let routes = json["routes"] as? NSArray {
        //                        if (routes.count > 0) {
        //                            self.gMap?.clear()
        //
        //                            self.selectedRoute = (json["routes"] as! Array<NSDictionary>)[0]
        //                          //  self.loadDistanceAndDuration()
        //
        //                            OperationQueue.main.addOperation({
        //                                for route in routes
        //                                {
        //                                    let routeOverviewPolyline:NSDictionary = (route as! NSDictionary).value(forKey: "overview_polyline") as! NSDictionary
        //                                    let points = routeOverviewPolyline.object(forKey: "points")
        //                                    let path = GMSPath.init(fromEncodedPath: points! as! String)
        //                                    let polyline = GMSPolyline.init(path: path)
        //                                    polyline.strokeWidth = 2
        //                                    polyline.strokeColor = UIColor.appDarkBlue
        //
        //                                    let bounds = GMSCoordinateBounds(path: path!)
        //                                    self.gMap?.animate(with: GMSCameraUpdate.fit(bounds, withPadding: 170.0))
        //
        //                                    polyline.map = self.gMap
        //
        //
        //                                    let pickUpPosition = CLLocationCoordinate2D(latitude: self.orderModel?.pickUpLatitude ?? 0, longitude: self.orderModel?.pickUpLongitude ?? 0)
        //                                    let pickMarker = GMSMarker(position: pickUpPosition)
        //                                    pickMarker.title = "\(self.orderModel?.shop?.id ?? 0)"
        //                                    if (self.orderModel?.shop?.id ?? 0 > 0) {
        //                                        pickMarker.icon = UIImage(named: "ic_map_shop")
        //                                        let url = URL(string: "\(Constants.IMAGE_URL)\(self.orderModel?.shop?.type?.selectedIcon ?? "")")
        //                                        self.applyMarkerImage(from: url!, to: pickMarker)
        //                                    }else {
        //                                        pickMarker.icon = UIImage(named: "ic_location_pin")
        //                                    }
        //                                    pickMarker.map = self.gMap
        //
        //
        //                                    let dropOffPosition = CLLocationCoordinate2D(latitude: self.orderModel?.dropOffLatitude ?? 0, longitude: self.orderModel?.dropOffLongitude ?? 0)
        //                                    let dropMarker = GMSMarker(position: dropOffPosition)
        //                                    dropMarker.title = "0"
        //                                    dropMarker.icon = UIImage(named: "ic_location")
        //                                    dropMarker.map = self.gMap
        //
        //                                }
        //                            })
        //
        //                        }else {
        //                            //no routes
        //                        }
        //
        //                    }else {
        //                       //no routes
        //                    }
        //
        //
        //                }catch let error as NSError{
        //                    print("error:\(error)")
        //                }
        //            }
        //        }).resume()
    }
    
    @IBAction func clearDropLocation(_ sender: Any) {
        self.moreDetailsView.isHidden = true
        self.lblSearch.isHidden = false
        self.lblDropLocation.text = ""
        self.orderModel?.dropOffAddress = ""
        self.orderModel?.dropOffLatitude = 0.0
        self.orderModel?.dropOffLongitude = 0.0
        self.edtMoreDetails.text = ""
        self.pinMarker?.map = nil
        self.dropLocation = nil
        self.gMap?.clear()
        self.toolTipView?.removeFromSuperview()
        self.lblDistance.text = ""
    }
    
    @IBAction func nextAction(_ sender: Any) {
        if (self.validate()) {
            if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DeliveryStep3") as? DeliveryStep3
            {
                self.orderModel?.dropOffDetails = self.edtMoreDetails.text ?? ""
                vc.latitude = self.latitude
                vc.longitude = self.longitude
                vc.orderModel = self.orderModel
                vc.delegate = self
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    fileprivate func getAddressForMapCenter() {
        let point : CGPoint = mapView.center
        let coordinate : CLLocationCoordinate2D = (self.dropMarker?.position)!
        let location =  CLLocation.init(latitude: coordinate.latitude, longitude: coordinate.longitude)
        self.dropLocation = location
        self.GetAnnotationUsingCoordinated(location)
    }
    fileprivate func getAddressForMapCenter(location : CLLocation) {
        self.dropLocation = location
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
                        
                        
                        self.lblDropLocation.text = strAddresMain
                        self.lblDropLocation.textColor = UIColor.appDarkBlue
                        self.orderModel?.dropOffAddress = strAddresMain
                        
                    }
                    else {
                        
                        self.lblDropLocation.text = "Loading".localized
                        self.lblDropLocation.textColor = UIColor.appDarkBlue
                        self.orderModel?.dropOffAddress = ""
                    }
                }
                else {
                    
                    self.lblDropLocation.text = "Loading".localized
                    self.lblDropLocation.textColor = UIColor.appDarkBlue
                    self.orderModel?.dropOffAddress = ""
                }
            }
            else {
                self.lblDropLocation.text = "Loading".localized
                self.lblDropLocation.textColor = UIColor.appDarkBlue
                self.orderModel?.dropOffAddress = ""
            }
        }
    }
    
    
    @IBAction func backBtnAction(_ sender: Any) {
        self.saveBackModel()
    }
    
    
    
    
    func getShopByPlaces(name : String, latitude : Double, longitude: Double) {
        
        ApiService.getPlacesAPI(input: name, latitude: latitude, longitude: longitude) { (response) in
            self.shops.removeAll()
            var filterItems = [SearchTextFieldItem]()
            self.filterShops.removeAll()
            for prediction in response.results ?? [Result]() {
                let dataShop = DataShop(id: 0, name: prediction.name ?? "", address: prediction.vicinity ?? "", latitude: prediction.geometry?.location?.lat ?? 0.0, longitude: prediction.geometry?.location?.lng ?? 0.0, phoneNumber: "", workingHours: "", images: [String](), rate: prediction.rating ?? 0.0, type: TypeClass(id: 0, name: prediction.types?[0] ?? "", image: "", selectedIcon: "", icon: ""), ownerId: "", googlePlaceId:  prediction.placeID ?? "", openNow: prediction.openingHours?.openNow ?? false, NearbyDriversCount :  0)
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
                self.orderModel?.dropOffLatitude = shop.latitude ?? 0.0
                self.orderModel?.dropOffLongitude = shop.longitude ?? 0.0
                self.orderModel?.shop = shop
                self.orderModel?.dropOffAddress = shop.name ?? ""
                self.orderModel?.dropOffDetails = shop.address ?? ""
                self.edtMoreDetails.text = shop.address ?? ""
                self.lblDropLocation.text = shop.name ?? ""
                self.lblDropLocation.textColor = UIColor.appDarkBlue
                
                self.view.endEditing(true)
                
                self.pinMarker?.map = nil
                self.pinMarker = GMSMarker()
                self.pinMarker?.position = CLLocationCoordinate2D(latitude: shop.latitude ?? 0.0, longitude: shop.longitude ?? 0.0)
                self.pinMarker?.title =  ""
                self.pinMarker?.icon = UIImage(named: "ic_location")
                self.pinMarker?.snippet = ""
                self.pinMarker?.map = self.gMap
                self.lblDropLocation.text = "Loading".localized
                self.lblDropLocation.textColor = UIColor.appDarkBlue
                self.getAddressForMapCenter()
                self.drawLocationLine()
                
            }
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
    
    func getFromToDistance() {
        let driverLatLng = CLLocation(latitude: self.orderModel?.pickUpLatitude ?? 0.0, longitude: self.orderModel?.pickUpLongitude ?? 0.0)
        let dropOffLatLng = CLLocation(latitude: self.orderModel?.dropOffLatitude ?? 0.0, longitude: self.orderModel?.dropOffLongitude ?? 0.0)
        let distanceInMeters = dropOffLatLng.distance(from: driverLatLng)
        let distanceInKM = distanceInMeters / 1000.0
        let distanceStr = String(format: "%.2f", distanceInKM)
        self.lblDistance.text = "\(distanceStr) \("km".localized)"
    }
    
    
    @IBAction func clearFieldAction(_ sender: Any) {
        self.edtMoreDetails.text = ""
    }
    
    @IBAction func searchGoogleAction(_ sender: Any) {
        self.googleSearchAction()
    }
    
}

extension DeliveryStep2 : GMSMapViewDelegate {
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        toolTipView?.removeFromSuperview()
    }
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        let id = marker.title ?? "0"
        if (id == "my_location") {
            self.orderModel?.dropOffLatitude = marker.position.latitude
            self.orderModel?.dropOffLongitude = marker.position.longitude
            self.getAddressForMapCenter(location: CLLocation(latitude: marker.position.latitude, longitude: marker.position.longitude))
            self.drawLocationLine()
            return true
        }
        if (Int(id) ?? 0 > 0) {
//            toolTipView?.removeFromSuperview()
//            toolTipView = UIView.fromNib()
//            if (self.orderModel?.shop?.id ?? 0 > 0) {
//                toolTipView?.lblTitle.text = self.orderModel?.shop?.name ?? ""
//                toolTipView?.lblDescription.text = self.orderModel?.shop?.address ?? ""
//                if (self.orderModel?.shop?.images?.count ?? 0 > 0) {
//                    let url = URL(string: "\(Constants.IMAGE_URL)\(self.orderModel?.shop?.images?[0] ?? "")")
//                    toolTipView?.ivLogo.kf.setImage(with: url)
//                }else {
//                   toolTipView?.ivLogo.image = UIImage(named: "ic_map_shop_selected")
//                }
//            }else {
//                toolTipView?.lblTitle.text = self.orderModel?.pickUpAddress ?? ""
//                toolTipView?.lblDescription.text = ""
//                toolTipView?.ivLogo.image = UIImage(named: "ic_location_pin")
//            }
//
//            if (self.orderModel?.shop?.id ?? 0 > 0) {
//                marker.icon = UIImage(named: "ic_map_shop_selected")
//            }else {
//                marker.icon = UIImage(named: "ic_location_pin")
//            }
//
//            toolTipView?.center = mapView.projection.point(for: marker.position)
//            mapView.addSubview(toolTipView!)
            return true
        }else {
            return true
        }
    }
    
    func mapView(_ mapView: GMSMapView, didLongPressAt coordinate: CLLocationCoordinate2D) {
        self.lblDropLocation.text = "Loading".localized
        self.lblDropLocation.textColor = UIColor.appDarkBlue
        self.orderModel?.dropOffLatitude = coordinate.latitude
        self.orderModel?.dropOffLongitude = coordinate.longitude
        self.orderModel?.dropOffAddress = ""
        self.moreDetailsView.isHidden = false
        self.lblSearch.isHidden = true
        self.drawLocationLine()
    }
    
}

extension DeliveryStep2: GMSAutocompleteViewControllerDelegate {
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        //        let camera = GMSCameraPosition.camera(withLatitude:place.coordinate.latitude, longitude:place.coordinate.longitude, zoom: 17.0)
        dismiss(animated: true, completion: {
            self.orderModel?.dropOffLatitude = place.coordinate.latitude
            self.orderModel?.dropOffLongitude = place.coordinate.longitude
            self.lblDropLocation.text = place.name ?? ""
            self.drawLocationLine()
            // self.gMap?.animate(to: camera)
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
extension DeliveryStep2: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField == self.searchField {
            let maxLength = 100
            let currentString: NSString = textField.text as NSString? ?? ""
            let newString: NSString =
                currentString.replacingCharacters(in: range, with: string) as NSString
            if (newString.length >= 3) {
                //                self.getShopsByName(name: newString as String, latitude: self.latitude ?? 0.0, longitude: self.longitude ?? 0.0, radius: Float(Constants.DEFAULT_RADIUS))
                
                self.getShopByPlaces(name: newString as String, latitude: self.latitude ?? 0.0, longitude: self.longitude ?? 0.0)
            }
            if (newString.length == 0) {
                self.gMap?.clear()
            }
            return newString.length <= maxLength
        }
        
        return false
    }
    
}
