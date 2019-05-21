//
//  AddHoursVC.swift
//  rzq
//
//  Created by Zaid najjar on 5/15/19.
//  Copyright © 2019 technzone. All rights reserved.
//

import UIKit

protocol AddHoursDelegate {
    func chosenHours(str : String)
}
class AddHoursVC: BaseVC, UITableViewDelegate, UITableViewDataSource, HourCellDelegate {

    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var ivHandle: UIImageView!
    
    var items = [HourItem]()
    var delegate : AddHoursDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (self.isArabic()) {
            self.ivHandle.image = UIImage(named: "ic_back_arabic")
        }
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.items = Constants.getHours()
        self.tableView.reloadData()

        // Do any additional setup after loading the view.
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
         let item = self.items[indexPath.row]
        if (item.isExpanded ?? false) {
            return 151.0
        }
        return 41.0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
   
    func didSelectFrom(cell: UITableViewCell, str: String) {
        let indexPath = self.tableView.indexPath(for: cell)
        self.items[(indexPath?.row)!].from = str
        self.tableView.reloadData()
    }
    
    func didSelectTo(cell: UITableViewCell, str: String) {
        let indexPath = self.tableView.indexPath(for: cell)
        self.items[(indexPath?.row)!].to = str
        self.tableView.reloadData()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : HourCell = tableView.dequeueReusableCell(withIdentifier: "hourcell", for: indexPath) as! HourCell
        
        cell.delegate = self
        
        let item = self.items[indexPath.row]
        
        cell.lblName.text = item.name ?? ""
        if (item.isExpanded ?? false) {
          cell.lblStatus.text = "open".localized
        }else {
          cell.lblStatus.text = "closed".localized
        }
        
        cell.btnFrom.setTitle(item.from ?? "", for: .normal)
        
        cell.btnTo.setTitle(item.to ?? "", for: .normal)
        
        if (item.isExpanded ?? false) {
            cell.expandedViewHeight.constant = 100.0
        }else {
           cell.expandedViewHeight.constant = 0
        }
        
        cell.onFrom = {
            
        }
        
        cell.onTo = {
            
        }
        
        cell.onExpand = {
            item.isExpanded = cell.isExpanded
            self.tableView.reloadData()
        }
        
        cell.onAllDay = {
            item.from  = "01:00"
            item.to = "23:00"
            cell.btnFrom.setTitle("01:00", for: .normal)
            cell.btnTo.setTitle("23:00", for: .normal)
        }

        return cell
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func doneAction(_ sender: Any) {
        var str = ""
        for item in self.items {
            if (item.isExpanded ?? false) {
                str = "\(str), \(item.from ?? "") - \(item.to ?? "")"
            }else {
                str = "\(str), \("--- ")"
            }
        }
        str.remove(at: str.startIndex)
        self.delegate?.chosenHours(str: str)
        self.navigationController?.popViewController(animated: true)
    }
    
}
