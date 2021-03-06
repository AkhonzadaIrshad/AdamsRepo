//
//  OTWOrder.swift
//  rzq
//
//  Created by Zaid najjar on 4/4/19.
//  Copyright © 2019 technzone. All rights reserved.
//

import Foundation
class OTWOrder : NSObject {
    var pickUpLongitude : Double?
    var pickUpLatitude : Double?
    var dropOffLongitude : Double?
    var dropOffLatitude : Double?
    var pickUpAddress : String?
    var dropOffAddress : String?
    var pickUpDetails : String?
    var dropOffDetails : String?
    var orderDetails : String?
    var orderCost : String?
    var time : Int?
    var shop : DataShop?
    var fromReorder: Bool?
    var selectedItems : [ShopMenuItem]?
    var paymentMethod : Int?
    var isFemale : Bool?
                    
    
    var images : [String]?
    var voiceRecord: String?
    
    var selectedTotal: Double?
    var edtOrderDetailsText: String?
    
    
    func reset() {
        self.pickUpLongitude = nil
        self.pickUpLatitude = nil
        self.pickUpAddress = nil
        self.pickUpDetails = nil
        self.orderDetails = nil
        self.orderCost = nil
    }
    
}
