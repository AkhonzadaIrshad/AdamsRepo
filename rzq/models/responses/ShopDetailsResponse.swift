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
    let latitude, longitude,rate: Double?
    let phoneNumber, workingHours: String?
    let isOpen: Bool?
    let type : Int?
    let image: String?
    
    enum CodingKeys: String, CodingKey {
        case rate = "Rate"
        case nearbyDriversCount = "NearbyDriversCount"
        case id = "Id"
        case type = "Type"
        case name = "Name"
        case address = "Address"
        case latitude = "Latitude"
        case longitude = "Longitude"
        case phoneNumber = "PhoneNumber"
        case workingHours = "WorkingHours"
        case isOpen = "IsOpen"
        case image = "Image"
    }
    
    init(rate: Double?, nearbyDriversCount: Int?, id: Int?, type : Int?, name: String?, address: String?, latitude: Double?, longitude: Double?, phoneNumber: String?, workingHours: String?, isOpen: Bool?, image: String?) {
        self.rate = rate
        self.nearbyDriversCount = nearbyDriversCount
        self.id = id
        self.type = type
        self.name = name
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
        self.phoneNumber = phoneNumber
        self.workingHours = workingHours
        self.isOpen = isOpen
        self.image = image
}
}
