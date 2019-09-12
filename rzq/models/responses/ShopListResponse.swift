//
//  ShopListResponse.swift
//  rzq
//
//  Created by Zaid najjar on 4/13/19.
//  Copyright © 2019 technzone. All rights reserved.
//

import Foundation

class ShopListResponse: Codable {
    let dataShops: [DataShop]?
    let errorCode: Int?
    let errorMessage: String?
    
    enum CodingKeys: String, CodingKey {
        case dataShops = "Data"
        case errorCode = "ErrorCode"
        case errorMessage = "ErrorMessage"
    }
    
    init(dataShops: [DataShop]?, errorCode: Int?, errorMessage: String?) {
        self.dataShops = dataShops
        self.errorCode = errorCode
        self.errorMessage = errorMessage
    }
}

class DataShop: Codable {
    let id: Int?
    let name, address: String?
    let latitude, longitude: Double?
    let phoneNumber, workingHours: String?
    let images : [String]?
    let rate: Double?
    let type: TypeClass?
    var placeId : String?
    var ownerId : String?
    var googlePlaceId : String?
    var openNow : Bool?
    
    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case name = "Name"
        case address = "Address"
        case latitude = "Latitude"
        case longitude = "Longitude"
        case phoneNumber = "PhoneNumber"
        case workingHours = "WorkingHours"
        case images = "Images"
        case rate = "Rate"
        case type = "Type"
        case ownerId = "OwnerId"
        case googlePlaceId = "GooglePlaceId"
        case openNow = "OpenNow"
    }
    
    init(id: Int?, name: String?, address: String?, latitude: Double?, longitude: Double?, phoneNumber: String?, workingHours: String?, images: [String]?, rate: Double?, type: TypeClass?, ownerId : String?, googlePlaceId : String?, openNow : Bool?) {
        self.id = id
        self.name = name
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
        self.phoneNumber = phoneNumber
        self.workingHours = workingHours
        self.images = images
        self.rate = rate
        self.type = type
        self.ownerId = ownerId
        self.googlePlaceId = googlePlaceId
        self.openNow = openNow
    }
}
