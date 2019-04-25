//
//  PreviousDeliveriesResponse.swift
//  rzq
//
//  Created by Zaid najjar on 4/12/19.
//  Copyright © 2019 technzone. All rights reserved.
//

import Foundation

class PreviousDeliveriesResponse: Codable {
    let data: DataClassDel?
    let errorCode: Int?
    let errorMessage: String?
    
    enum CodingKeys: String, CodingKey {
        case data = "Data"
        case errorCode = "ErrorCode"
        case errorMessage = "ErrorMessage"
    }
    
    init(data: DataClassDel?, errorCode: Int?, errorMessage: String?) {
        self.data = data
        self.errorCode = errorCode
        self.errorMessage = errorMessage
    }
}

class DataClassDel: Codable {
    let data: [Datum]?
    let totalRows: Int?
    
    enum CodingKeys: String, CodingKey {
        case data = "Data"
        case totalRows = "TotalRows"
    }
    
    init(data: [Datum]?, totalRows: Int?) {
        self.data = data
        self.totalRows = totalRows
    }
}

class Datum: Codable {
    let driverID: String?
    let canReport, canTrack: Bool?
    let id: Int?
    let fromAddress, toAddress, title: String?
    let status, time: Int?
    let statusString, image, createdDate: String?
    let toLatitude,price , toLongitude, fromLatitude, fromLongitude: Double?
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
        case canRate = "CanRate"
        case canCancel = "CanCancel"
        case canChat = "CanChat"
    }
    
    init(driverID: String?, canReport: Bool?, canTrack: Bool?, id: Int?, fromAddress: String?, toAddress: String?, title: String?, status: Int?, price: Double?, time: Int?, statusString: String?, image: String?, createdDate: String?, toLatitude: Double?, toLongitude: Double?, fromLatitude: Double?, fromLongitude: Double?, canRate: Bool?, canCancel: Bool?, canChat: Bool?) {
        self.driverID = driverID
        self.canReport = canReport
        self.canTrack = canTrack
        self.id = id
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
        self.canRate = canRate
        self.canCancel = canCancel
        self.canChat = canChat
    }
}
