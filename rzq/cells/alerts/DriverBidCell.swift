//
//  DriverBidCell.swift
//  rzq
//
//  Created by Zaid najjar on 4/3/19.
//  Copyright © 2019 technzone. All rights reserved.
//

import UIKit
import Cosmos
import CoreLocation
import MFSDK

class DriverBidCell: UITableViewCell {

    @IBOutlet weak var veriviedDriverImageView: UIImageView!
    @IBOutlet weak var bidCardView: CardView!
    @IBOutlet weak var bidContainerView: CardView!
    @IBOutlet weak var ivLogo: UIImageView!
    @IBOutlet weak var lblTitle: MyUILabel!
    @IBOutlet weak var lblMoney: MyUILabel!
    @IBOutlet weak var numberOfOrdersLabel: UILabel!
    @IBOutlet weak var lblTime: MyUILabel!
    @IBOutlet weak var userProfilImage: CircleImage!
    @IBOutlet weak var ViewReviews: MyUIButton!
    
    @IBOutlet weak var lblDistance: MyUILabel!
    @IBOutlet weak var lblNotificationDate: MyUILabel!
    @IBOutlet weak var lblNotificationTime: MyUILabel!
    
    @IBOutlet weak var timeView: UIView!
    @IBOutlet weak var counterLbl: UILabel!
    @IBOutlet weak var rateView: CosmosView!

    @IBOutlet weak var btnCheckBid: MyUIButton!
    @IBOutlet weak var vwDeclineBid: RoundedView!
    @IBOutlet weak var vwAcceptBid: RoundedView!
    
    @IBOutlet weak var vwCountDown: RoundedView!
    @IBOutlet weak var btnAcceptBid: UIButton!
    @IBOutlet weak var btnDeclineBid: UIButton!
    
    var onCheck : (() -> Void)? = nil
    var onDecline: (() -> Void)? = nil
    var onAccept: (() -> Void)? = nil
    var onViewReviews: (() -> Void)? = nil

    var count = 120
    var seconds = 1
    var secondTimer:Timer?
    var firstTime: Bool = false
    @IBAction func checkOfferAction(_ sender: Any) {
        if let onCheck = self.onCheck {
            onCheck()
        }
    }
    @IBAction func btnDeclineClicked(_ sender: Any) {
        self.onDecline?()
    }
    @IBAction func onViewReviews(_ sender: Any) {
        self.onViewReviews?()
    }
    
    @IBAction func btnAcceptClicked(_ sender: Any) {
        self.onAccept?()
    }
    // for setup of timer and variable
    func setTimer() {
        seconds = 1

        secondTimer?.invalidate()
        secondTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateUI), userInfo: nil, repeats: true)
    }

    //method to update your UI
    @objc func updateUI() {
        //update your UI here

        //also update your seconds variable value by 1
        seconds += 1
        if seconds == 25 {
            secondTimer?.invalidate()
            secondTimer = nil
            DispatchQueue.main.async {
                self.bidCardView.backgroundColor = .white
            }
        }
        print(seconds)
    }
    
    func startCountDown(startedFrom: String?) {
        if let startedTime = startedFrom {
            initCounter(startedFrom: startedTime)
        } else {
            self.count = 0
        }
        self.update()
        _ = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
        
    }
    
    @objc func update() {
        let (minutes, seconds) = secondsToHoursMinutesSeconds(seconds: self.count)
        if(count > 0) {
            count = count - 1
            counterLbl.text = String(minutes) + ":" + String(seconds)

        } else {
            self.vwCountDown.isHidden = true
            self.vwAcceptBid.isUserInteractionEnabled = false
            self.vwAcceptBid.backgroundColor = .lightGray
            self.vwDeclineBid.isUserInteractionEnabled = false
            self.vwDeclineBid.backgroundColor = .lightGray
        }
    }
    
    func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int) {
      return (seconds / 60, (seconds % 60))
    }
    
    func initCounter(startedFrom: String) {
        self.btnAcceptBid.setTitle("bidCell.Accept".localized, for: .normal)
        self.btnDeclineBid.setTitle("bidCell.Decline".localized, for: .normal)
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

