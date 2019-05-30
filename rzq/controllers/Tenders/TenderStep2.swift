//
//  TenderStep2.swift
//  rzq
//
//  Created by Zaid najjar on 5/26/19.
//  Copyright © 2019 technzone. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import MapKit
import CoreLocation

class TenderStep2: BaseVC {
    
    @IBOutlet weak var lblDropLocation: MyUILabel!
    
    @IBOutlet weak var mapView: UIView!
    
    @IBOutlet weak var edtMoreDetails: MyUITextField!
    
    @IBOutlet weak var searchAddress: MyUITextField!
    
    @IBOutlet weak var ivHandle: UIImageView!
    
    
    var markerLocation: GMSMarker?
    var currentZoom: Float = 0.0
    var gMap : GMSMapView?
    
    var latitude : Double?
    var longitude : Double?
    
    var orderModel : TNDROrder?
    
    var dropLocation : CLLocation?
    
    var pinMarker : GMSMarker?
    
    var selectedRoute: NSDictionary!
    
    var toolTipView : ToolTipView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        super.viewDidLoad()
        if (self.isArabic()) {
            self.ivHandle.image = UIImage(named: "ic_back_arabic")
        }
        gMap = GMSMapView()
        self.setUpGoogleMap()
        
        self.edtMoreDetails.text = self.orderModel?.dropOffDetails ?? ""
    }
    
    func selectDefaultDrop() {
        self.orderModel?.dropOffLatitude = self.latitude ?? 0.0
        self.orderModel?.dropOffLongitude = self.longitude ?? 0.0
        self.getAddressForMapCenter(location: CLLocation(latitude: self.latitude ?? 0.0, longitude: self.longitude ?? 0.0))
    }
    
    @IBAction func myLocationAction(_ sender: Any) {
        let camera = GMSCameraPosition.camera(withLatitude: self.latitude ?? 0.0, longitude: self.longitude ?? 0.0, zoom: 20.0)
        self.gMap?.animate(to: camera)
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
    
    @IBAction func searchPlacesAction(_ sender: Any) {
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
        
        //        let marker = GMSMarker()
        //        marker.position = CLLocationCoordinate2D(latitude: self.latitude ?? 0.0, longitude: self.longitude ?? 0.0)
        //        marker.title =  "my_location"
        //        marker.snippet = ""
        //        marker.map = gMap
        
        
        self.pinMarker?.map = nil
        self.pinMarker = GMSMarker()
        self.pinMarker?.position = CLLocationCoordinate2D(latitude: self.latitude ?? 0.0, longitude: self.longitude ?? 0.0)
        self.pinMarker?.title =  "my_location"
        self.pinMarker?.icon = UIImage(named: "ic_location")
        self.pinMarker?.snippet = ""
        self.pinMarker?.map = gMap
        self.lblDropLocation.text = "Loading".localized
        self.lblDropLocation.textColor = UIColor.appDarkBlue
        self.orderModel?.dropOffLatitude = self.latitude ?? 0.0
        self.orderModel?.dropOffLongitude = self.longitude ?? 0.0
        self.orderModel?.dropOffAddress = ""
        self.getAddressForMapCenter()
        
        
        self.mapView.addSubview(gMap!)
        gMap?.bindFrameToSuperviewBounds()
        self.view.layoutSubviews()
        
        self.selectDefaultDrop()
    }
    
    @IBAction func step1Action(_ sender: Any) {
        // self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func step2Action(_ sender: Any) {
        
    }
    
    @IBAction func step3Action(_ sender: Any) {
        
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.saveBackModel()
    }
    
    func saveBackModel() {
        self.navigationController?.popViewController(animated: true)
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
            self.goToStep3()
        }
    }
    
    func goToStep3() {
        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TenderStep3") as? TenderStep3
        {
            vc.orderModel = TNDROrder()
            self.orderModel?.dropOffDetails = self.edtMoreDetails.text ?? ""
            self.orderModel?.dropOffLatitude = self.pinMarker?.position.latitude
            self.orderModel?.dropOffLongitude = self.pinMarker?.position.longitude
            vc.orderModel = self.orderModel
            vc.latitude = self.latitude
            vc.longitude = self.longitude
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    fileprivate func getAddressForMapCenter() {
        let point : CGPoint = mapView.center
        let coordinate : CLLocationCoordinate2D = (self.pinMarker?.position)!
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
    
    
    
}

extension TenderStep2 : GMSMapViewDelegate {
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        toolTipView?.removeFromSuperview()
    }
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        return true
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
        self.lblDropLocation.textColor = UIColor.appDarkBlue
        self.orderModel?.dropOffLatitude = coordinate.latitude
        self.orderModel?.dropOffLongitude = coordinate.longitude
        self.orderModel?.dropOffAddress = ""
        self.getAddressForMapCenter()
    }
    
}

extension TenderStep2: GMSAutocompleteViewControllerDelegate {
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        //        let camera = GMSCameraPosition.camera(withLatitude:place.coordinate.latitude, longitude:place.coordinate.longitude, zoom: 17.0)
        dismiss(animated: true, completion: {
            self.orderModel?.dropOffLatitude = place.coordinate.latitude
            self.orderModel?.dropOffLongitude = place.coordinate.longitude
            self.lblDropLocation.text = place.name ?? ""
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