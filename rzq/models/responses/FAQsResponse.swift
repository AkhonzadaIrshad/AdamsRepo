//
//  FAQsResponse.swift
//  rzq
//
//  Created by Zaid najjar on 4/16/19.
//  Copyright © 2019 technzone. All rights reserved.
//

import Foundation

class FAQsResponse: Codable {
    let faQsData: [FAQsDatum]?
    let errorCode: Int?
    let errorMessage: String?
    
    enum CodingKeys: String, CodingKey {
        case faQsData = "Data"
        case errorCode = "ErrorCode"
        case errorMessage = "ErrorMessage"
    }
    
    init(faQsData: [FAQsDatum]?, errorCode: Int?, errorMessage: String?) {
        self.faQsData = faQsData
        self.errorCode = errorCode
        self.errorMessage = errorMessage
    }
}

class FAQsDatum: Codable {
    let id: Int?
    let question, answer: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case question = "Question"
        case answer = "Answer"
    }
    
    init(id: Int?, question: String?, answer: String?) {
        self.id = id
        self.question = question
        self.answer = answer
    }
}
