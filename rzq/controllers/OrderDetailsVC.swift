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
import FittedSheets


protocol OrderChatDelegate {
    func onOrderPaymentSuccess()
    func onOrderPaymentFail()
    func onCloseFromNotification()
}
class OrderDetailsVC: PaymentViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, AVAudioPlayerDelegate, PaymentSheetDelegate, PaymentDelegate {
    
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
    @IBOutlet weak var btnChat: UIButton!
    
    @IBOutlet weak var viewCancel: UIView!
    @IBOutlet weak var btnCancel: MyUIButton!
    
    @IBOutlet weak var audioViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var imagesViewHeight: NSLayoutConstraint!
    @IBOutlet weak var btnPlay: UIButton!
    
    @IBOutlet weak var ivHandle: UIImageView!
    
    @IBOutlet weak var recordLine: UIView!
    
    @IBOutlet weak var lblServiceName: MyUILabel!
    
    @IBOutlet weak var pickupHeight: NSLayoutConstraint!
    @IBOutlet weak var pickUpLine: UIView!
    
    @IBOutlet weak var viewPaymentMethod: UIView!
    @IBOutlet weak var paymentMethodHeight: NSLayoutConstraint!
    
    @IBOutlet weak var lblPaymentMethod: MyUILabel!
    
    var sheetController : SheetViewController?
    
    @IBOutlet weak var btnChangeMethod: MyUIButton!
    
    @IBOutlet weak var viewChangeMethod: CardView!
    
    var player : AVPlayer?
    
    var markerLocation: GMSMarker?
    var currentZoom: Float = 0.0
    var gMap : GMSMapView?
    
    var latitude : Double?
    var longitude : Double?
    
    var isPay : Bool?
    
    var delegate : OrderChatDelegate?
    
    
    var order : DataClassDelObj?
    
    var selectedRoute: NSDictionary!
    
    var items = [String]()
    
    @IBOutlet weak var btnViewItems: MyUIButton!
    
    @IBOutlet weak var viewViewItems: CardView!
    
    
    @IBOutlet weak var descriptionHright: NSLayoutConstraint!
    @IBOutlet weak var descriptionView: UIView!
    
    
    @IBOutlet weak var viewNavigate: UIView!
    @IBOutlet weak var viewNavigateHeight: NSLayoutConstraint!
    
    var audioPlayer: AVAudioPlayer?
    
    @IBOutlet weak var viewReorder: UIView!
    
    
    @IBOutlet weak var btnPay: MyUIButton!
    
    @IBOutlet weak var viewPay: UIView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (self.isArabic()) {
            self.ivHandle.image = UIImage(named: "ic_back_arabic")
        }
        self.setUpGoogleMap()
        self.lblStatus.text = self.order?.statusString ?? ""
        self.lblStatus.textColor = self.getStatusColor(status: self.order?.status ?? 0)
        
        if (self.order?.pickUpDetails?.count ?? 0 > 0) {
            self.lblPickup.text = "\(self.order?.fromAddress ?? "") ,\(self.order?.pickUpDetails ?? "")"
        }else {
            self.lblPickup.text = self.order?.fromAddress ?? ""
        }
        if (self.order?.dropOffDetails?.count ?? 0 > 0) {
            self.lblDropoff.text = "\(self.order?.toAddress ?? "") ,\(self.order?.dropOffDetails ?? "")"
        }else {
            self.lblDropoff.text = self.order?.toAddress ?? ""
        }
        
        if (self.order?.type == 2 || self.order?.type == 3) {
            self.pickupHeight.constant = 0
            self.pickUpLine.isHidden = true
        }else {
            self.pickupHeight.constant = 51
            self.pickUpLine.isHidden = false
        }
        
        let price = self.order?.cost ?? 0.0
        if (price > 10) {
            self.lblCost.text = "> 10 \("currency".localized)"
        }else {
            self.lblCost.text = "< 10 \("currency".localized)"
        }
        //        self.lblCost.text = "\(self.order?.cost ?? 0.0) \("currency".localized)"
        
        if (self.order?.time ?? 0 > 0) {
            self.lblTime.text = "\(self.order?.time ?? 0) \("hours".localized)"
        }else {
            self.lblTime.text = "asap".localized
        }
        
