//
//  ShopDetailsResponse.swift
//  rzq
//
//  Created by Zaid najjar on 4/16/19.
//  Copyright © 2019 technzone. All rights reserved.
//

import Foundation

class ShopDetailsResponse: Codable {
    let shopData: ShopData?
    let errorCode: Int?
    let errorMessage: String?
    
    enum CodingKeys: String, CodingKey {
        case shopData = "Data"
        case errorCode = "ErrorCode"
        case errorMessage = "ErrorMessage"
    }
    
    init(shopData: ShopData?, errorCode: Int?, errorMessage: String?) {
        self.shopData = shopData
        self.errorCode = errorCode
        self.errorMessage = errorMessage
    }
}

class ShopData: Codable {
    let nearbyDriversCount, id: Int?
    let name, address: String?
    let latitude, longitude: Double?
    let phoneNumber, workingHours: String?
    let rate: Double?
    let images: [String]?
    let type: TypeClass?
    var placeId : String?
    var ownerId : String?
    
    enum CodingKeys: String, CodingKey {
        case nearbyDriversCount = "NearbyDriversCount"
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
    }
    
    init(nearbyDriversCount: Int?, id: Int?, name: String?, address: String?, latitude: Double?, longitude: Double?, phoneNumber: String?, workingHours: String?, images: [String]?, rate: Double?, type: TypeClass?, ownerId: String?) {
        self.nearbyDriversCount = nearbyDriversCount
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
    }
}

class TypeClass: Codable {
    let id: Int?
    let name, image: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case name = "Name"
        case image = "Image"
    }
    init(id: Int?, name: String?, image: String?) {
        self.id = id
        self.name = name
        self.image = image
    }
}
