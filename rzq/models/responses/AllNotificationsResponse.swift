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
    let id : Int?
    let type: Int?
    let createdDate, data, userID: String?
    let createdTime : String?
    let orderID: Int?
    let isVerified: Bool?
    
    enum CodingKeys: String, CodingKey {
        case type = "Type"
        case createdDate = "CreatedDate"
        case data = "Data"
        case userID = "UserId"
        case orderID = "OrderId"
        case id = "Id"
        case createdTime = "CreatedTime"
        case isVerified = "IsVerified"
    }
    
    init(id : Int?, type: Int?, createdDate: String?,createdTime : String?, data: String?, userID: String?, orderID: Int?, isVerified: Bool?) {
        self.id = id
        self.type = type
        self.createdDate = createdDate
        self.data = data
        self.userID = userID
        self.orderID = orderID
        self.createdTime = createdTime
        self.isVerified = isVerified
    }
}
