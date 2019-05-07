//
//  MySubscriptionsResponse.swift
//  rzq
//
//  Created by Zaid najjar on 4/18/19.
//  Copyright © 2019 technzone. All rights reserved.
//

import Foundation

class MySubscriptionsResponse: Codable {
    let subsData: [SubsDatum]?
    let errorCode: Int?
    let errorMessage: String?
    
    enum CodingKeys: String, CodingKey {
        case subsData = "Data"
        case errorCode = "ErrorCode"
        case errorMessage = "ErrorMessage"
    }
    
    init(subsData: [SubsDatum]?, errorCode: Int?, errorMessage: String?) {
        self.subsData = subsData
        self.errorCode = errorCode
        self.errorMessage = errorMessage
    }
}

class SubsDatum: Codable {
    let id: Int?
    let name, address: String?
    let latitude, longitude: Double?
    let phoneNumber, workingHours: String?
    let isOpen: Bool?
    let image: String?
    let type : Int?
    
    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case name = "Name"
        case address = "Address"
        case latitude = "Latitude"
        case longitude = "Longitude"
        case phoneNumber = "PhoneNumber"
        case workingHours = "WorkingHours"
        case isOpen = "IsOpen"
        case image = "Image"
        case type = "Type"
    }
    
    init(id: Int?, name: String?, address: String?, latitude: Double?, longitude: Double?, phoneNumber: String?, workingHours: String?, isOpen: Bool?, image: String?, type : Int?) {
        self.id = id
        self.name = name
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
        self.phoneNumber = phoneNumber
        self.workingHours = workingHours
        self.isOpen = isOpen
        self.image = image
        self.type = type
    }
}
