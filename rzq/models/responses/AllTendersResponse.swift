//
//  AllTendersResponse.swift
//  rzq
//
//  Created by Zaid najjar on 5/26/19.
//  Copyright © 2019 technzone. All rights reserved.
//

import Foundation

// MARK: - AllTendersResponse
class AllTendersResponse: Codable {
    let data: [TenderData]?
    let errorCode: Int?
    let errorMessage: String?
    
    enum CodingKeys: String, CodingKey {
        case data = "Data"
        case errorCode = "ErrorCode"
        case errorMessage = "ErrorMessage"
    }
    
    init(data: [TenderData]?, errorCode: Int?, errorMessage: String?) {
        self.data = data
        self.errorCode = errorCode
        self.errorMessage = errorMessage
    }
}

// MARK: - Datum
class TenderData: Codable {
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
