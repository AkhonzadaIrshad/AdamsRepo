//
//  AllTypesResponse.swift
//  rzq
//
//  Created by Zaid najjar on 5/22/19.
//  Copyright © 2019 technzone. All rights reserved.
//

import Foundation

// MARK: - AllTypesResponse
class AllTypesResponse: Codable {
    let data: [TypeClass]?
    let errorCode: Int?
    let errorMessage: String?
    
    enum CodingKeys: String, CodingKey {
        case data = "Data"
        case errorCode = "ErrorCode"
        case errorMessage = "ErrorMessage"
    }
    
    init(data: [TypeClass]?, errorCode: Int?, errorMessage: String?) {
        self.data = data
        self.errorCode = errorCode
        self.errorMessage = errorMessage
    }
}
