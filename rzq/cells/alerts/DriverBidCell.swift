//
//  DriverBidCell.swift
//  rzq
//
//  Created by Zaid najjar on 4/3/19.
//  Copyright © 2019 technzone. All rights reserved.
//

import UIKit

class DriverBidCell: UITableViewCell {

   
    @IBOutlet weak var ivLogo: UIImageView!
    
    @IBOutlet weak var lblTitle: MyUILabel!
    
    @IBOutlet weak var lblMoney: MyUILabel!
    
    @IBOutlet weak var lblTime: MyUILabel!
    
    @IBOutlet weak var lblDistance: MyUILabel!
    
    @IBOutlet weak var lblNotificationDate: MyUILabel!
    @IBOutlet weak var lblNotificationTime: MyUILabel!
    
    @IBOutlet weak var timeView: UIView!
    @IBOutlet weak var counterLbl: UILabel!
    
    @IBOutlet weak var btnCheckBid: MyUIButton!
    
    var onCheck : (() -> Void)? = nil
    var count = 120
    
    @IBAction func checkOfferAction(_ sender: Any) {
        if let onCheck = self.onCheck {
            onCheck()
        }
    }
    
    func startCountDown(startedFrom: String?) {
        _ = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
        if let startedTime = startedFrom {
            initCounter(startedFrom: startedTime)
        } else {
            self.count = 0
        }
        
    }
    
    @objc func update() {
        let (minutes, seconds) = secondsToHoursMinutesSeconds(seconds: self.count)
        if(count > 0) {
            count = count - 1
            counterLbl.text = String(minutes) + " mins " + String(seconds) + " sec"
        } else {
            counterLbl.text = ""
            self.btnCheckBid.isUserInteractionEnabled = false
            self.btnCheckBid.backgroundColor = .lightGray
        }
    }
    
    func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int) {
      return (seconds / 60, (seconds % 60))
    }
    
    func initCounter(startedFrom: String) {
        
        let inFormatter = DateFormatter()
        inFormatter.locale = .current
        inFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"

        let outFormatter = DateFormatter()
        outFormatter.locale = .current
        outFormatter.dateFormat = "hh:mm:ss"

        let bidDate = inFormatter.date(from: startedFrom) ?? Date()
        let nowDate = Date()
        let intervalInMin = (nowDate.timeIntervalSince(bidDate) / 60)
        if intervalInMin > 5 {
            self.count = 0
        } else {
            self.count = 300 - Int(nowDate.timeIntervalSince(bidDate))
        }
    }
}

