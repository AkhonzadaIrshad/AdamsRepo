//
//  DriverOnGoingOrdersResponse.swift
//  rzq
//
//  Created by Zaid najjar on 4/12/19.
//  Copyright © 2019 technzone. All rights reserved.
//

import Foundation

class DriverOnGoingOrdersResponse: Codable {
    let data: [DatumDriverDel]?
    let errorCode: Int?
    let errorMessage: String?
    
    enum CodingKeys: String, CodingKey {
        case data = "Data"
        case errorCode = "ErrorCode"
        case errorMessage = "ErrorMessage"
    }
    
    init(data: [DatumDriverDel]?, errorCode: Int?, errorMessage: String?) {
        self.data = data
        self.errorCode = errorCode
        self.errorMessage = errorMessage
    }
}

class DatumDriverDel: Codable {
    let id, time: Int?
    let title: String?
    let status: Int?
    let statusString, image, createdDate: String?
    let chatId: Int?
    let fromAddress: String?
    let fromLatitude, fromLongitude: Double?
    let toAddress: String?
    let toLatitude, toLongitude: Double?
    let providerID, providerName, providerImage: String?
    let providerRate, price: Double?
    let serviceName: String?
    var paymentMethod : Int?
    let items : [ShopMenuItem]?
    let isPaid : Bool?
    let invoiceId : String?
    let toFemaleOnly : Bool?
    let shopId : Int?
    let OrderPrice : Double?
    let KnetCommission: Double?
    let clientPhone: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case title = "Title"
        case status = "Status"
        case statusString = "StatusString"
        case image = "Image"
        case createdDate = "CreatedDate"
        case chatId = "ChatId"
        case fromAddress = "FromAddress"
        case fromLatitude = "FromLatitude"
        case fromLongitude = "FromLongitude"
        case toAddress = "ToAddress"
        case toLatitude = "ToLatitude"
        case toLongitude = "ToLongitude"
        case providerID = "ProviderId"
        case providerName = "ProviderName"
        case providerImage = "ProviderImage"
        case providerRate = "ProviderRate"
        case time = "Time"
        case price = "Price"
        case serviceName = "ServiceName"
        case paymentMethod = "PaymentMethod"
        case items = "Items"
        case isPaid = "IsPaid"
        case invoiceId = "InvoiceId"
        case toFemaleOnly = "ToFemaleOnly"
        case shopId = "ShopId"
        case OrderPrice = "OrderPrice"
        case KnetCommission = "KnetCommission"
        case clientPhone = "ClientPhone"
    }
    
    init(id: Int?, title: String?, status: Int?, statusString: String?, image: String?, createdDate: String?, chatId: Int?, fromAddress: String?, fromLatitude: Double?, fromLongitude: Double?, toAddress: String?, toLatitude: Double?, toLongitude: Double?, providerID: String?, providerName: String?, providerImage: String?, providerRate: Double?, time: Int?, price: Double?, serviceName: String?, paymentMethod: Int?, items: [ShopMenuItem]?, isPaid : Bool?, invoiceId: String?, toFemaleOnly: Bool?, shopId : Int?,OrderPrice: Double?, KnetCommission: Double?,clientPhone: String?) {
        self.id = id
        self.title = title
        self.status = status
        self.statusString = statusString
        self.image = image
        self.createdDate = createdDate
        self.chatId = chatId
        self.fromAddress = fromAddress
        self.fromLatitude = fromLatitude
        self.fromLongitude = fromLongitude
        self.toAddress = toAddress
        self.toLatitude = toLatitude
        self.toLongitude = toLongitude
        self.providerID = providerID
        self.providerName = providerName
        self.providerImage = providerImage
        self.providerRate = providerRate
        self.time = time
        self.price = price
        self.serviceName = serviceName
        self.paymentMethod = paymentMethod
        self.items = items
        self.isPaid = isPaid
        self.invoiceId = invoiceId
        self.toFemaleOnly = toFemaleOnly
        self.shopId = shopId
        self.OrderPrice = OrderPrice
        self.KnetCommission = KnetCommission
        self.clientPhone = clientPhone
    }
}
