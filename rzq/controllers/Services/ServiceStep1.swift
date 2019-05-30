//
//  ServiceStep1.swift
//  rzq
//
//  Created by Zaid najjar on 5/23/19.
//  Copyright © 2019 technzone. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import MapKit
import CoreLocation
import Firebase

class ServiceStep1: BaseVC, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, LabasLocationManagerDelegate {

    @IBOutlet weak var mapView: UIView!
    @IBOutlet weak var ivHandle: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    var latitude : Double?
    var longitude : Double?
    
    var markerLocation: GMSMarker?
    var currentZoom: Float = 0.0
    var gMap : GMSMapView?
    
    let cameraZoom : Float = 15.0
    
    var items = [ServiceData]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        gMap = GMSMapView()
        
        if (self.isArabic()) {
            self.ivHandle.image = UIImage(named: "ic_back_arabic")
        }
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        if (self.latitude ?? 0.0 == 0.0 || self.longitude ?? 0.0 == 0.0) {
            self.showLoading()
            LabasLocationManager.shared.delegate = self
            LabasLocationManager.shared.startUpdatingLocation()
        }else {
            self.setUpGoogleMap()
        }
        
        ApiService.getAllServices(name: "") { (response) in
            self.items.removeAll()
            self.items.append(contentsOf: response.data ?? [ServiceData]())
            self.collectionView.reloadData()
        }

        // Do any additional setup after loading the view.
    }
    
    
    func labasLocationManager(didUpdateLocation location: CLLocation) {
        if (self.latitude ?? 0.0 == 0.0 || self.longitude ?? 0.0 == 0.0) {
            
//            self.latitude = location.coordinate.latitude
//            self.longitude = location.coordinate.longitude
            
                                    self.latitude = 29.273551
                                    self.longitude = 47.936161
            
            self.hideLoading()
            self.setUpGoogleMap()
            
        }
        //  self.loadTracks()
        
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
    }
    
    
    //collection delegates
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 113.0, height: 130.0)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let orderModel = SERVOrder()
        orderModel.service = self.items[indexPath.row]
        
        
        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ServiceStep2") as? ServiceStep2
        {
            vc.orderModel = SERVOrder()
            vc.orderModel = orderModel
            vc.latitude = self.latitude
            vc.longitude = self.longitude
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: ServiceCell = collectionView.dequeueReusableCell(withReuseIdentifier: "servicecell", for: indexPath as IndexPath) as! ServiceCell
        
        let item = self.items[indexPath.row]
        cell.lblName.text = item.name ?? ""
        
        if (item.image?.count ?? 0 > 0) {
            let url = URL(string: "\(Constants.IMAGE_URL)\(item.image ?? "")")
            cell.ivLogo.kf.setImage(with: url)
        }
    
        return cell
        
    }
    

    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
extension ServiceStep1 : GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        
    }
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        
    }
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        return true
    }
    func mapView(_ mapView: GMSMapView, didLongPressAt coordinate: CLLocationCoordinate2D) {
   
    }
}
