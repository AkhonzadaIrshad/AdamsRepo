//
//  OnGoingDeliveriesResponse.swift
//  rzq
//
//  Created by Zaid najjar on 4/12/19.
//  Copyright © 2019 technzone. All rights reserved.
//

import Foundation

class OnGoingDeliveriesResponse: Codable {
    let data: [DatumDel]?
    let errorCode: Int?
    let errorMessage: String?
    
    enum CodingKeys: String, CodingKey {
        case data = "Data"
        case errorCode = "ErrorCode"
        case errorMessage = "ErrorMessage"
    }
    
    init(data: [DatumDel]?, errorCode: Int?, errorMessage: String?) {
        self.data = data
        self.errorCode = errorCode
        self.errorMessage = errorMessage
    }
}

class DatumDel: Codable {
    let driverID: String?
    let canReport, canTrack: Bool?
    let id: Int?
    let chatId : Int?
    let fromAddress, toAddress, title: String?
    let status, time: Int?
    let statusString, image, createdDate: String?
    let toLatitude, toLongitude, fromLatitude,price, fromLongitude: Double?
    let driverName, driverImage: String?
    let driverRate: Double?
    let canRate, canCancel, canChat: Bool?
    
    enum CodingKeys: String, CodingKey {
        case driverID = "DriverId"
        case canReport = "CanReport"
        case canTrack = "CanTrack"
        case id = "Id"
        case fromAddress = "FromAddress"
        case toAddress = "ToAddress"
        case title = "Title"
        case status = "Status"
        case price = "Price"
        case time = "Time"
        case statusString = "StatusString"
        case image = "Image"
        case createdDate = "CreatedDate"
        case toLatitude = "ToLatitude"
        case toLongitude = "ToLongitude"
        case fromLatitude = "FromLatitude"
        case fromLongitude = "FromLongitude"
        case driverName = "DriverName"
        case driverImage = "DriverImage"
        case driverRate = "DriverRate"
        case canRate = "CanRate"
        case canCancel = "CanCancel"
        case canChat = "CanChat"
        case chatId = "ChatId"
    }
    
    init(driverID: String?, canReport: Bool?, canTrack: Bool?, id: Int?, chatId : Int, fromAddress: String?, toAddress: String?, title: String?, status: Int?, price: Double?, time: Int?, statusString: String?, image: String?, createdDate: String?, toLatitude: Double?, toLongitude: Double?, fromLatitude: Double?, fromLongitude: Double?, driverName: String?, driverImage: String?, driverRate: Double?, canRate: Bool?, canCancel: Bool?, canChat: Bool?) {
        self.driverID = driverID
        self.canReport = canReport
        self.canTrack = canTrack
        self.id = id
        self.chatId = chatId
        self.fromAddress = fromAddress
        self.toAddress = toAddress
        self.title = title
        self.status = status
        self.price = price
        self.time = time
        self.statusString = statusString
        self.image = image
        self.createdDate = createdDate
        self.toLatitude = toLatitude
        self.toLongitude = toLongitude
        self.fromLatitude = fromLatitude
        self.fromLongitude = fromLongitude
        self.driverName = driverName
        self.driverImage = driverImage
        self.driverRate = driverRate
        self.canRate = canRate
        self.canCancel = canCancel
        self.canChat = canChat
    }
}
