//
//  DeliveryLocationResponse.swift
//  rzq
//
//  Created by Zaid najjar on 4/17/19.
//  Copyright © 2019 technzone. All rights reserved.
//

import Foundation

class DeliveryLocationResponse: Codable {
    let locationData: LocationData?
    let errorCode: Int?
    let errorMessage: String?
    
    enum CodingKeys: String, CodingKey {
        case locationData = "Data"
        case errorCode = "ErrorCode"
        case errorMessage = "ErrorMessage"
    }
    
    init(locationData: LocationData?, errorCode: Int?, errorMessage: String?) {
        self.locationData = locationData
        self.errorCode = errorCode
        self.errorMessage = errorMessage
    }
}

class LocationData: Codable {
    let latitude, longitude: Double?
    
    enum CodingKeys: String, CodingKey {
        case latitude = "Latitude"
        case longitude = "Longitude"
    }
    
    init(latitude: Double?, longitude: Double?) {
        self.latitude = latitude
        self.longitude = longitude
    }
}
