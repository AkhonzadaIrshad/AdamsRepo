//
//  WorkingHoursVC.swift
//  rzq
//
//  Created by Zaid najjar on 4/28/19.
//  Copyright © 2019 technzone. All rights reserved.
//

import UIKit

class WorkingHoursVC: BaseVC, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    
    @IBOutlet weak var ivHandle: UIImageView!
    
    var items = [String]()
    
    var isGooglePlace : Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (self.isArabic()) {
            self.ivHandle.image = UIImage(named: "ic_back_arabic")
        }
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.reloadData()
        
    }
    
    
    //tableview delegates
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 71.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : WorkingHourCell = tableView.dequeueReusableCell(withIdentifier: "workinghourcell", for: indexPath) as! WorkingHourCell
        
        let item = self.items[indexPath.row]
        
        cell.lblDay.text = self.getDayText(index : indexPath.row)
        if (item.count > 5) {
            var fromTime12Format = ""
            var toTime12Format = ""
            
            let times = item.split(separator: "-")
            let fromTime = String(times[0]).trim()
            let toTime = String(times[1]).trim()
            
            let fromSplit = fromTime.split(separator: ":")
            let fromHour = String(fromSplit[0])
            let fromMin = String(fromSplit[1])
            
            let integerFromHour = Int(fromHour) ?? 0
            if (integerFromHour < 12) {
                fromTime12Format = "\(integerFromHour):\(fromMin) \("am".localized)"
            }else if (integerFromHour > 12){
                fromTime12Format = "\(integerFromHour - 12):\(fromMin) \("pm".localized)"
            }else {
                fromTime12Format = "12:\(fromMin) \("pm".localized)"
            }
            
            
            
            let toSplit = toTime.split(separator: ":")
            let toHour = String(toSplit[0])
            let toMin = String(toSplit[1])
            
            let integerToHour = Int(toHour) ?? 0
            if (integerToHour < 12) {
                toTime12Format = "\(integerToHour):\(toMin) \("am".localized)"
            }else if (integerToHour > 12){
                toTime12Format = "\(integerToHour - 12):\(toMin) \("pm".localized)"
            }else {
                toTime12Format = "12:\(toMin) \("pm".localized)"
            }
            
            cell.lblTime.text = "\(fromTime12Format) - \(toTime12Format)"
        }else {
            cell.lblTime.text = item
        }
        
        
        
        return cell
    }
    
    func getDayText(index : Int) -> String {
        if (self.isArabic()) {
            if (self.isGooglePlace ?? false) {
                switch index {
                case 0:
                    return "saturday".localized
                case 1:
                    return "sunday".localized
                case 2:
                    return "monday".localized
                case 3:
                    return "tuesday".localized
                case 4:
                    return "wednesday".localized
                case 5:
                    return "thursday".localized
                case 6:
                    return "friday".localized
                default:
                    return "saturday".localized
                }
            }else {
                switch index {
                case 0:
                    return "monday".localized
                case 1:
                    return "tuesday".localized
                case 2:
                    return "wednesday".localized
                case 3:
                    return "thursday".localized
                case 4:
                    return "friday".localized
                case 5:
                    return "saturday".localized
                case 6:
                    return "sunday".localized
                default:
                    return "monday".localized
                }
            }
            
        }else {
            switch index {
            case 0:
                return "monday".localized
            case 1:
                return "tuesday".localized
            case 2:
                return "wednesday".localized
            case 3:
                return "thursday".localized
            case 4:
                return "friday".localized
            case 5:
                return "saturday".localized
            case 6:
                return "sunday".localized
            default:
                return "monday".localized
            }
        }
        
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
