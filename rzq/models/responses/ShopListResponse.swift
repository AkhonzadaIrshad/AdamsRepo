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
    let type : Int?
    let rate : Double?
    let name, address: String?
    let latitude, longitude: Double?
    let phoneNumber, workingHours: String?
    let isOpen: Bool?
    let image: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case type = "Type"
        case rate = "Rate"
        case name = "Name"
        case latitude = "Latitude"
        case longitude = "Longitude"
        case phoneNumber = "PhoneNumber"
        case workingHours = "WorkingHours"
        case isOpen = "IsOpen"
        case image = "Image"
        case address = "Address"
    }
    
    init(id: Int?,type : Int?,rate : Double?, name: String?, address : String?, latitude: Double?, longitude: Double?, phoneNumber: String?, workingHours: String?, isOpen: Bool?, image: String?) {
        self.id = id
        self.type = type
        self.rate = rate ?? 0.0
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.phoneNumber = phoneNumber
        self.workingHours = workingHours
        self.isOpen = isOpen
        self.image = image
        self.address = address
    }
}
