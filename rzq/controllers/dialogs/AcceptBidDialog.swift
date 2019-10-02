//
//  AcceptBidDialog.swift
//  rzq
//
//  Created by Zaid najjar on 4/14/19.
//  Copyright © 2019 technzone. All rights reserved.
//

import UIKit
import Cosmos
import CoreLocation

protocol AcceptBidDelegate {
    func refreshNotifications()
    func onAccept()
}
class AcceptBidDialog: BaseVC {
    
    @IBOutlet weak var ivLogo: CircleImage!
    @IBOutlet weak var lblDriverName: MyUILabel!
    @IBOutlet weak var rateView: CosmosView!
    @IBOutlet weak var lblMoney: MyUILabel!
    @IBOutlet weak var lblTime: MyUILabel!
    @IBOutlet weak var lblDistance: MyUILabel!
    @IBOutlet weak var lblOrdersCount: MyUILabel!
    @IBOutlet weak var lblOfferPrice: MyUILabel!

    var deliveryId  : Int?
    var bidId : Int?
    var notificationId : Int?
    var item : DatumNot?
    
    var latitude : Double?
    var longitude : Double?
    
    var delegate : AcceptBidDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.rateView.isUserInteractionEnabled = false
  
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let dict = self.item?.data?.convertToDictionary()
        
        if (item?.type == Constants.BID_CREATED) {
            let driver = dict?["Driver"] as? String ?? ""
            let driverImage = dict?["DriverImage"] as? String ?? ""
            let driverRate = dict?["DriverRate"] as? Double ?? 0.0
            let price = dict?["Price"] as? Double ?? 0.0
            let time = dict?["Time"] as? Int ?? 0
            let distance = dict?["Distance"] as? Double ?? 0.0
            self.deliveryId = dict?["OrderId"] as? Int ?? 0
            self.bidId = dict?["Id"] as? Int ?? 0
            let orderCount = dict?["OrderCount"] as? Int ?? 0
            
            let url = URL(string: "\(Constants.IMAGE_URL)\(driverImage)")
            self.ivLogo.kf.setImage(with: url)
            
            self.lblDriverName.text = driver
            self.rateView.rating = driverRate
            self.lblOfferPrice.text = "\(price) \("currency".localized)"
            self.lblMoney.text = "\(price) \("currency".localized)"
            if (time > 0) {
                self.lblTime.text = "\(time) \("hours".localized)"
            }else {
                self.lblTime.text = "asap".localized
            }
            
            self.lblDistance.text = "\(String(format: "%.2f", (distance))) \("km".localized)"
            self.lblOrdersCount.text = "\(orderCount) \("orders".localized)"
        }else if (item?.type == Constants.SERVICE_BID_CREATED) {
            let driver = dict?["ProviderName"] as? String ?? ""
            let driverImage = dict?["ProviderImage"] as? String ?? ""
            let driverRate = dict?["ProviderRate"] as? Double ?? 0.0
            let price = dict?["Price"] as? Double ?? 0.0
            let time = dict?["Time"] as? Int ?? 0
            let providerLatitude = dict?["Latitude"] as? Double ?? 0.0
            let providerLongitude = dict?["Longitude"] as? Double ?? 0.0
            self.deliveryId = dict?["OrderId"] as? Int ?? 0
            self.bidId = dict?["BidId"] as? Int ?? 0
            let orderCount = dict?["OrderCount"] as? Int ?? 0
            
            let url = URL(string: "\(Constants.IMAGE_URL)\(driverImage)")
            self.ivLogo.kf.setImage(with: url)
            
            self.lblDriverName.text = driver
            self.rateView.rating = driverRate
            self.lblOfferPrice.text = "\(price) \("currency".localized)"
            self.lblMoney.text = "\(price) \("currency".localized)"
            if (time > 0) {
                self.lblTime.text = "\(time) \("hours".localized)"
            }else {
                self.lblTime.text = "asap".localized
            }
            
            let driverLatLng = CLLocation(latitude: self.latitude ?? 0.0, longitude: self.longitude ?? 0.0)
            let dropOffLatLng = CLLocation(latitude: providerLatitude, longitude: providerLongitude)
            let distanceInMeters = dropOffLatLng.distance(from: driverLatLng)
            let distanceInKM = distanceInMeters / 1000.0
             let distanceStr = String(format: "%.2f", distanceInKM)
            
            self.lblDistance.text = "\(distanceStr) \("km".localized)"
            self.lblOrdersCount.text = "\(orderCount) \("orders".localized)"
        }
       
    }

    @IBAction func declineAction(_ sender: Any) {
        self.showLoading()
        ApiService.declineBid(Authorization: self.loadUser().data?.accessToken ?? "", bidId: self.bidId ?? 0) { (response) in
            self.hideLoading()
            if (response.errorCode == 0) {
                self.showBanner(title: "alert".localized, message: "bid_declined_successfully".localized, style: UIColor.SUCCESS)
                self.delegate?.refreshNotifications()
                DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                    self.dismiss(animated: true, completion: nil)
                })
            }else {
                self.showBanner(title: "alert".localized, message: response.errorMessage ?? "", style: UIColor.INFO)
            }
        }
    }
    
//    func deleteNotification() {
//        ApiService.deleteNotification(Authorization: self.loadUser().data?.accessToken ?? "", id: self.notificationId ?? 0) { (response) in
//            self.showBanner(title: "alert".localized, message: "bid_declined_successfully".localized, style: UIColor.SUCCESS)
//            DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
//                self.dismiss(animated: true, completion: nil)
//            })
//        }
//    }
    
    @IBAction func acceptAction(_ sender: Any) {
        self.showLoading()
        ApiService.acceptBid(Authorization: self.loadUser().data?.accessToken ?? "", deliveryId: self.deliveryId ?? 0, bidId: self.bidId ?? 0) { (response) in
            self.hideLoading()
            if (response.errorCode == 0) {
                self.showBanner(title: "alert".localized, message: "bid_accepted_successfully".localized, style: UIColor.SUCCESS)
                self.delegate?.onAccept()
                DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                    self.dismiss(animated: true, completion: nil)
                })
            }else {
                self.showBanner(title: "alert".localized, message: response.errorMessage ?? "", style: UIColor.INFO)
            }
            
        }
    }
    
    @IBAction func closeAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
