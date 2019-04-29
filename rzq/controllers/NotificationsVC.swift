//
//  NotificationsVC.swift
//  rzq
//
//  Created by Zaid najjar on 4/3/19.
//  Copyright © 2019 technzone. All rights reserved.
//

import UIKit
import CoreLocation

class NotificationsVC: BaseViewController, UITableViewDelegate, UITableViewDataSource,LabasLocationManagerDelegate {
    
    @IBOutlet weak var btnMenu: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var emptyView: EmptyView!
    
    @IBOutlet weak var btnAbout: UIButton!
    
    
    var items = [DatumNot]()
    
    var latitude : Double?
    var longitude : Double?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.btnMenu.addTarget(self, action: #selector(BaseViewController.onSlideMenuButtonPressed(_:)), for: UIControl.Event.touchUpInside)
        
          self.btnAbout.addTarget(self, action: #selector(BaseViewController.onAboutPressed(_:)), for: UIControl.Event.touchUpInside)
        
        LabasLocationManager.shared.delegate = self
        LabasLocationManager.shared.startUpdatingLocation()
        
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 138.0
        
        // Do any additional setup after loading the view.
    }
    
    func updateNotifications() {
        self.items.removeAll()
        ApiService.getAllNotifications(Authorization: self.loadUser().data?.accessToken ?? "") { (response) in
            self.items.removeAll()
            self.items.append(contentsOf: response.data ?? [DatumNot]())
            if (self.items.count > 0) {
                self.emptyView.isHidden = true
                self.tableView.delegate = self
                self.tableView.dataSource = self
                self.tableView.reloadData()
            }else {
                self.emptyView.isHidden = false
            }
      }
    }
    
    
    func labasLocationManager(didUpdateLocation location: CLLocation) {
        if (self.latitude ?? 0.0 == 0.0 || self.longitude ?? 0.0 == 0.0) {
            self.latitude = location.coordinate.latitude
            self.longitude = location.coordinate.longitude
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        ApiService.getAllNotifications(Authorization: self.loadUser().data?.accessToken ?? "") { (response) in
            self.items.removeAll()
            self.items.append(contentsOf: response.data ?? [DatumNot]())
            if (self.items.count > 0) {
              self.emptyView.isHidden = true
                self.tableView.delegate = self
                self.tableView.dataSource = self
                self.tableView.reloadData()
            }else {
              self.emptyView.isHidden = false
            }
            
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        let item = self.items[indexPath.row]
//        switch item.type {
//        case Constants.DELIVERY_CREATED:
//            return 138.0
//        case Constants.BID_CREATED:
//            return 138.0
//        default:
//            return 78.0
//        }
//    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = self.items[indexPath.row]
        switch item.type {
        case Constants.DELIVERY_CREATED:
            let cell : DriverOrderCell = tableView.dequeueReusableCell(withIdentifier: "driverordercell", for: indexPath) as! DriverOrderCell
            
            let dict = item.data?.convertToDictionary()
            
            let fromLatitude = dict?["FromLatitude"] as? Double ?? 0.0
            let fromLongitude = dict?["FromLongitude"] as? Double ?? 0.0
            let toLatitude = dict?["ToLatitude"] as? Double ?? 0.0
            let toLongitude = dict?["ToLongitude"] as? Double ?? 0.0
            let fromAddress = dict?["FromAddress"] as? String ?? ""
            let toAddress = dict?["ToAddress"] as? String ?? ""
            let desc = dict?["Description"] as? String ?? ""
            
            cell.lblTitle.text = desc
            cell.lblMoney.text = "\(dict?["EstimatedPrice"] as? Double ?? 0.0) \("currency".localized)"
            cell.lblTime.text = "\(dict?["Time"] as? Int ?? 0) \("hours".localized)"
            
            let driverLatLng = CLLocation(latitude: self.latitude ?? 0.0, longitude: self.longitude ?? 0.0)
            let dropOffLatLng = CLLocation(latitude: toLatitude, longitude: toLongitude)
            let distanceInMeters = dropOffLatLng.distance(from: driverLatLng)
            let distanceInKM = distanceInMeters / 1000.0
            let distanceStr = String(format: "%.2f", distanceInKM)
            
            cell.lblDistance.text = "\(distanceStr) \("km".localized)"
            
            cell.onTake = {
                if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TakeOrderVC") as? TakeOrderVC
                {
                    vc.deliveryId = item.deliveryID ?? 0
                    vc.latitude = self.latitude
                    vc.longitude = self.longitude
                    
                    vc.fromLatitude = fromLatitude
                    vc.fromLongitude = fromLongitude
                    vc.toLatitude = toLatitude
                    vc.toLongitude = toLongitude
                    vc.fromAddress = fromAddress
                    vc.toAddress = toAddress
                    vc.desc = desc
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
            
            return cell
        case Constants.DELIVERY_CANCELLED:
            let cell : RegularAlertCell = tableView.dequeueReusableCell(withIdentifier: "regularalertcell", for: indexPath) as! RegularAlertCell
            
            let dict = item.data?.convertToDictionary()
            
            let arabicTitle = dict?["ArabicTitle"] as? String ?? ""
            let englishTitle = dict?["EnglishTitle"] as? String ?? ""
            
            let arabicBody = dict?["ArabicBody"] as? String ?? ""
            let englishBody = dict?["EnglishBody"] as? String ?? ""
            
            if (self.isArabic()) {
                cell.lblTitle.text = arabicTitle
                cell.lblDescription.text = arabicBody
            }else {
                cell.lblTitle.text = englishTitle
                cell.lblDescription.text = englishBody
            }
            
            return cell
        case Constants.BID_CREATED:
            let cell : DriverBidCell = tableView.dequeueReusableCell(withIdentifier: "driverbidcell", for: indexPath) as! DriverBidCell
            
            let dict = item.data?.convertToDictionary()
            
            var desc = ""
            if (self.isArabic()) {
              desc = dict?["ArabicBody"] as? String ?? ""
            }else {
              desc = dict?["EnglishBody"] as? String ?? ""
            }
            let distance = dict?["Distance"] as? Double ?? 0.0
            
            cell.lblTitle.text = desc
            cell.lblMoney.text = "\(dict?["Price"] as? Double ?? 0.0) \("currency".localized)"
            cell.lblTime.text = "\(dict?["Time"] as? Int ?? 0) \("hours".localized)"
            
            let distanceStr = String(format: "%.2f", (distance / 1000.0))
            
            cell.lblDistance.text = "\(distanceStr) \("km".localized)"
            
            cell.onCheck = {
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AcceptBidDialog") as! AcceptBidDialog
                self.definesPresentationContext = true
                vc.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
                vc.view.backgroundColor = UIColor.clear
              let notificationId = dict?["Id"] as? Int ?? 0
                vc.item = item
                vc.notificationId = notificationId
                
                self.present(vc, animated: true, completion: nil)
            }
            
            return cell
        case Constants.ON_THE_WAY:
            let cell : RegularAlertCell = tableView.dequeueReusableCell(withIdentifier: "regularalertcell", for: indexPath) as! RegularAlertCell
            
            let dict = item.data?.convertToDictionary()
            
            let arabicTitle = dict?["ArabicTitle"] as? String ?? ""
            let englishTitle = dict?["EnglishTitle"] as? String ?? ""
            
            let arabicBody = dict?["ArabicBody"] as? String ?? ""
            let englishBody = dict?["EnglishBody"] as? String ?? ""
            
            if (self.isArabic()) {
                cell.lblTitle.text = arabicTitle
                cell.lblDescription.text = arabicBody
            }else {
                cell.lblTitle.text = englishTitle
                cell.lblDescription.text = englishBody
            }
            
            return cell
        case Constants.DELIVERY_COMPLETED:
            let cell : RegularAlertCell = tableView.dequeueReusableCell(withIdentifier: "regularalertcell", for: indexPath) as! RegularAlertCell
            
            let dict = item.data?.convertToDictionary()
            
            let arabicTitle = dict?["ArabicTitle"] as? String ?? ""
            let englishTitle = dict?["EnglishTitle"] as? String ?? ""
            
            let arabicBody = dict?["ArabicBody"] as? String ?? ""
            let englishBody = dict?["EnglishBody"] as? String ?? ""
            
            if (self.isArabic()) {
                cell.lblTitle.text = arabicTitle
                cell.lblDescription.text = arabicBody
            }else {
                cell.lblTitle.text = englishTitle
                cell.lblDescription.text = englishBody
            }
            
            return cell
        case Constants.BID_ACCEPTED:
            let cell : RegularAlertCell = tableView.dequeueReusableCell(withIdentifier: "regularalertcell", for: indexPath) as! RegularAlertCell
            
            let dict = item.data?.convertToDictionary()
            
            let arabicTitle = dict?["ArabicTitle"] as? String ?? ""
            let englishTitle = dict?["EnglishTitle"] as? String ?? ""
            
            let arabicBody = dict?["ArabicBody"] as? String ?? ""
            let englishBody = dict?["EnglishBody"] as? String ?? ""
            
            if (self.isArabic()) {
                cell.lblTitle.text = arabicTitle
                cell.lblDescription.text = arabicBody
            }else {
                cell.lblTitle.text = englishTitle
                cell.lblDescription.text = englishBody
            }
            
            return cell
        default:
            let cell : RegularAlertCell = tableView.dequeueReusableCell(withIdentifier: "regularalertcell", for: indexPath) as! RegularAlertCell
            
            let dict = item.data?.convertToDictionary()
            
            let arabicTitle = dict?["ArabicTitle"] as? String ?? ""
            let englishTitle = dict?["EnglishTitle"] as? String ?? ""
            
            let arabicBody = dict?["ArabicBody"] as? String ?? ""
            let englishBody = dict?["EnglishBody"] as? String ?? ""
            
            if (self.isArabic()) {
                cell.lblTitle.text = arabicTitle
                cell.lblDescription.text = arabicBody
            }else {
                cell.lblTitle.text = englishTitle
                cell.lblDescription.text = englishBody
            }
            
            return cell
        }
        
    }
    
    
    
    
    
}