        self.lblDescription.text = self.order?.desc ?? ""
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
        if (self.isProvider()) {
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
            self.recordLine.isHidden = true
        }
        
        if (self.order?.images?.count ?? 0 == 0) {
            self.imagesViewHeight.constant = 0
        }
        
        
        if (self.isProvider()  && DataManager.loadUser().data?.userID == self.order?.driverId) {
            self.viewCancel.isHidden = true
        }else {
            if (self.order?.status == Constants.ORDER_PENDING) {
                self.viewCancel.isHidden = false
            }else {
                self.viewCancel.isHidden = true
            }
        }
        
        if (self.order?.status == Constants.ORDER_PROCESSING) {
            if (self.isProvider() && DataManager.loadUser().data?.userID == self.order?.driverId ?? "") {
                viewNavigate.isHidden = false
                viewNavigateHeight.constant = 40
            }else {
                viewNavigate.isHidden = true
                viewNavigateHeight.constant = 0
            }
        }else {
            viewNavigate.isHidden = true
            viewNavigateHeight.constant = 0
        }
        
        self.selectPaymentMethod(method: self.order?.paymentMethod ?? Constants.PAYMENT_METHOD_CASH)
        
        if (self.order?.status == Constants.ORDER_PROCESSING || self.order?.status == Constants.ORDER_PENDING || self.order?.status == Constants.ORDER_ON_THE_WAY) {
            if (self.isProvider() && DataManager.loadUser().data?.userID == self.order?.driverId ?? "") {
                self.btnChangeMethod.isHidden = true
                self.viewChangeMethod.isHidden = true
            }else {
                self.btnChangeMethod.isHidden = false
                self.viewChangeMethod.isHidden = false
                //testing
                //self.btnChangeMethod.isHidden = true
                //self.viewChangeMethod.isHidden = true
            }
        }else {
            self.btnChangeMethod.isHidden = true
            self.viewChangeMethod.isHidden = true
        }
        
        if (self.order?.items?.count ?? 0 == 0) {
            self.btnViewItems.isHidden = true
            self.viewViewItems.isHidden = true
        }
        
        if (self.order?.status == Constants.ORDER_COMPLETED || self.order?.status == Constants.ORDER_CANCELLED || self.order?.status == Constants.ORDER_EXPIRED) {
            if (self.isProvider() && DataManager.loadUser().data?.userID == self.order?.driverId ?? "") {
                self.viewReorder.isHidden = true
            }else {
                self.viewReorder.isHidden = false
            }
        }else {
            self.viewReorder.isHidden = true
        }
        
        
        if (self.isProvider() && DataManager.loadUser().data?.userID == self.order?.driverId ?? "") {
            self.btnPay.isHidden = true
            self.viewPay.isHidden = true
        }else {
            // if (self.isPay ?? false) {
            if (self.order?.paymentMethod == Constants.PAYMENT_METHOD_KNET && (self.order?.isPaid ?? false) == false) {
                if (self.order?.status == Constants.ORDER_PENDING || self.order?.status == Constants.ORDER_PROCESSING || self.order?.status == Constants.ORDER_ON_THE_WAY) {
                    //for testing
                    self.btnPay.isHidden = false
                    self.viewPay.isHidden = false
                }else {
                    self.btnPay.isHidden = true
                    self.viewPay.isHidden = true
                }
            }else {
                self.btnPay.isHidden = true
                self.viewPay.isHidden = true
            }
            
            //            }else {
            //                self.btnPay.isHidden = true
            //                self.viewPay.isHidden = true
            //            }
            
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
        
        var bounds = GMSCoordinateBounds()
        bounds = bounds.includingCoordinate(pickMarker.position)
        bounds = bounds.includingCoordinate(dropMarker.position)
        self.gMap?.animate(with: GMSCameraUpdate.fit(bounds, withPadding: 155.0))
        
        
        //        let origin = "\(fromLatitude ?? 0),\(fromLongitude ?? 0)"
        //        let destination = "\(toLatitude ?? 0),\(toLongitude ?? 0)"
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
        //                            //  self.loadDistanceAndDuration()
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
        //                                    self.gMap?.animate(with: GMSCameraUpdate.fit(bounds, withPadding: 30.0))
        //
        //                                    polyline.map = self.gMap
        //
        //
        //                                    let pickUpPosition = CLLocationCoordinate2D(latitude: fromLatitude ?? 0.0, longitude: fromLongitude ?? 0.0)
        //                                    let pickMarker = GMSMarker(position: pickUpPosition)
        //                                    pickMarker.title = ""
        //                                    pickMarker.icon = UIImage(named: "ic_map_shop")
        //                                    pickMarker.map = self.gMap
        //
        //
        //                                    let dropOffPosition = CLLocationCoordinate2D(latitude: toLatitude ?? 0.0, longitude: toLongitude ?? 0.0)
        //                                    let dropMarker = GMSMarker(position: dropOffPosition)
        //                                    dropMarker.title = ""
        //                                    dropMarker.icon = UIImage(named: "ic_location")
        //                                    dropMarker.map = self.gMap
        //
        //                                }
        //                            })
        //                        }else {
        //                            //no routes
        //                        }
        //
        //                    }else {
        //                        //no routes
        //                    }
        //
        //                }catch let error as NSError{
        //                    print("error:\(error)")
        //                }
        //            }
        //        }).resume()
    }
    
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func trackAction(_ sender: Any) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MapNavigationController") as! UINavigationController
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func playRecordAction(_ sender: Any) {
        // playSound(soundUrl: ("\(Constants.IMAGE_URL)\(self.order?.voiceFile ?? "")"))
        let url = URL(string: ("\(Constants.IMAGE_URL)\(self.order?.voiceFile ?? "")"))
        self.downloadFileFromURL(url: url!)
    }
    
