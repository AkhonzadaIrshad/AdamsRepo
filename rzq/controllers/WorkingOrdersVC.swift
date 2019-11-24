//
//  WorkingOrdersVC.swift
//  rzq
//
//  Created by Zaid najjar on 4/17/19.
//  Copyright © 2019 technzone. All rights reserved.
//

import UIKit

class WorkingOrdersVC: BaseViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var btnMenu: UIButton!
    
    @IBOutlet weak var btnAbout: UIButton!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var emptyView: EmptyView!
    
    var pendingItems = [DatumDriverDel]()
    var historyItems = [DatumDelObj]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

           self.btnMenu.addTarget(self, action: #selector(BaseViewController.onSlideMenuButtonPressed(_:)), for: UIControl.Event.touchUpInside)
        
         self.btnAbout.addTarget(self, action: #selector(BaseViewController.onAboutPressed(_:)), for: UIControl.Event.touchUpInside)
        
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 200.0
        
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
    
   
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        ApiService.getDriverOnGoingDeliveries(Authorization: self.loadUser().data?.accessToken ?? "") { (response) in
            self.pendingItems.removeAll()
            self.pendingItems.append(contentsOf: response.data ?? [DatumDriverDel]())
            self.tableView.delegate = self
            self.tableView.dataSource = self
            self.tableView.reloadData()
            self.validateEmptyView()
        }
        ApiService.getDriverPreviousDeliveries(Authorization: self.loadUser().data?.accessToken ?? "") { (response) in
            self.historyItems.removeAll()
            self.historyItems.append(contentsOf: response.data?.data ?? [DatumDelObj]())
            self.tableView.delegate = self
            self.tableView.dataSource = self
            self.tableView.reloadData()
            self.validateEmptyView()
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
            
            cell.lblTitle.text = item.title ?? ""
            cell.lblOrderNumber.text = "\("order_number".localized) \(Constants.ORDER_NUMBER_PREFIX)\(item.id ?? 0)"
            cell.lblDeliveryDate.text = "\("delivery_date".localized) \(item.createdDate ?? "")"
            cell.lblFrom.text = "\("from".localized) \(item.fromAddress ?? "")"
            cell.lblTo.text = "\("to".localized) \(item.toAddress ?? "")"
            cell.lblOrderStatus.text = item.statusString ?? ""
            
            if (item.status == Constants.ORDER_PROCESSING || item.status == Constants.ORDER_ON_THE_WAY) {
                cell.viewChat.isHidden = false
            }else {
                cell.viewChat.isHidden = true
            }
            if (item.status == Constants.ORDER_ON_THE_WAY) {
                cell.viewTrack.isHidden = true
            }else {
                cell.viewTrack.isHidden = true
            }
            
            cell.onTrack = {
              
            }
            
            cell.onChat = {
                 DispatchQueue.main.async {
                let messagesVC: ZHCDemoMessagesViewController = ZHCDemoMessagesViewController.init()
                messagesVC.presentBool = true
                    
                    let dumOrder = DatumDel(id: item.id ?? 0, title: item.title ?? "", status: item.status ?? 0, statusString: item.statusString ?? "", image: item.image ?? "", createdDate: item.createdDate ?? "", chatId: item.chatId ?? 0, fromAddress: item.fromAddress ?? "", fromLatitude: item.fromLatitude ?? 0.0, fromLongitude: item.fromLongitude ?? 0.0, toAddress: item.toAddress ?? "", toLatitude: item.toLatitude ?? 0.0, toLongitude: item.toLongitude ?? 0.0, providerID: item.providerID ?? "", providerName: item.providerName ?? "", providerImage: item.providerImage ?? "", providerRate: item.providerRate ?? 0.0, time: item.time ?? 0, price: item.price ?? 0.0, serviceName: item.serviceName ?? "",paymentMethod: item.paymentMethod ?? 0, items: item.items ?? [ShopMenuItem](), isPaid: item.isPaid ?? false, invoiceId: item.invoiceId ?? "", toFemaleOnly: item.toFemaleOnly ?? false, shopId: item.shopId ?? 0, OrderPrice: item.OrderPrice ?? 0.0, KnetCommission: item.KnetCommission ?? 0.0)
                
                messagesVC.order = dumOrder
                messagesVC.user = self.loadUser()
                let nav: UINavigationController = UINavigationController.init(rootViewController: messagesVC)
                    nav.modalPresentationStyle = .fullScreen
                    messagesVC.modalPresentationStyle = .fullScreen
                self.navigationController?.present(nav, animated: true, completion: nil)
                }
            }
            
            cell.lblOrderStatus.textColor = self.getStatusColor(status: item.status ?? Constants.ORDER_PENDING)
            cell.statusColorView.backgroundColor = self.getStatusColor(status: item.status ?? Constants.ORDER_PENDING)
            
            return cell
        }else {
            let item = self.historyItems[indexPath.row]
            let cell : OrderCell = tableView.dequeueReusableCell(withIdentifier: "ordercell", for: indexPath) as! OrderCell
            
            if (item.image?.count ?? 0 > 0) {
                let url = URL(string: "\(Constants.IMAGE_URL)\(item.image ?? "")")
                cell.ivLogo.kf.setImage(with: url)
            }
            
            cell.lblTitle.text = item.title ?? ""
            cell.lblOrderNumber.text = "\("order_number".localized) \(Constants.ORDER_NUMBER_PREFIX)\(item.id ?? 0)"
            cell.lblDeliveryDate.text = "\("delivery_date".localized) \(item.createdDate ?? "")"
            cell.lblFrom.text = "\("from".localized) \(item.fromAddress ?? "")"
            cell.lblTo.text = "\("to".localized) \(item.toAddress ?? "")"
            cell.lblOrderStatus.text = item.statusString ?? ""
            
            cell.viewTrack.isHidden = true
            cell.viewChat.isHidden = true
            
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


}
