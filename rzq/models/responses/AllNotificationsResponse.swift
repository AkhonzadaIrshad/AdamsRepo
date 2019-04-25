//
//  AllNotificationsResponse.swift
//  rzq
//
//  Created by Zaid najjar on 4/12/19.
//  Copyright © 2019 technzone. All rights reserved.
//

import Foundation

class AllNotificationsResponse: Codable {
    let data: [DatumNot]?
    let errorCode: Int?
    let errorMessage: String?
    
    enum CodingKeys: String, CodingKey {
        case data = "Data"
        case errorCode = "ErrorCode"
        case errorMessage = "ErrorMessage"
    }
    
    init(data: [DatumNot]?, errorCode: Int?, errorMessage: String?) {
        self.data = data
        self.errorCode = errorCode
        self.errorMessage = errorMessage
    }
}

class DatumNot: Codable {
    let type: Int?
    let createdDate, data, userID: String?
    let deliveryID, serviceID, tenderID: Int?
    
    enum CodingKeys: String, CodingKey {
        case type = "Type"
        case createdDate = "CreatedDate"
        case data = "Data"
        case userID = "UserId"
        case deliveryID = "DeliveryId"
        case serviceID = "ServiceId"
        case tenderID = "TenderId"
    }
    
    init(type: Int?, createdDate: String?, data: String?, userID: String?, deliveryID: Int?, serviceID: Int?, tenderID: Int?) {
        self.type = type
        self.createdDate = createdDate
        self.data = data
        self.userID = userID
        self.deliveryID = deliveryID
        self.serviceID = serviceID
        self.tenderID = tenderID
    }
}
