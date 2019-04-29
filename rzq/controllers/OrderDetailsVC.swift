//
//  OrderDetailsVC.swift
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
import AVFoundation

class OrderDetailsVC: BaseVC, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, AVAudioPlayerDelegate {
    
    @IBOutlet weak var mapView: UIView!
    
    @IBOutlet weak var lblStatus: MyUILabel!
    
    @IBOutlet weak var lblTime: MyUILabel!
    
    @IBOutlet weak var lblPickup: MyUILabel!
    
    @IBOutlet weak var lblDropoff: MyUILabel!
    
    @IBOutlet weak var lblCost: MyUILabel!
    
    @IBOutlet weak var lblDescription: MyUILabel!
    
    @IBOutlet weak var imagesCollection: UICollectionView!
    
    @IBOutlet weak var viewTrack: UIView!
    @IBOutlet weak var btnTrack: MyUIButton!
    
    @IBOutlet weak var viewChat: UIView!
    @IBOutlet weak var btnChat: MyUIButton!
    
    @IBOutlet weak var audioViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var imagesViewHeight: NSLayoutConstraint!
    @IBOutlet weak var btnPlay: UIButton!
    
    @IBOutlet weak var ivHandle: UIImageView!
    
    var player : AVPlayer?
    
    var markerLocation: GMSMarker?
    var currentZoom: Float = 0.0
    var gMap : GMSMapView?
    
    var latitude : Double?
    var longitude : Double?
    
    
    var order : DataClassDelObj?
    
    var selectedRoute: NSDictionary!
    
    var items = [String]()
    
    @IBOutlet weak var descriptionHright: NSLayoutConstraint!
    @IBOutlet weak var descriptionView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (self.isArabic()) {
            self.ivHandle.image = UIImage(named: "ic_back_arabic")
        }
        self.setUpGoogleMap()
        self.lblStatus.text = self.order?.statusString ?? ""
        self.lblStatus.textColor = self.getStatusColor(status: self.order?.status ?? 0)
        self.lblPickup.text = self.order?.fromAddress ?? ""
        self.lblDropoff.text = self.order?.toAddress ?? ""
        self.lblCost.text = "\(self.order?.cost ?? 0.0) \("currency".localized)"
        self.lblTime.text = "\(self.order?.time ?? 0) \("hours".localized)"
        self.lblDescription.text = self.order?.title ?? ""
        if (self.order?.status == Constants.ORDER_PROCESSING || self.order?.status == Constants.ORDER_ON_THE_WAY) {
            self.viewChat.isHidden = false
        }else {
            self.viewChat.isHidden = true
        }
        if (self.order?.status == Constants.ORDER_ON_THE_WAY) {
            self.viewTrack.isHidden = false
        }else {
            self.viewTrack.isHidden = true
        }
        if ((self.loadUser().data?.roles?.contains(find: "Driver"))!) {
            self.viewTrack.isHidden = true
        }
        
        self.items.append(contentsOf: self.order?.images ?? [String]())
        
        
        var newFrame  = self.descriptionView.frame
        self.lblDescription.numberOfLines = 0
        self.lblDescription.sizeToFit()
        newFrame.size.height = 55 + self.lblDescription.bounds.height
        self.descriptionHright.constant = newFrame.size.height
        
