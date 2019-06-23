//
//  AllServicesResponse.swift
//  rzq
//
//  Created by Zaid najjar on 5/23/19.
//  Copyright © 2019 technzone. All rights reserved.
//

import Foundation

// MARK: - AllServicesResponse
class AllServicesResponse: Codable {
    let data: [ServiceData]?
    let errorCode: Int?
    let errorMessage: String?
    
    enum CodingKeys: String, CodingKey {
        case data = "Data"
        case errorCode = "ErrorCode"
        case errorMessage = "ErrorMessage"
    }
    
    init(data: [ServiceData]?, errorCode: Int?, errorMessage: String?) {
        self.data = data
        self.errorCode = errorCode
        self.errorMessage = errorMessage
    }
}

// MARK: - Datum
class ServiceData: Codable {
    let id: Int?
    let name, image: String?
    var isChecked : Bool?
    
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