    func playRecord(path : URL) {
        //        let playerItem:AVPlayerItem = AVPlayerItem(url: path)
        //        let audioPlayer = AVPlayer(playerItem: playerItem)
        //        audioPlayer.volume = 1.0
        //        audioPlayer.isMuted = false
        //        audioPlayer.play()
        
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
    
    func downloadFileFromURL(url:URL){
        
        var downloadTask:URLSessionDownloadTask
        downloadTask = URLSession.shared.downloadTask(with: url, completionHandler: { (url, response, error) in
            // self.play(url: url!)
            self.playRecord(path: url!)
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
            
            //            let order = DatumDel(driverID: self.order?.driverId ?? "", canReport: false, canTrack: false, id: self.order?.id ?? 0, chatId: self.order?.chatId ?? 0, fromAddress: self.order?.fromAddress ?? "", toAddress: self.order?.toAddress ?? "", title: self.order?.title ?? "", status: self.order?.status ?? 0, price: self.order?.cost ?? 0.0, time: self.order?.time ?? 0, statusString: self.order?.statusString ?? "", image: "", createdDate: self.order?.createdDate ?? "", toLatitude: self.order?.toLatitude ?? 0.0, toLongitude: self.order?.toLongitude ?? 0.0, fromLatitude: self.order?.fromLatitude ?? 0.0, fromLongitude: self.order?.fromLongitude ?? 0.0, driverName: "", driverImage: "", driverRate: 0, canRate: false, canCancel: false, canChat: false)
            
            let order = DatumDel(id: self.order?.id ?? 0, title: self.order?.title ?? "", status: self.order?.status ?? 0, statusString: self.order?.statusString ?? "", image: "", createdDate: self.order?.createdDate ?? "", chatId: self.order?.chatId ?? 0, fromAddress: self.order?.fromAddress ?? "", fromLatitude: self.order?.fromLatitude ?? 0.0, fromLongitude: self.order?.fromLongitude ?? 0.0, toAddress: self.order?.toAddress ?? "", toLatitude: self.order?.toLatitude ?? 0.0, toLongitude: self.order?.toLongitude ?? 0.0, providerID: self.order?.driverId, providerName: "", providerImage: "", providerRate: 0, time: self.order?.time ?? 0, price: self.order?.cost ?? 0.0, serviceName: "", paymentMethod: self.order?.paymentMethod ?? 0, items: self.order?.items ?? [ShopMenuItem](), isPaid: self.order?.isPaid ?? false, invoiceId: self.order?.invoiceId ?? "", toFemaleOnly: self.order?.toFemaleOnly ?? false, shopId: self.order?.shopId ?? 0, OrderPrice: self.order?.orderPrice ?? 0.0, KnetCommission: self.order?.KnetCommission ?? 0.0, ClientPhone: self.order?.ClientPhone ?? "", ProviderPhone : self.order?.ProviderPhone ?? "")
            
            messagesVC.order = order
            messagesVC.user = DataManager.loadUser()
            let nav: UINavigationController = UINavigationController.init(rootViewController: messagesVC)
            nav.modalPresentationStyle = .fullScreen
            messagesVC.modalPresentationStyle = .fullScreen
            self.navigationController?.present(nav, animated: true, completion: nil)
        }
    }
    
    func cancelDeliveryByUser(reason : String) {
        ApiService.cancelDelivery(Authorization: DataManager.loadUser().data?.accessToken ?? "", deliveryId: self.order?.id ?? 0, reason : reason, completion: { (response) in
            if (response.errorCode == 0) {
                self.showBanner(title: "alert".localized, message: "delivery_cancelled".localized, style: UIColor.SUCCESS)
                DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                    self.navigationController?.popViewController(animated: true)
                })
            }else {
                self.showBanner(title: "alert".localized, message: response.errorMessage ?? "", style: UIColor.INFO)
            }
        })
    }
    
