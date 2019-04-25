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
    let id: Int?
    let chatId : Int?
    let title, fromAddress: String?
    let fromLatitude, fromLongitude: Double?
    let toAddress: String?
    let time : Int?
    let toLatitude, toLongitude, cost: Double?
    let status: Int?
    let canCancel, canChat: Bool?
    let statusString: String?
    let images: [String]?
    let createdDate: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case title = "Title"
        case fromAddress = "FromAddress"
        case fromLatitude = "FromLatitude"
        case fromLongitude = "FromLongitude"
        case toAddress = "ToAddress"
        case toLatitude = "ToLatitude"
        case toLongitude = "ToLongitude"
        case time = "Time"
        case cost = "Cost"
        case canCancel = "CanCancel"
        case canChat = "CanChat"
        case status = "Status"
        case statusString = "StatusString"
        case images = "Images"
        case createdDate = "CreatedDate"
        case chatId = "ChatId"
    }
    
    init(id: Int?, chatId : Int?, title: String?, fromAddress: String?, fromLatitude: Double?, fromLongitude: Double?, toAddress: String?, toLatitude: Double?, toLongitude: Double?, time: Int?, cost: Double?, status: Int?, canCancel: Bool?, canChat: Bool?, statusString: String?, images: [String]?, createdDate: String?) {
        self.id = id
        self.chatId = chatId
        self.title = title
        self.fromAddress = fromAddress
        self.fromLatitude = fromLatitude
        self.fromLongitude = fromLongitude
        self.toAddress = toAddress
        self.toLatitude = toLatitude
        self.toLongitude = toLongitude
        self.time = time
        self.cost = cost
        self.status = status
        self.canCancel = canCancel
        self.canChat = canChat
        self.statusString = statusString
        self.images = images
        self.createdDate = createdDate
    }
}
