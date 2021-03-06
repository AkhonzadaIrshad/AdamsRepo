//
//  DeliveryResponse.swift
//  rzq
//
//  Created by Zaid najjar on 4/9/19.
//  Copyright © 2019 technzone. All rights reserved.
//

import Foundation

class DeliveryResponse: Codable {
    let data: DataClassDelObj?
    let errorCode: Int?
    let errorMessage: String?
    
    enum CodingKeys: String, CodingKey {
        case data = "Data"
        case errorCode = "ErrorCode"
        case errorMessage = "ErrorMessage"
    }
    
    init(data: DataClassDelObj?, errorCode: Int?, errorMessage: String?) {
        self.data = data
        self.errorCode = errorCode
        self.errorMessage = errorMessage
    }
}

class DataClassDelObj: Codable {
    let type : Int?
    let id: Int?
    let driverId : String?
    let chatId : Int?
    let title, fromAddress: String?
    let fromLatitude, fromLongitude: Double?
    let toAddress: String?
    let time : Int?
    let toLatitude, toLongitude, cost, orderPrice: Double?
    let status: Int?
    let canCancel, canChat: Bool?
    let statusString: String?
    let images: [String]?
    let voiceFile : String?
    let createdDate: String?
    let pickUpDetails : String?
    let dropOffDetails : String?
    let desc : String?
    var paymentMethod: Int?
    let items: [ShopMenuItem]?
    let isPaid : Bool?
    let invoiceId : String?
    let toFemaleOnly : Bool?
    let shopId : Int?
    let KnetCommission : Double?
    let ClientPhone : String?
    let ProviderPhone : String?
    let hasUnreadMessages: Bool?
    
    enum CodingKeys: String, CodingKey {
        case type = "Type"
        case pickUpDetails = "PickUpDetails"
        case dropOffDetails = "DropOffDetails"
        case id = "Id"
        case driverId = "ProviderId"
        case title = "Title"
        case fromAddress = "FromAddress"
        case fromLatitude = "FromLatitude"
        case fromLongitude = "FromLongitude"
        case toAddress = "ToAddress"
        case toLatitude = "ToLatitude"
        case toLongitude = "ToLongitude"
        case time = "Time"
        case cost = "Cost"
        case orderPrice = "OrderPrice"
        case canCancel = "CanCancel"
        case canChat = "CanChat"
        case status = "Status"
        case statusString = "StatusString"
        case images = "Images"
        case createdDate = "CreatedDate"
        case chatId = "ChatId"
        case voiceFile = "VoiceFile"
        case desc = "Description"
        case paymentMethod = "PaymentMethod"
        case items = "Items"
        case isPaid = "IsPaid"
        case invoiceId = "InvoiceId"
        case toFemaleOnly = "ToFemaleOnly"
        case shopId = "ShopId"
        case KnetCommission = "KnetCommission"
        case ClientPhone = "ClientPhone"
        case ProviderPhone = "ProviderPhone"
        case hasUnreadMessages = "hasUnreadMessages"
    }
    
    init(type :Int?, id: Int?,driverId : String?, chatId : Int?, title: String?, fromAddress: String?, fromLatitude: Double?, fromLongitude: Double?, toAddress: String?, toLatitude: Double?, toLongitude: Double?, time: Int?, cost: Double?, status: Int?, canCancel: Bool?, canChat: Bool?, statusString: String?, images: [String]?,voiceFile : String?, createdDate: String?, pickUpDetails: String?,dropOffDetails: String?,desc: String?, paymentMethod: Int?, items: [ShopMenuItem]?, isPaid : Bool?, invoiceId: String?, toFemaleOnly : Bool?, shopId : Int?, orderPrice: Double?, KnetCommission: Double?, ClientPhone : String?, ProviderPhone: String?, hasUnreadMessages: Bool) {
        self.type = type
        self.id = id
        self.driverId = driverId
        self.chatId = chatId
        self.title = title
        self.fromAddress = fromAddress
        self.fromLatitude = fromLatitude
        self.fromLongitude = fromLongitude
        self.toAddress = toAddress
        self.toLatitude = toLatitude
        self.toLongitude = toLongitude
        self.time = time
        self.voiceFile = voiceFile
        self.cost = cost
        self.status = status
        self.canCancel = canCancel
        self.canChat = canChat
        self.statusString = statusString
        self.images = images
        self.createdDate = createdDate
        self.pickUpDetails = pickUpDetails
        self.dropOffDetails = dropOffDetails
        self.desc = desc
        self.paymentMethod = paymentMethod
        self.items = items
        self.isPaid = isPaid
        self.invoiceId = invoiceId
        self.toFemaleOnly = toFemaleOnly
        self.shopId = shopId
        self.orderPrice = orderPrice
        self.KnetCommission = KnetCommission
        self.ClientPhone = ClientPhone
        self.ProviderPhone = ProviderPhone
        self.hasUnreadMessages = hasUnreadMessages
    }
    
}
