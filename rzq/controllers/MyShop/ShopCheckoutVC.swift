//
//  ShopCheckoutVC.swift
//  rzq
//
//  Created by Zaid Khaled on 10/21/19.
//  Copyright © 2019 technzone. All rights reserved.
//

import UIKit

protocol CheckOutDoneDelegate {
    func onDone(selectedItems : [ShopMenuItem])
}

class ShopCheckoutVC: BaseVC, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var lblItemsCount: MyUILabel!
    
    @IBOutlet weak var lblItemsPrice: MyUILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var ivHandle: UIImageView!
    
    var delegate : CheckOutDoneDelegate?
    
    var items = [ShopMenuItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.lblItemsCount.text = "0"
        self.lblItemsPrice.text = "0.00 \("currency".localized)"
        
        //        self.tableView.estimatedRowHeight = 108.0
        //        self.tableView.rowHeight = UITableView.automaticDimension
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.reloadData()
        
        self.calculateTotal()
        
        if (self.isArabic()) {
            self.ivHandle.image = UIImage(named: "ic_back_arabic")
        }
        // Do any additional setup after loading the view.
    }
    
    //tableview delegate
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 108.0
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ShopCheckoutCell = tableView.dequeueReusableCell(withIdentifier: "ShopCheckoutCell", for: indexPath as IndexPath) as! ShopCheckoutCell
        
        let item = self.items[indexPath.row]
        
        cell.lblTitle.text = item.name ?? ""
        cell.lblItemPrice.text = "\(item.price ?? 0.0) \("currency".localized)"
        cell.viewStepper.value = Double(item.quantity ?? 0)
        let doubleQuantity = Double(item.quantity ?? 0)
        let doublePrice = item.price ?? 0.0
        cell.lblTotalPrice.text = "\(doubleQuantity * doublePrice) \("currency".localized)"
        
        
        cell.valueChanged = {
            item.quantity = cell.selectedValue ?? 0
            self.calculateTotal()
        }
        
        cell.onDelete = {
            self.deleteItem(index: indexPath.row)
        }
        
        return cell
    }
    
    func deleteItem(index: Int) {
        self.showAlert(title: "alert".localized, message: "confirm_delete_menu_item".localized, actionTitle: "delete".localized, cancelTitle: "cancel".localized, actionHandler: {
            self.items.remove(at: index)
            self.tableView.reloadData()
            self.calculateTotal()
            if (self.items.count == 0) {
                self.navigationController?.popViewController(animated: true)
            }
        }, cancelHandler: {
            if let cell = self.tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? ShopCheckoutCell {
                cell.viewStepper.value = 1.0
                self.items[index].quantity = 1
                self.tableView.reloadData()
                // self.tableView.reloadData()
            }
        })
    }
    
    
    func calculateTotal() {
        var totalItems = 0
        var totalPrice = 0.0
        
        for item in self.items {
            totalItems = totalItems + (item.quantity ?? 0)
            let doubleQuantity = Double(item.quantity ?? 0)
            let itemPrice = doubleQuantity * (item.price ?? 0.0)
            totalPrice = totalPrice + itemPrice
        }
        
        
        UIView.transition(with: self.lblItemsCount,
                          duration: 0.25,
                          options: .transitionFlipFromBottom,
                          animations: { [weak self] in
                            self?.lblItemsCount.text = "\(totalItems)"
            }, completion: nil)
        
        let formattedTotalPrice = String(format: "%.2f", totalPrice)
        UIView.transition(with: self.lblItemsPrice,
                          duration: 0.25,
                          options: .transitionFlipFromBottom,
                          animations: { [weak self] in
                            self?.lblItemsPrice.text = "\(formattedTotalPrice) \("currency".localized)"
            }, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //go to delivery step 1
        
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func doneAction(_ sender: Any) {
        //actual code
        self.delegate?.onDone(selectedItems: self.items)
        self.navigationController?.popViewController(animated: true)
    }
    
    func getTotal() -> Double {
        var total = 0.0
        for item in self.items {
            let doubleQuantity = Double(item.quantity ?? 0)
            let doublePrice = item.price ?? 0.0
            total = total + (doubleQuantity * doublePrice)
        }
        return total
    }
    
    
    @IBAction func addMoreAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
        
    }
}
