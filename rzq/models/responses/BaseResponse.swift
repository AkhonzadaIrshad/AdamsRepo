//
//  BaseResponse.swift
//  rzq
//
//  Created by Zaid najjar on 4/9/19.
//  Copyright © 2019 technzone. All rights reserved.
//

import Foundation
class BaseResponse: Codable {
    let errorCode: Int?
    let errorMessage: String?
    let message: String?
    
    enum CodingKeys: String, CodingKey {
        case errorCode = "ErrorCode"
        case errorMessage = "ErrorMessage"
        case message = "Message"
    }
    
    init(errorCode: Int?, errorMessage: String?, message: String?) {
        self.errorCode = errorCode
        self.errorMessage = errorMessage
        self.message = message
    }
}
