//
//  userAdress.swift
//  rzq
//
//  Created by Said Elmansour on 2021-05-09.
//  Copyright © 2021 technzone. All rights reserved.
//

import Foundation

// MARK: - UserAdressResponse
class UserAdressResponse: Codable {
    let errorCode: Int?
    let message: String?
    let userAdressData: [userAdressData]?

    enum CodingKeys: String, CodingKey {
        case errorCode = "ErrorCode"
        case message = "Message"
        case userAdressData = "Data"
    }

    init(errorCode: Int, message: String?, userAdressData: [userAdressData]?) {
        self.errorCode = errorCode
        self.message = message
        self.userAdressData = userAdressData
    }
}

// MARK: - userAdressData
class userAdressData: Codable {
    let name: String?
    let longitude, latitude: Double?

    enum CodingKeys: String, CodingKey {
        case name = "Name"
        case longitude = "Longitude"
        case latitude = "Latitude"
    }

    init(name: String?, longitude: Double?, latitude: Double?) {
        self.name = name
        self.longitude = longitude
        self.latitude = latitude
    }
}