    func cancelDeliveryByDriver(reason : String) {
        ApiService.cancelDeliveryByDriver(Authorization: DataManager.loadUser().data?.accessToken ?? "", deliveryId: self.order?.id ?? 0, reason : reason, completion: { (response) in
            if (response.errorCode == 0) {
                self.showBanner(title: "alert".localized, message: "delivery_cancelled".localized, style: UIColor.SUCCESS)
                DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                    self.navigationController?.popViewController(animated: true)
                })
            }else {
                self.showBanner(title: "alert".localized, message: response.errorMessage ?? "", style: UIColor.INFO)
            }
        })
    }
    
    @IBAction func cancelOrderAction(_ sender: Any) {
        //        self.showAlert(title: "alert".localized, message: "confirm_cancel_delivery".localized, actionTitle: "yes".localized, cancelTitle: "no".localized, actionHandler: {
        //            if (self.isProvider() && DataManager.loadUser().data?.userID == self.order?.driverId ?? "") {
        //                self.cancelDeliveryByDriver()
        //            }else {
        //                self.cancelDeliveryByUser()
        //            }
        //        })
        
        self.showAlertField(title: "alert".localized, message: "confirm_cancel_delivery".localized, actionTitle: "yes".localized, cancelTitle: "no".localized) { (reason) in
            if (self.isProvider() && DataManager.loadUser().data?.userID == self.order?.driverId ?? "") {
                self.cancelDeliveryByDriver(reason : reason)
            }else {
                self.cancelDeliveryByUser(reason : reason)
            }
        }
    }
    
    
    @IBAction func navigateToShopAction(_ sender: Any) {
        self.startNavigation(longitude: self.order?.fromLongitude ?? 0.0, latitude: self.order?.fromLatitude ?? 0.0)
    }
    
    
    @IBAction func navigateToClientAction(_ sender: Any) {
        self.startNavigation(longitude: self.order?.toLongitude ?? 0.0, latitude: self.order?.toLatitude ??  0.0)
    }
    
    
    func startNavigation(longitude : Double, latitude : Double) {
        let sourceSelector = UIAlertController(title: "continueUsing".localized, message: nil, preferredStyle: .actionSheet)
        
        if let popoverController = sourceSelector.popoverPresentationController {
            popoverController.sourceView = self.view //to set the source of your alert
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0) // you can set this as per your requirement.
            popoverController.permittedArrowDirections = [] //to hide the arrow of any particular direction
        }
        
        let googleMapsAction = UIAlertAction(title: "googleMaps".localized, style: .default) { (action) in
            
            
            let url = URL(string: "https://www.google.com/maps/dir/?api=1&destination=\(latitude),\(longitude)&directionsmode=driving")
            
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url!, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url!)
            }
        }
        
        let appleMapsAction = UIAlertAction(title: "appleMaps".localized, style: .default) { (action) in
            
            let coordinate = CLLocationCoordinate2DMake(latitude ,longitude)
            let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate, addressDictionary:nil))
            mapItem.name = "\("") \("")"
            mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving])
            
        }
        let cancelAction = UIAlertAction(title: "cancel".localized, style: .cancel) { (action) in }
        
        sourceSelector.addAction(googleMapsAction)
        //  sourceSelector.addAction(appleMapsAction)
        sourceSelector.addAction(cancelAction)
        
        self.present(sourceSelector, animated: true, completion: nil)
    }
    
    @IBAction func changeMethodAction(_ sender: Any) {
        self.showPaymentMethodsSheet()
    }
    
    
    func showPaymentMethodsSheet() {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "PaymentMethodSheet") as! PaymentMethodSheet
        sheetController = SheetViewController(controller: controller, sizes: [.fixed(290)])
        sheetController?.handleColor = UIColor.app_green
        controller.selectedMethod = self.order?.paymentMethod ?? Constants.PAYMENT_METHOD_CASH
        controller.delegate = self
        
        self.present(sheetController!, animated: false, completion: nil)
    }
    
    func onSubmit(method: Int) {
        self.showLoading()
        ApiService.changePaymentMethod(Authorization: DataManager.loadUser().data?.accessToken ?? "", orderId: self.order?.id ?? 0, paymentMethod: method) { (response) in
            self.hideLoading()
            if (response.errorCode == 0) {
                self.showBanner(title: "alert".localized, message: "payment_method_changed".localized, style: UIColor.SUCCESS)
                self.order?.paymentMethod = method
                self.selectPaymentMethod(method: method)
                self.notifyDriver(method : method)
            }else {
                self.showBanner(title: "alert".localized, message: response.errorMessage ?? "", style: UIColor.INFO)
            }
        }
        self.sheetController?.closeSheet()
    }
    
    func notifyDriver(method : Int) {
        var type = 901
        if (method == Constants.PAYMENT_METHOD_KNET) {
            type = 902
        }
        self.showLoading()
        ApiService.sendUserNotification(Authorization: DataManager.loadUser().data?.accessToken ?? "", arabicTitle: "الطلب \(Constants.ORDER_NUMBER_PREFIX)\(self.order?.id ?? 0)", englishTitle: "Order \(Constants.ORDER_NUMBER_PREFIX)\(self.order?.id ?? 0)", arabicBody: "قام الزبون بتغيير طريقة الدفع", englishbody: "Client changed payment method for this order", userId: self.order?.driverId ?? "", type: type) { (response) in
            self.hideLoading()
        }
    }
    
    func selectPaymentMethod(method: Int) {
        var isPaid = "not_paid_title".localized
        if (self.order?.isPaid ?? false) {
            isPaid = "paid_title".localized
        }
        if (method == Constants.PAYMENT_METHOD_CASH) {
            self.lblPaymentMethod.text = "cash_on_delivery".localized
        }else if (method == Constants.PAYMENT_METHOD_BALANCE) {
            self.lblPaymentMethod.text = "by_coupon".localized
        }else {
            self.lblPaymentMethod.text = "\("knet".localized) \(isPaid)"
        }
    }
    
    @IBAction func viewItemsAction(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc : ViewMenuVC = storyboard.instantiateViewController(withIdentifier: "ViewMenuVC") as! ViewMenuVC
        vc.items = self.order?.items ?? [ShopMenuItem]()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    @IBAction func reorderAction(_ sender: Any) {
        self.showLoading()
        ApiService.getShopDetails(Authorization: DataManager.loadUser().data?.accessToken ?? "", id: self.order?.shopId ?? 0) { (response) in
            self.hideLoading()
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc1 : DeliveryStep1 = storyboard.instantiateViewController(withIdentifier: "DeliveryStep1") as! DeliveryStep1
            let vc2 : DeliveryStep2 = storyboard.instantiateViewController(withIdentifier: "DeliveryStep2") as! DeliveryStep2
            let vc3 : DeliveryStep3 = storyboard.instantiateViewController(withIdentifier: "DeliveryStep3") as! DeliveryStep3
            let model = OTWOrder()
            model.pickUpDetails = self.order?.pickUpDetails ?? ""
            model.pickUpAddress = self.order?.fromAddress ?? ""
            model.pickUpLatitude = self.order?.fromLatitude ?? 0.0
            model.pickUpLongitude = self.order?.fromLongitude ?? 0.0
            
            model.dropOffDetails = self.order?.dropOffDetails ?? ""
            model.dropOffAddress = self.order?.toAddress ?? ""
            model.dropOffLatitude = self.order?.toLatitude ?? 0.0
            model.dropOffLongitude = self.order?.toLongitude ?? 0.0
            
            model.images = self.order?.images ?? [String]()
            model.voiceRecord = self.order?.voiceFile ?? ""
            
            model.orderCost = String(self.order?.cost ?? 0.0)
            model.orderDetails = self.order?.desc ?? ""
            model.time = self.order?.time ?? 0
            model.fromReorder = true
            model.selectedItems = self.order?.items ?? [ShopMenuItem]()
            model.paymentMethod = self.order?.paymentMethod ?? Constants.PAYMENT_METHOD_CASH
            model.isFemale = self.order?.toFemaleOnly ?? false
            
            let shop = DataShop(id: response.shopData?.id ?? 0, name: response.shopData?.name ?? "", address: response.shopData?.address ?? "", latitude: response.shopData?.latitude ?? 0.0, longitude: response.shopData?.longitude ?? 0.0, phoneNumber: response.shopData?.phoneNumber ?? "", workingHours: response.shopData?.workingHours ?? "", images: response.shopData?.images ?? [String](), rate: response.shopData?.rate ?? 0.0, type: response.shopData?.type!, ownerId: response.shopData?.ownerId ?? "", googlePlaceId: response.shopData?.googlePlaceId ?? "", openNow: response.shopData?.openNow ?? true, NearbyDriversCount : response.shopData?.nearbyDriversCount ?? 0)
            
            model.shop = shop
            
            vc1.orderModel = OTWOrder()
            vc2.orderModel = OTWOrder()
            vc3.orderModel = OTWOrder()
            
            vc1.orderModel = model
            vc2.orderModel = model
            vc3.orderModel = model
            
            vc1.latitude = self.latitude ?? 0.0
            vc1.longitude = self.longitude ?? 0.0
            
            vc2.latitude = self.order?.fromLatitude ?? 0.0
            vc2.longitude = self.order?.fromLongitude ?? 0.0
            
            //  self.navigationController?.pushViewController(vc, animated: true)
            
            var controllers = self.navigationController?.viewControllers
            controllers?.append(vc1)
            controllers?.append(vc2)
            controllers?.append(vc3)
            self.navigationController?.setViewControllers(controllers!, animated: true)
        }
    }
    
    
    @IBAction func payAction(_ sender: Any) {
        
        let orderCost = self.order?.orderPrice ?? 0.0
        let  x = self.order?.KnetCommission ?? 0.0
        let commission = (x * 100).rounded() / 100
        
        let totalCost = orderCost + commission
        self.ammountToPay = Double(totalCost)
        self.initiatePayment()
        self.executePayment(paymentMethodId: 1)
    }
    
    func onPaymentSuccess(payment: PaymentStatusResponse) {
        self.showLoading()
        ApiService.createPaymentRecord(Authorization: DataManager.loadUser().data?.accessToken ?? "", orderId: self.order?.id ?? 0, payment: payment) { (response) in
            self.hideLoading()
            self.delegate?.onOrderPaymentSuccess()
            self.navigationController?.popViewController(animated: true)
        }
        
    }
    
    func onPaymentFail() {
        self.delegate?.onOrderPaymentFail()
    }
    
    func getTotal(items : [ShopMenuItem]) -> Double {
        var total = 0.0
        for item in items {
            var itemQuantity = item.quantity ?? 0
            if (itemQuantity == 0) {
                itemQuantity = item.count ?? 0
            }
            let doubleQuantity = Double(itemQuantity)
            let doublePrice = item.price ?? 0.0
            total = total + (doubleQuantity * doublePrice)
        }
        return total
    }
    
    func closeFromNotification() {
        self.delegate?.onCloseFromNotification()
        self.navigationController?.popViewController(animated: true)
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
