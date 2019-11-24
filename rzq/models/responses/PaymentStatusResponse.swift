//
//  PaymentStatusResponse.swift
//  rzq
//
//  Created by Zaid Khaled on 11/4/19.
//  Copyright © 2019 technzone. All rights reserved.
//

import Foundation

// MARK: - PaymentStatusResponse
class PaymentStatusResponse: Codable {
    let isSuccess: Bool?
    let message: String?
    let paymentStatusData: PaymentStatusData?

    enum CodingKeys: String, CodingKey {
        case isSuccess = "IsSuccess"
        case message = "Message"
        case paymentStatusData = "Data"
    }

    init(isSuccess: Bool?, message: String?, paymentStatusData: PaymentStatusData?) {
        self.isSuccess = isSuccess
        self.message = message
        self.paymentStatusData = paymentStatusData
    }
}

// MARK: - PaymentStatusData
class PaymentStatusData: Codable {
    let invoiceID: Int?
    let invoiceStatus, invoiceReference, customerReference, createdDate: String?
    let expiryDate: String?
    let invoiceValue: Double?
    let comments, customerName, customerMobile, customerEmail: String?
    let userDefinedField, invoiceDisplayValue: String?
    let invoiceItems: [InvoiceItem]?
    let invoiceTransactions: [InvoiceTransaction]?

    enum CodingKeys: String, CodingKey {
        case invoiceID = "InvoiceId"
        case invoiceStatus = "InvoiceStatus"
        case invoiceReference = "InvoiceReference"
        case customerReference = "CustomerReference"
        case createdDate = "CreatedDate"
        case expiryDate = "ExpiryDate"
        case invoiceValue = "InvoiceValue"
        case comments = "Comments"
        case customerName = "CustomerName"
        case customerMobile = "CustomerMobile"
        case customerEmail = "CustomerEmail"
        case userDefinedField = "UserDefinedField"
        case invoiceDisplayValue = "InvoiceDisplayValue"
        case invoiceItems = "InvoiceItems"
        case invoiceTransactions = "InvoiceTransactions"
    }

    init(invoiceID: Int?, invoiceStatus: String?, invoiceReference: String?, customerReference: String?, createdDate: String?, expiryDate: String?, invoiceValue: Double?, comments: String?, customerName: String?, customerMobile: String?, customerEmail: String?, userDefinedField: String?, invoiceDisplayValue: String?, invoiceItems: [InvoiceItem]?, invoiceTransactions: [InvoiceTransaction]?) {
        self.invoiceID = invoiceID
        self.invoiceStatus = invoiceStatus
        self.invoiceReference = invoiceReference
        self.customerReference = customerReference
        self.createdDate = createdDate
        self.expiryDate = expiryDate
        self.invoiceValue = invoiceValue
        self.comments = comments
        self.customerName = customerName
        self.customerMobile = customerMobile
        self.customerEmail = customerEmail
        self.userDefinedField = userDefinedField
        self.invoiceDisplayValue = invoiceDisplayValue
        self.invoiceItems = invoiceItems
        self.invoiceTransactions = invoiceTransactions
    }
}

// MARK: - InvoiceItem
class InvoiceItem: Codable {
    let itemName: String?
    let quantity: Int?
    let unitPrice: Double?

    enum CodingKeys: String, CodingKey {
        case itemName = "ItemName"
        case quantity = "Quantity"
        case unitPrice = "UnitPrice"
    }

    init(itemName: String?, quantity: Int?, unitPrice: Double?) {
        self.itemName = itemName
        self.quantity = quantity
        self.unitPrice = unitPrice
    }
}

// MARK: - InvoiceTransaction
class InvoiceTransaction: Codable {
    let transactionDate, paymentGateway, referenceID, trackID: String?
    let transactionID, paymentID, authorizationID, transactionStatus: String?
    let transationValue, customerServiceCharge, dueValue, paidCurrency: String?
    let paidCurrencyValue, currency, error: String?

    enum CodingKeys: String, CodingKey {
        case transactionDate = "TransactionDate"
        case paymentGateway = "PaymentGateway"
        case referenceID = "ReferenceId"
        case trackID = "TrackId"
        case transactionID = "TransactionId"
        case paymentID = "PaymentId"
        case authorizationID = "AuthorizationId"
        case transactionStatus = "TransactionStatus"
        case transationValue = "TransationValue"
        case customerServiceCharge = "CustomerServiceCharge"
        case dueValue = "DueValue"
        case paidCurrency = "PaidCurrency"
        case paidCurrencyValue = "PaidCurrencyValue"
        case currency = "Currency"
        case error = "Error"
    }

    init(transactionDate: String?, paymentGateway: String?, referenceID: String?, trackID: String?, transactionID: String?, paymentID: String?, authorizationID: String?, transactionStatus: String?, transationValue: String?, customerServiceCharge: String?, dueValue: String?, paidCurrency: String?, paidCurrencyValue: String?, currency: String?, error: String?) {
        self.transactionDate = transactionDate
        self.paymentGateway = paymentGateway
        self.referenceID = referenceID
        self.trackID = trackID
        self.transactionID = transactionID
        self.paymentID = paymentID
        self.authorizationID = authorizationID
        self.transactionStatus = transactionStatus
        self.transationValue = transationValue
        self.customerServiceCharge = customerServiceCharge
        self.dueValue = dueValue
        self.paidCurrency = paidCurrency
        self.paidCurrencyValue = paidCurrencyValue
        self.currency = currency
        self.error = error
    }
}

