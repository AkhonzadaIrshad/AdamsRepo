//
//  AcceptBidResponse.swift
//  rzq
//
//  Created by Zaid najjar on 4/24/19.
//  Copyright © 2019 technzone. All rights reserved.
//

import Foundation

class AcceptBidResponse: Codable {
    let data, errorCode: Int?
    let errorMessage: String?
    
    enum CodingKeys: String, CodingKey {
        case data = "Data"
        case errorCode = "ErrorCode"
        case errorMessage = "ErrorMessage"
    }
    
    init(data: Int?, errorCode: Int?, errorMessage: String?) {
        self.data = data
        self.errorCode = errorCode
        self.errorMessage = errorMessage
    }
}
