//
//  SelectLocationVC.swift
//  rzq
//
//  Created by Zaid najjar on 5/14/19.
//  Copyright © 2019 technzone. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces

protocol SelectLocationDelegate {
    func selectedLocation(location: CLLocation, address : String)
}
struct RequestLoction {
    var location : CLLocation
    var address : String
}

class SelectLocationViewController: BaseVC {
    var locationSelected = false
    
    var delegate : SelectLocationDelegate?
    
    @IBOutlet weak var btnBack: UIButton!
    
    @IBOutlet weak var ivHandle: UIImageView!
    
    var selectedLocation:CLLocation?
    // MARK: Properties
    var markerLocation: GMSMarker?
    var currentZoom: Float = 0.0
    var mapView = GMSMapView()
    //    var locationManager = CLLocationManager()
    var requestLocation: RequestLoction?
    
    // MARK: Outlets
    @IBOutlet weak var viewGoogleMap: UIView!
    @IBOutlet weak var imgPinCenter: UIImageView!
    @IBOutlet var selectedLocationLabel: UILabel!
    
    // MARK: UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        if (self.isArabic()) {
          self.ivHandle.image = UIImage(named: "ic_back_arabic")
        }
        let loc = CLLocationCoordinate2D(latitude: 24.7136, longitude: 46.6753)
        mapView.camera = GMSCameraPosition(target: loc, zoom: 15, bearing: 0, viewingAngle: 0)
        
        setUpGoogleMap()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        //        if self.locationSelected == false {
        //            self.addLocationVC?.gpsButton.stopAnimation()
        //            self.addLocationVC?.manualButtonClicked((self.addLocationVC?.manualButton)!)
        //        }
        
    }
    
    // MARK:- Methods
    // MARK: Actions
    @IBAction func showMyLocationButtonClicked(_ sender: UIButton) {
        
        switch LabasLocationManager.shared.getLocationServiceState() {
        case .allowed:
            if self.mapView.myLocation != nil {
                self.mapView.animate(toLocation: self.mapView.myLocation!.coordinate)
            }
        case .denied:
            self.showAlert(title: "LocationNotEnabled".localized, message: "PleaseEnableLocation".localized, actionTitle: "ok".localized, cancelTitle: "cancel".localized, actionHandler: {
                LabasLocationManager.shared.openAppLocationSetting()
            }) {
                
            }
        case .notEnabled:
            self.showAlert(title: "LocationNotEnabled".localized, message: "PleaseEnableLocation".localized, actionTitle: "ok".localized, cancelTitle: "cancel".localized, actionHandler: {
                LabasLocationManager.shared.openAppLocationSetting()
            }) {
                
            }
        }
    }
    
    @IBAction func switchMapMode(_ sender: UIButton) {
        if self.mapView.mapType == .satellite{
            self.mapView.mapType = .normal
            sender.setImage(#imageLiteral(resourceName: "unselectedSatlite") , for: .normal)
        }else{
            self.mapView.mapType = .satellite
            sender.setImage(#imageLiteral(resourceName: "selectedSatlite"), for: .normal)
        }
    }
    
    @IBAction func nextButtonClicked(_ sender: UIButton) {
        locationSelected = true
        self.delegate?.selectedLocation(location: self.selectedLocation!, address: self.selectedLocationLabel.text ?? "")
        self.navigationController?.popViewController(animated: true)
        
    }
    
    
    @IBAction func searchLocationClicked(_ sender: UIButton) {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        present(autocompleteController, animated: true, completion: nil)
    }
    // MARK: Public methods
    
    
    
    fileprivate func setUpGoogleMap() {
        
        var latitude : CLLocationDegrees = LabasLocationManager.shared.defaultLocation.coordinate.latitude
        var longitude : CLLocationDegrees = LabasLocationManager.shared.defaultLocation.coordinate.longitude
        
        if let currentLocation = LabasLocationManager.shared.currentLocation {
            latitude = currentLocation.coordinate.latitude
            longitude = currentLocation.coordinate.longitude
            
            //            latitude = 24.7136
            //            longitude = 46.6753
        } else {
            LabasLocationManager.shared.delegate = self
            LabasLocationManager.shared.startUpdatingLocation()
        }
        
        currentZoom = 15
        
        let camera : GMSCameraPosition = GMSCameraPosition.camera(withLatitude: latitude, longitude: longitude, zoom: 15, bearing: 3, viewingAngle: 0)
        
        viewGoogleMap.layer.masksToBounds = true
        mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        mapView.delegate = self
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = false
        mapView.settings.compassButton = false
        mapView.isIndoorEnabled = false
        viewGoogleMap.addSubview(mapView)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.0) {
            self.mapView.frame = self.viewGoogleMap.frame
            self.view.layoutIfNeeded()
        }
        
    }
    
    fileprivate func getAddressForMapCenter() {
        let point : CGPoint = mapView.center
        let coordinate : CLLocationCoordinate2D = mapView.projection.coordinate(for: point)
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
                        
                        self.selectedLocationLabel.text = strAddresMain
                        self.requestLocation = RequestLoction(location: location, address: strAddresMain)
                        
                    }
                    else {
                        self.selectedLocationLabel.text = "Loading".localized
                        self.requestLocation = nil
                    }
                }
                else {
                    self.selectedLocationLabel.text = "Loading".localized
                    self.requestLocation = nil
                }
            }
            else {
                self.selectedLocationLabel.text = "Loading".localized
                self.requestLocation = nil
            }
        }
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}

extension SelectLocationViewController : GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        mapView.clear()
        self.selectedLocationLabel.text = "Loading".localized
    }
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        self.selectedLocationLabel.text = "Loading".localized
        self.getAddressForMapCenter()
    }
    
    
}


extension SelectLocationViewController: LabasLocationManagerDelegate {
    func labasLocationManager(didUpdateLocation location:CLLocation) {
        
        if let currentLocation = LabasLocationManager.shared.currentLocation {
            let latitude = currentLocation.coordinate.latitude
            let longitude = currentLocation.coordinate.longitude
            
            let camera : GMSCameraPosition = GMSCameraPosition.camera(withLatitude: latitude, longitude: longitude, zoom: 15, bearing: 3, viewingAngle: 0)
            
            self.mapView.animate(to: camera)
            LabasLocationManager.shared.stopUpdatingLocation()
        }
        
    }
    
}

extension SelectLocationViewController: GMSAutocompleteViewControllerDelegate {
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        let camera = GMSCameraPosition.camera(withLatitude:place.coordinate.latitude, longitude:place.coordinate.longitude, zoom: 17.0)
        dismiss(animated: true, completion: {
            self.mapView.animate(to: camera)
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
