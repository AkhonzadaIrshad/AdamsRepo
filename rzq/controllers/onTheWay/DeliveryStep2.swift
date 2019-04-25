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

class DeliveryStep2: BaseVC {

    @IBOutlet weak var lblPickupLocation: MyUILabel!
    
    @IBOutlet weak var lblDropLocation: MyUILabel!
    
    @IBOutlet weak var mapView: UIView!
    
    @IBOutlet weak var edtMoreDetails: MyUITextField!
    
    @IBOutlet weak var searchAddress: MyUITextField!
    
    var markerLocation: GMSMarker?
    var currentZoom: Float = 0.0
    var gMap : GMSMapView?
    
    var latitude : Double?
    var longitude : Double?
    
    var orderModel : OTWOrder?
    
    var dropLocation : CLLocation?
    
    var pinMarker : GMSMarker?
    
    var selectedRoute: NSDictionary!
    
    var toolTipView : ToolTipView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        gMap = GMSMapView()
        self.lblPickupLocation.text = self.orderModel?.pickUpAddress ?? ""
        self.setUpGoogleMap()
    }
    
    func validate() -> Bool {
        if (self.orderModel?.dropOffLatitude ?? 0.0 == 0.0 || self.orderModel?.dropOffLongitude ?? 0.0 == 0.0) {
            self.showBanner(title: "alert".localized, message: "choose_drop_location".localized, style: UIColor.INFO)
            return false
        }
        if (self.edtMoreDetails.text?.count ?? 0 == 0) {
            self.showBanner(title: "alert".localized, message: "enter_dropoff_details".localized, style: UIColor.INFO)
            return false
        }
        return true
    }
    
    @IBAction func searchPlacesAction(_ sender: Any) {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        present(autocompleteController, animated: true, completion: nil)
    }
    
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
        marker.title =  ""
        marker.snippet = ""
        marker.map = gMap
        
        self.mapView.addSubview(gMap!)
        self.view.layoutSubviews()
        
        
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
    
    func drawLocationLine() {
        let origin = "\(self.orderModel?.pickUpLatitude ?? 0),\(self.orderModel?.pickUpLongitude ?? 0)"
        let destination = "\(self.orderModel?.dropOffLatitude ?? 0),\(self.orderModel?.dropOffLongitude ?? 0)"
        
        let urlString = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(destination)&mode=driving&key=AIzaSyDxtBzX5RkfCrl51ttGLHMKXAk9zrW4LLY"
        
        let url = URL(string: urlString)
        URLSession.shared.dataTask(with: url!, completionHandler: {
            (data, response, error) in
            if(error != nil){
                print("error")
            } else {
                do{
                    let json = try JSONSerialization.jsonObject(with: data!, options:.allowFragments) as! [String : AnyObject]
                    if let routes = json["routes"] as? NSArray {
                        if (routes.count > 0) {
                            self.gMap?.clear()
                            
                            self.selectedRoute = (json["routes"] as! Array<NSDictionary>)[0]
                          //  self.loadDistanceAndDuration()
                            
                            OperationQueue.main.addOperation({
                                for route in routes
                                {
                                    let routeOverviewPolyline:NSDictionary = (route as! NSDictionary).value(forKey: "overview_polyline") as! NSDictionary
                                    let points = routeOverviewPolyline.object(forKey: "points")
                                    let path = GMSPath.init(fromEncodedPath: points! as! String)
                                    let polyline = GMSPolyline.init(path: path)
                                    polyline.strokeWidth = 2
                                    polyline.strokeColor = UIColor.appDarkBlue
                                    
                                    let bounds = GMSCoordinateBounds(path: path!)
                                    self.gMap?.animate(with: GMSCameraUpdate.fit(bounds, withPadding: 30.0))
                                    
                                    polyline.map = self.gMap
                                    
                        
                                    let pickUpPosition = CLLocationCoordinate2D(latitude: self.orderModel?.pickUpLatitude ?? 0, longitude: self.orderModel?.pickUpLongitude ?? 0)
                                    let pickMarker = GMSMarker(position: pickUpPosition)
                                    pickMarker.title = "\(self.orderModel?.shop?.id ?? 0)"
                                    if (self.orderModel?.shop?.id ?? 0 > 0) {
                                        pickMarker.icon = UIImage(named: "ic_map_shop")
                                    }else {
                                        pickMarker.icon = UIImage(named: "ic_location_pin")
                                    }
                                    pickMarker.map = self.gMap
                                    
                                    
                                    let dropOffPosition = CLLocationCoordinate2D(latitude: self.orderModel?.dropOffLatitude ?? 0, longitude: self.orderModel?.dropOffLongitude ?? 0)
                                    let dropMarker = GMSMarker(position: dropOffPosition)
                                    dropMarker.title = "0"
                                    dropMarker.icon = UIImage(named: "ic_location")
                                    dropMarker.map = self.gMap
                                    
                                }
                            })
                        }else {
                            //no routes
                        }
                        
                    }else {
                       //no routes
                    }
                    
                }catch let error as NSError{
                    print("error:\(error)")
                }
            }
        }).resume()
    }
    
    @IBAction func clearDropLocation(_ sender: Any) {
        self.lblDropLocation.text = ""
        self.orderModel?.dropOffAddress = ""
        self.orderModel?.dropOffLatitude = 0.0
        self.orderModel?.dropOffLongitude = 0.0
        self.edtMoreDetails.text = ""
        self.pinMarker?.map = nil
        self.dropLocation = nil
        self.gMap?.clear()
        self.toolTipView?.removeFromSuperview()
    }
    
    @IBAction func nextAction(_ sender: Any) {
        if (self.validate()) {
            if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DeliveryStep3") as? DeliveryStep3
            {
                vc.latitude = self.latitude
                vc.longitude = self.longitude
                vc.orderModel = self.orderModel
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    fileprivate func getAddressForMapCenter() {
        let point : CGPoint = mapView.center
        let coordinate : CLLocationCoordinate2D = (self.pinMarker?.position)!
        let location =  CLLocation.init(latitude: coordinate.latitude, longitude: coordinate.longitude)
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
                        
                        
                        self.lblDropLocation.text = strAddresMain
                        self.orderModel?.dropOffAddress = strAddresMain
                        
                    }
                    else {
                        
                        self.lblDropLocation.text = "Loading".localized
                        self.orderModel?.dropOffAddress = ""
                    }
                }
                else {
                    
                    self.lblDropLocation.text = "Loading".localized
                    self.orderModel?.dropOffAddress = ""
                }
            }
            else {
                self.lblDropLocation.text = "Loading".localized
                self.orderModel?.dropOffAddress = ""
            }
        }
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
        if (Int(id)! > 0) {
            toolTipView?.removeFromSuperview()
            toolTipView = UIView.fromNib()
            if (self.orderModel?.shop?.id ?? 0 > 0) {
                toolTipView?.lblTitle.text = self.orderModel?.shop?.name ?? ""
                toolTipView?.lblDescription.text = self.orderModel?.shop?.address ?? ""
                let url = URL(string: "\(Constants.IMAGE_URL)\(self.orderModel?.shop?.image ?? "")")
                toolTipView?.ivLogo.kf.setImage(with: url)
            }else {
                toolTipView?.lblTitle.text = self.orderModel?.pickUpAddress ?? ""
                toolTipView?.lblDescription.text = ""
                toolTipView?.ivLogo.image = UIImage(named: "ic_location_pin")
            }
            
            if (self.orderModel?.shop?.id ?? 0 > 0) {
                marker.icon = UIImage(named: "ic_map_shop_selected")
            }else {
                marker.icon = UIImage(named: "ic_location_pin")
            }
            
            toolTipView?.center = mapView.projection.point(for: marker.position)
            mapView.addSubview(toolTipView!)
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
        self.pinMarker?.icon = UIImage(named: "ic_location")
        self.pinMarker?.snippet = ""
        self.pinMarker?.map = gMap
        self.lblDropLocation.text = "Loading".localized
        self.orderModel?.dropOffLatitude = coordinate.latitude
        self.orderModel?.dropOffLongitude = coordinate.longitude
        self.orderModel?.dropOffAddress = ""
        self.getAddressForMapCenter()
        self.drawLocationLine()
    }
    
}

extension DeliveryStep2: GMSAutocompleteViewControllerDelegate {
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        let camera = GMSCameraPosition.camera(withLatitude:place.coordinate.latitude, longitude:place.coordinate.longitude, zoom: 17.0)
        dismiss(animated: true, completion: {
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
