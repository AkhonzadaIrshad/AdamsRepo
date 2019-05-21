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
    let phoneNumber, workingHours, image: String?
    let rate: Double?
    let type: TypeClass?
    
    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case name = "Name"
        case address = "Address"
        case latitude = "Latitude"
        case longitude = "Longitude"
        case phoneNumber = "PhoneNumber"
        case workingHours = "WorkingHours"
        case image = "Image"
        case rate = "Rate"
        case type = "Type"
    }
    
    init(id: Int?, name: String?, address: String?, latitude: Double?, longitude: Double?, phoneNumber: String?, workingHours: String?, image: String?, rate: Double?, type: TypeClass?) {
        self.id = id
        self.name = name
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
        self.phoneNumber = phoneNumber
        self.workingHours = workingHours
        self.image = image
        self.rate = rate
        self.type = type
    }
}
