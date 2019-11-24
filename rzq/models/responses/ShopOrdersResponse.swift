//
//  ShopOrdersResponse.swift
//  rzq
//
//  Created by Zaid Khaled on 11/1/19.
//  Copyright © 2019 technzone. All rights reserved.
//

import Foundation

// MARK: - ShopOrdersResponse
class ShopOrdersResponse: Codable {
    let shopOrderData: ShopOrderData?
    let errorCode: Int?
    let errorMessage: String?

    enum CodingKeys: String, CodingKey {
        case shopOrderData = "Data"
        case errorCode = "ErrorCode"
        case errorMessage = "ErrorMessage"
    }

    init(shopOrderData: ShopOrderData?, errorCode: Int?, errorMessage: String?) {
        self.shopOrderData = shopOrderData
        self.errorCode = errorCode
        self.errorMessage = errorMessage
    }
}

// MARK: - ShopOrderData
class ShopOrderData: Codable {
    let shopOrdersData: [ShopOrdersDatum]?
    let totalRows: Int?

    enum CodingKeys: String, CodingKey {
        case shopOrdersData = "Data"
        case totalRows = "TotalRows"
    }

    init(shopOrdersData: [ShopOrdersDatum]?, totalRows: Int?) {
        self.shopOrdersData = shopOrdersData
        self.totalRows = totalRows
    }
}

// MARK: - ShopOrdersDatum
class ShopOrdersDatum: Codable {
    let id: Int?
    let createdDate, image, createdTime: String?
    let status: Int?
    let statusString, shopOrdersDatumDescription: String?
    let time: Int?
    let items: [ShopMenuItem]?
    let paymentMethod : Int?

    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case createdDate = "CreatedDate"
        case image = "Image"
        case status = "Status"
        case statusString = "StatusString"
        case shopOrdersDatumDescription = "Description"
        case time = "Time"
        case items = "Items"
        case paymentMethod = "PaymentMethod"
        case createdTime = "CreatedTime"
    }

    init(id: Int?, createdDate: String?, image: String?, status: Int?, statusString: String?, shopOrdersDatumDescription: String?, time: Int?, items: [ShopMenuItem]?, paymentMethod : Int?, createdTime: String?) {
        self.id = id
        self.createdDate = createdDate
        self.image = image
        self.status = status
        self.statusString = statusString
        self.shopOrdersDatumDescription = shopOrdersDatumDescription
        self.time = time
        self.items = items
        self.paymentMethod = paymentMethod
        self.createdTime = createdTime
    }
}


