//
//  OrdersVC.swift
//  rzq
//
//  Created by Zaid najjar on 4/3/19.
//  Copyright © 2019 technzone. All rights reserved.
//

import UIKit

class OrdersVC: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var navBar: NavBar!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var btnMenu: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var btnAbout: UIButton!
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var emptyView: EmptyView!
    
    var pendingItems = [DatumDel]()
    var historyItems = [Datum]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        let titleTextAttributes2 = [NSAttributedString.Key.foregroundColor: UIColor.black]
        navBar.delegate = self
        
        self.segmentControl.setTitleTextAttributes(titleTextAttributes2, for: .normal)
        self.segmentControl.setTitleTextAttributes(titleTextAttributes, for: .selected)
        
        self.btnMenu.addTarget(self, action: #selector(BaseViewController.onSlideMenuButtonPressed(_:)), for: UIControl.Event.touchUpInside)
        
        self.btnAbout.addTarget(self, action: #selector(BaseViewController.onAboutPressed(_:)), for: UIControl.Event.touchUpInside)
        
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 200.0
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        ApiService.getOnGoingDeliveries(Authorization: DataManager.loadUser().data?.accessToken ?? "") { (response) in
            self.pendingItems.removeAll()
            self.pendingItems.append(contentsOf: response.data ?? [DatumDel]())
            self.tableView.delegate = self
            self.tableView.dataSource = self
            self.tableView.reloadData()
            self.validateEmptyView()
        }
        
        ApiService.getPreviousDeliveries(Authorization: DataManager.loadUser().data?.accessToken ?? "", pageSize: 100, pageNumber: 1) { (response) in
            self.historyItems.removeAll()
            self.historyItems.append(contentsOf: response.data?.data ?? [Datum]())
            self.tableView.delegate = self
            self.tableView.dataSource = self
            self.tableView.reloadData()
            self.validateEmptyView()
        }
        
    }
    
    func validateEmptyView() {
        if (segmentControl.selectedSegmentIndex == 0) {
            if (self.pendingItems.count > 0) {
                self.emptyView.isHidden = true
            }else {
                self.emptyView.isHidden = false
            }
        }else {
            if (self.historyItems.count > 0) {
                self.emptyView.isHidden = true
            }else {
                self.emptyView.isHidden = false
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.segmentControl.selectedSegmentIndex == 0) {
            return self.pendingItems.count
        }else {
            return self.historyItems.count
        }
    }
    
    //    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    //        return 200.0
    //    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "OrderDetailsVC") as? OrderDetailsVC
        {
            self.showLoading()
            if (self.segmentControl.selectedSegmentIndex == 0) {
                ApiService.getDelivery(id: self.pendingItems[indexPath.row].id ?? 0) { (response) in
                    self.hideLoading()
                    vc.order = response.data
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }else {
                ApiService.getDelivery(id: self.historyItems[indexPath.row].id ?? 0) { (response) in
                    self.hideLoading()
                    vc.order = response.data
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (self.segmentControl.selectedSegmentIndex == 0) {
            let item = self.pendingItems[indexPath.row]
            let cell : OrderCell = tableView.dequeueReusableCell(withIdentifier: "ordercell", for: indexPath) as! OrderCell
            
            if (item.image?.count ?? 0 > 0) {
                let url = URL(string: "\(Constants.IMAGE_URL)\(item.image ?? "")")
                cell.ivLogo.kf.setImage(with: url)
            }
            
            if item.hasUnreadMessages ?? false {
                cell.messagedReadImageView.isHidden = false
                cell.messagedReadImageView.tintColor = #colorLiteral(red: 0, green: 0.5628422499, blue: 0.3188166618, alpha: 1)
            } else {
               // cell.messagedReadImageView.isHidden = true
            }
            
            cell.lblTitle.text = item.title ?? ""
            cell.lblOrderNumber.text = "\("order_number".localized) \(Constants.ORDER_NUMBER_PREFIX)\(item.id ?? 0)"
            cell.lblDeliveryDate.text = "\("delivery_date".localized) \(self.convertDate(isoDate: item.createdDate ?? ""))"
            cell.lblFrom.text = "\("from".localized) \(item.fromAddress ?? "")"
            cell.lblTo.text = "\("to".localized) \(item.toAddress ?? "")"
            cell.lblOrderStatus.text = item.statusString ?? ""
            
            cell.lblOrderStatus.textColor = self.getStatusColor(status: item.status ?? Constants.ORDER_PENDING)
            cell.statusColorView.backgroundColor = self.getStatusColor(status: item.status ?? Constants.ORDER_PENDING)
            
            if (item.status == Constants.ORDER_PROCESSING || item.status == Constants.ORDER_ON_THE_WAY) {
                cell.viewChat.isHidden = false
            }else {
                cell.viewChat.isHidden = true
            }
            
            cell.btnReorder.isHidden = true
            
            if (item.status == Constants.ORDER_ON_THE_WAY) {
                cell.viewTrack.isHidden = false
            }else {
                cell.viewTrack.isHidden = true
            }
            
            cell.onTrack = {
                self.openViewControllerBasedOnIdentifier("HomeMapVC")
            }
            
            cell.onChat = {
                DispatchQueue.main.async {
                    let messagesVC: ZHCDemoMessagesViewController = ZHCDemoMessagesViewController.init()
                    messagesVC.presentBool = true
                    messagesVC.order = item
                    messagesVC.user = DataManager.loadUser()
                    let nav: UINavigationController = UINavigationController.init(rootViewController: messagesVC)
                    nav.modalPresentationStyle = .fullScreen
                    messagesVC.modalPresentationStyle = .fullScreen
                    self.navigationController?.present(nav, animated: true, completion: nil)
                }
            }
            
            return cell
        }else {
            let item = self.historyItems[indexPath.row]
            let cell : OrderCell = tableView.dequeueReusableCell(withIdentifier: "ordercell", for: indexPath) as! OrderCell
            
            if (item.image?.count ?? 0 > 0) {
                let url = URL(string: "\(Constants.IMAGE_URL)\(item.image ?? "")")
                cell.ivLogo.kf.setImage(with: url)
            }
            
            cell.messagedReadImageView.isHidden = true
            cell.lblTitle.text = item.title ?? ""
            cell.lblOrderNumber.text = "\("order_number".localized) \(Constants.ORDER_NUMBER_PREFIX)\(item.id ?? 0)"
            cell.lblDeliveryDate.text = "\("delivery_date".localized) \(self.convertDate(isoDate: item.createdDate ?? ""))"
            cell.lblFrom.text = "\("from".localized) \(item.fromAddress ?? "")"
            cell.lblTo.text = "\("to".localized) \(item.toAddress ?? "")"
            cell.lblOrderStatus.text = item.statusString ?? ""
            
            cell.viewTrack.isHidden = true
            cell.viewChat.isHidden = true
            
            cell.btnReorder.isHidden = false
            cell.onReorder = {
                self.reorderAction(orderId: item.id ?? 0)
            }
            
            cell.lblOrderStatus.textColor = self.getStatusColor(status: item.status ?? Constants.ORDER_PENDING)
            cell.statusColorView.backgroundColor = self.getStatusColor(status: item.status ?? Constants.ORDER_PENDING)
            
            return cell
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
        case Constants.ORDER_EXPIRED:
            return UIColor.expired
        default:
            return UIColor.pending
        }
    }
    
    @IBAction func segmentAction(_ sender: Any) {
        self.tableView.reloadData()
        self.validateEmptyView()
    }
    
    
    func reorderAction(orderId : Int) {
        self.showLoading()
        ApiService.getShopDetails(Authorization: DataManager.loadUser().data?.accessToken ?? "", id: orderId) { (response) in
            
            ApiService.getDelivery(id: orderId) { (order) in
                self.hideLoading()
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc1 : DeliveryStep1 = storyboard.instantiateViewController(withIdentifier: "DeliveryStep1") as! DeliveryStep1
                let vc2 : DeliveryStep2 = storyboard.instantiateViewController(withIdentifier: "DeliveryStep2") as! DeliveryStep2
                let vc3 : DeliveryStep3 = storyboard.instantiateViewController(withIdentifier: "DeliveryStep3") as! DeliveryStep3
                let model = OTWOrder()
                model.pickUpDetails = order.data?.pickUpDetails ?? ""
                model.pickUpAddress = order.data?.fromAddress ?? ""
                model.pickUpLatitude = order.data?.fromLatitude ?? 0.0
                model.pickUpLongitude = order.data?.fromLongitude ?? 0.0
                
                model.dropOffDetails = order.data?.dropOffDetails ?? ""
                model.dropOffAddress = order.data?.toAddress ?? ""
                model.dropOffLatitude = order.data?.toLatitude ?? 0.0
                model.dropOffLongitude = order.data?.toLongitude ?? 0.0
                
                model.images = order.data?.images ?? [String]()
                model.voiceRecord = order.data?.voiceFile ?? ""
                
                model.orderCost = String(order.data?.cost ?? 0.0)
                model.orderDetails = order.data?.desc ?? ""
                model.time = order.data?.time ?? 0
                model.fromReorder = true
                model.selectedItems = order.data?.items ?? [ShopMenuItem]()
                model.paymentMethod = order.data?.paymentMethod ?? Constants.PAYMENT_METHOD_CASH
                model.isFemale = order.data?.toFemaleOnly ?? false
                
                let shop = DataShop(id: response.shopData?.id ?? 0, name: response.shopData?.name ?? "", address: response.shopData?.address ?? "", latitude: response.shopData?.latitude ?? 0.0, longitude: response.shopData?.longitude ?? 0.0, phoneNumber: response.shopData?.phoneNumber ?? "", workingHours: response.shopData?.workingHours ?? "", images: response.shopData?.images ?? [String](), rate: response.shopData?.rate ?? 0.0, type: response.shopData?.type!, ownerId: response.shopData?.ownerId ?? "", googlePlaceId: response.shopData?.googlePlaceId ?? "", openNow: response.shopData?.openNow ?? true, NearbyDriversCount : response.shopData?.nearbyDriversCount ?? 0, hasOwner: response.shopData?.hasOwner ?? true)
                
                model.shop = shop
                
                vc1.orderModel = OTWOrder()
                vc2.orderModel = OTWOrder()
                vc3.orderModel = OTWOrder()
                
                vc1.orderModel = model
                vc2.orderModel = model
                vc3.orderModel = model
                                
                vc2.latitude = order.data?.fromLatitude ?? 0.0
                vc2.longitude = order.data?.fromLongitude ?? 0.0
                
                //  self.navigationController?.pushViewController(vc, animated: true)
                
                var controllers = self.navigationController?.viewControllers
                controllers?.append(vc1)
                controllers?.append(vc2)
                controllers?.append(vc3)
                self.navigationController?.setViewControllers(controllers!, animated: true)
                
                
                
            }
        }
    }
    
}

// MARK: - NavBarDelegate

extension OrdersVC: NavBarDelegate {
    func goToHomeScreen() {
        self.slideMenuItemSelectedAtIndex(1)
    }
    
    func goToOrdersScreen() {
        if DataManager.loadUser().data?.roles?.contains(find: "Driver") ?? false {
            self.slideMenuItemSelectedAtIndex(99)
        } else {
            self.slideMenuItemSelectedAtIndex(2)
        }
    }
    
    func goToNotificationsScreen() {
        self.slideMenuItemSelectedAtIndex(3)
    }
    
    func goToProfileScreen() {
        self.slideMenuItemSelectedAtIndex(12)
    }
}
