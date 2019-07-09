//
//  ProfileResponse.swift
//  rzq
//
//  Created by Zaid najjar on 4/15/19.
//  Copyright © 2019 technzone. All rights reserved.
//

import Foundation

class ProfileResponse: Codable {
    let dataProfileObj: DataProfileObj?
    let errorCode: Int?
    let errorMessage: String?
    
    enum CodingKeys: String, CodingKey {
        case dataProfileObj = "Data"
        case errorCode = "ErrorCode"
        case errorMessage = "ErrorMessage"
    }
    
    init(dataProfileObj: DataProfileObj?, errorCode: Int?, errorMessage: String?) {
        self.dataProfileObj = dataProfileObj
        self.errorCode = errorCode
        self.errorMessage = errorMessage
    }
}

class DataProfileObj: Codable {
    let id, fullName: String?
    let gender: Int?
    let rate, dueAmount, earnings, balance : Double?
    let dateOfBirth, image, email, phoneNumber: String?
    let ordersCount: Int?
    let roles: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case fullName = "FullName"
        case gender = "Gender"
        case rate = "Rate"
        case dateOfBirth = "DateOfBirth"
        case image = "Image"
        case email = "Email"
        case phoneNumber = "PhoneNumber"
        case dueAmount = "DueAmount"
        case ordersCount = "OrdersCount"
        case roles = "Roles"
        case earnings = "Earnings"
        case balance = "Balance"
    }
    
    init(id: String?, fullName: String?, gender: Int?, rate: Double?, dateOfBirth: String?, image: String?, email: String?, phoneNumber: String?, dueAmount: Double?, ordersCount: Int?, roles: String?, earnings : Double?, balance : Double?) {
        self.id = id
        self.fullName = fullName
        self.gender = gender
        self.rate = rate
        self.dateOfBirth = dateOfBirth
        self.image = image
        self.email = email
        self.phoneNumber = phoneNumber
        self.dueAmount = dueAmount
        self.ordersCount = ordersCount
        self.roles = roles
        self.earnings = earnings
        self.balance = balance
    }
}