        self.imagesCollection.delegate = self
        self.imagesCollection.dataSource = self
        self.imagesCollection.reloadData()
        
        
        if (self.order?.voiceFile?.count ?? 0 == 0) {
            self.audioViewHeight.constant = 0
        }
        if (self.order?.images?.count ?? 0 == 0) {
            self.imagesViewHeight.constant = 0
        }
        
    }
    
    func getStatusColor(status : Int) -> UIColor {
        switch status {
        case Constants.ORDER_PENDING:
            return UIColor.pending
        case Constants.ORDER_PROCESSING:
            return UIColor.processing
        case Constants.ORDER_ON_THE_WAY:
            return UIColor.on_the_way
        case Constants.ORDER_CANCELLED:
            return UIColor.cancelled
        case Constants.ORDER_COMPLETED:
            return UIColor.delivered
        default:
            return UIColor.pending
        }
    }
    
    //collection delegates
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 120.0, height: 120.0)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ImageSliderVC") as? ImageSliderVC
        {
            vc.orderImages = self.items
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: OrderImageCell = collectionView.dequeueReusableCell(withReuseIdentifier: "orderimagecell", for: indexPath as IndexPath) as! OrderImageCell
        
        let url = URL(string: "\(Constants.IMAGE_URL)\(self.items[indexPath.row])")
        cell.ivLogo.kf.setImage(with: url)
        
        return cell
        
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
        gMap?.bindFrameToSuperviewBounds()
        self.view.layoutSubviews()
        
        self.drawLocationLine()
        
    }
    
    
    
    func drawLocationLine() {
        var fromLatitude : Double?
        var fromLongitude : Double?
        var toLatitude : Double?
        var toLongitude : Double?
        
        fromLatitude = self.order?.fromLatitude ?? 0.0
        fromLongitude = self.order?.fromLongitude ?? 0.0
        toLatitude = self.order?.toLatitude ?? 0.0
        toLongitude = self.order?.toLongitude ?? 0.0
        
        let origin = "\(fromLatitude ?? 0),\(fromLongitude ?? 0)"
        let destination = "\(toLatitude ?? 0),\(toLongitude ?? 0)"
        
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
                                    
                                    
                                    let pickUpPosition = CLLocationCoordinate2D(latitude: fromLatitude ?? 0.0, longitude: fromLongitude ?? 0.0)
                                    let pickMarker = GMSMarker(position: pickUpPosition)
                                    pickMarker.title = ""
                                    pickMarker.icon = UIImage(named: "ic_map_shop")
                                    pickMarker.map = self.gMap
                                    
                                    
                                    let dropOffPosition = CLLocationCoordinate2D(latitude: toLatitude ?? 0.0, longitude: toLongitude ?? 0.0)
                                    let dropMarker = GMSMarker(position: dropOffPosition)
                                    dropMarker.title = ""
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
    
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

    
    @IBAction func trackAction(_ sender: Any) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MapNavigationController") as! UINavigationController
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func playRecordAction(_ sender: Any) {
    // playSound(soundUrl: ("\(Constants.IMAGE_URL)\(self.order?.voiceFile ?? "")"))
        let url = URL(string: ("\(Constants.IMAGE_URL)\(self.order?.voiceFile ?? "")"))
        self.downloadFileFromURL(url: url!)
    }
    
    func downloadFileFromURL(url:URL){
        
        var downloadTask:URLSessionDownloadTask
        downloadTask = URLSession.shared.downloadTask(with: url, completionHandler: { (url, response, error) in
            self.play(url: url!)
        })
        
        downloadTask.resume()
        
    }
    
    func play(url:URL) {
        print("playing \(url)")
        DispatchQueue.main.async {
            self.btnPlay.setImage(UIImage(named: "ic_order_pause"), for: .normal)
        }
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.delegate = self
            player.prepareToPlay()
            player.volume = 1.0
            player.play()
        } catch let error as NSError {
            //self.player = nil
            print(error.localizedDescription)
        } catch {
            print("AVAudioPlayer init failed")
        }
        
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        DispatchQueue.main.async {
            self.btnPlay.setImage(UIImage(named: "ic_order_play"), for: .normal)
        }
    }
    
    
//    func playSound(soundUrl: String) {
//        let sound = URL(string: soundUrl)!
//        do {
//            let audioPlayer = try AVAudioPlayer(contentsOf: sound)
//            audioPlayer.prepareToPlay()
//            audioPlayer.play()
//        }catch let error {
//            print("Error: \(error.localizedDescription)")
//        }
//    }
    
    @IBAction func chatAction(_ sender: Any) {
         DispatchQueue.main.async {
        let messagesVC: ZHCDemoMessagesViewController = ZHCDemoMessagesViewController.init()
        messagesVC.presentBool = true
            
            let order = DatumDel(driverID: "", canReport: false, canTrack: false, id: self.order?.id ?? 0, chatId: self.order?.chatId ?? 0, fromAddress: self.order?.fromAddress ?? "", toAddress: self.order?.toAddress ?? "", title: self.order?.title ?? "", status: self.order?.status ?? 0, price: self.order?.cost ?? 0.0, time: self.order?.time ?? 0, statusString: self.order?.statusString ?? "", image: "", createdDate: self.order?.createdDate ?? "", toLatitude: self.order?.toLatitude ?? 0.0, toLongitude: self.order?.toLongitude ?? 0.0, fromLatitude: self.order?.fromLatitude ?? 0.0, fromLongitude: self.order?.fromLongitude ?? 0.0, driverName: "", driverImage: "", driverRate: 0, canRate: false, canCancel: false, canChat: false)
            
        messagesVC.order = order
        messagesVC.user = self.loadUser()
        let nav: UINavigationController = UINavigationController.init(rootViewController: messagesVC)
        self.navigationController?.present(nav, animated: true, completion: nil)
        }
    }
    
}
extension OrderDetailsVC : GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        
    }
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        
    }
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        //        let id = marker.title ?? "0"
        //        getshopinfo
        return true
    }
    
}
