//
//  PaymentResponse.swift
//  rzq
//
//  Created by Zaid Khaled on 10/22/19.
//  Copyright © 2019 technzone. All rights reserved.
//

import Foundation

// MARK: - PaymentResponse
class PaymentResponse: Codable {
    let isSuccess: Bool?
    let message: String?
    let paymentData: PaymentData?

    enum CodingKeys: String, CodingKey {
        case isSuccess = "IsSuccess"
        case message = "Message"
        case paymentData = "Data"
    }

    init(isSuccess: Bool?, message: String?, paymentData: PaymentData?) {
        self.isSuccess = isSuccess
        self.message = message
        self.paymentData = paymentData
    }
}

// MARK: - PaymentData
class PaymentData: Codable {
    let invoiceID: Int?
    let isDirectPayment: Bool?
    let paymentURL: String?
    let customerReference, userDefinedField: String?

    enum CodingKeys: String, CodingKey {
        case invoiceID = "InvoiceId"
        case isDirectPayment = "IsDirectPayment"
        case paymentURL = "PaymentURL"
        case customerReference = "CustomerReference"
        case userDefinedField = "UserDefinedField"
    }

    init(invoiceID: Int?, isDirectPayment: Bool?, paymentURL: String?, customerReference: String?, userDefinedField: String?) {
        self.invoiceID = invoiceID
        self.isDirectPayment = isDirectPayment
        self.paymentURL = paymentURL
        self.customerReference = customerReference
        self.userDefinedField = userDefinedField
    }
}
