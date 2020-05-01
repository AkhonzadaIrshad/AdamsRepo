//
//  TNDRModel.swift
//  rzq
//
//  Created by Zaid najjar on 5/26/19.
//  Copyright © 2019 technzone. All rights reserved.
//

import Foundation

class TNDROrder : NSObject {
    var dropOffLongitude : Double?
    var dropOffLatitude : Double?
    var dropOffAddress : String?
    var dropOffDetails : String?
    var orderDetails : String?
    var orderCost : String?
    var time : Int?
    var service : ServiceData?
}
