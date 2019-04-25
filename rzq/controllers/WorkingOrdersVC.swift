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
    
    var pendingItems = [DatumDriverDel]()
    var historyItems = [DatumDelObj]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

           self.btnMenu.addTarget(self, action: #selector(BaseViewController.onSlideMenuButtonPressed(_:)), for: UIControl.Event.touchUpInside)
        
         self.btnAbout.addTarget(self, action: #selector(BaseViewController.onAboutPressed(_:)), for: UIControl.Event.touchUpInside)
        
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 200.0
        
    }
    
    func showEmptyView(show : Bool) {
        self.containerView.subviews.forEach({ $0.removeFromSuperview() })
        if (show) {
            self.tableView.isHidden = true
            let emptyView: EmptyView = UIView.fromNib()
            emptyView.lblTitle.text = "no_orders".localized
            emptyView.lblDescription.text = "no_orders_desc".localized
            emptyView.ivEmpty.image = UIImage(named: "empty_orders")
            //  emptyView.frame = self.containerView.frame
            self.containerView.addSubview(emptyView)
            emptyView.bindFrameToSuperviewBounds()
        } else {
            self.tableView.isHidden = false
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
        }
        ApiService.getDriverPreviousDeliveries(Authorization: self.loadUser().data?.accessToken ?? "") { (response) in
            self.historyItems.removeAll()
            self.historyItems.append(contentsOf: response.data?.data ?? [DatumDelObj]())
            self.tableView.delegate = self
            self.tableView.dataSource = self
            self.tableView.reloadData()
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
                    let dumOrder = DatumDel(driverID: self.loadUser().data?.accessToken ?? "", canReport: false, canTrack: false, id: item.id ?? 0, chatId : item.chatId ?? 0, fromAddress: item.fromAddress ?? "", toAddress: item.toAddress ?? "", title: item.title ?? "", status: item.status ?? Constants.ORDER_PROCESSING, price: item.price ?? 0.0, time: item.time ?? 0, statusString: item.statusString ?? "", image: item.image ?? "", createdDate: item.createdDate ?? "", toLatitude: item.toLatitude ?? 0.0, toLongitude: item.toLongitude ?? 0.0, fromLatitude: item.fromLatitude ?? 0.0, fromLongitude: item.fromLongitude ?? 0.0, driverName: item.driverName ?? "", driverImage: item.driverImage ?? "", driverRate: item.driverRate ?? 0.0, canRate: false, canCancel: false, canChat: false)
                
                messagesVC.order = dumOrder
                messagesVC.user = self.loadUser()
                let nav: UINavigationController = UINavigationController.init(rootViewController: messagesVC)
                self.navigationController?.present(nav, animated: true, completion: nil)
                }
            }
            
            cell.lblOrderStatus.textColor = self.getStatusColor(status: item.status ?? Constants.ORDER_PENDING)
            cell.statusColorView.backgroundColor = self.getStatusColor(status: item.status ?? Constants.ORDER_PENDING)
            
            return cell
        }else {
            let item = self.historyItems[indexPath.row]
            let cell : OrderCell = tableView.dequeueReusableCell(withIdentifier: "ordercell", for: indexPath) as! OrderCell
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
        default:
            return UIColor.pending
        }
    }
    @IBAction func segmentAction(_ sender: Any) {
        self.tableView.reloadData()
    }


}
