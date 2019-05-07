//
//  VerifyResponse.swift
//  rzq
//
//  Created by Zaid najjar on 4/9/19.
//  Copyright © 2019 technzone. All rights reserved.
//

import Foundation

class VerifyResponse: Codable {
    let data: DataClass?
    let errorCode: Int?
    let errorMessage: String?
    
    enum CodingKeys: String, CodingKey {
        case data = "Data"
        case errorCode = "ErrorCode"
        case errorMessage = "ErrorMessage"
    }
    
    init(data: DataClass?, errorCode: Int?, errorMessage: String?) {
        self.data = data
        self.errorCode = errorCode
        self.errorMessage = errorMessage
    }
}

class DataClass: Codable {
    let accessToken, phoneNumber, username, fullName: String?
    let userID, dateOfBirth, profilePicture, email: String?
    let gender: Int?
    let rate : Double?
    let roles: String?
    let isOnline: Bool?
    let exceededDueAmount : Bool?
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case phoneNumber = "PhoneNumber"
        case username = "Username"
        case fullName = "FullName"
        case userID = "UserId"
        case dateOfBirth = "DateOfBirth"
        case profilePicture = "ProfilePicture"
        case email = "Email"
        case gender = "Gender"
        case rate = "Rate"
        case roles = "Roles"
        case isOnline = "IsOnline"
        case exceededDueAmount = "ExceededDueAmount"
    }
    
    init(accessToken: String?, phoneNumber: String?, username: String?, fullName: String?, userID: String?, dateOfBirth: String?, profilePicture: String?, email: String?, gender: Int?, rate: Double?, roles: String?, isOnline: Bool?, exceededDueAmount : Bool?) {
        self.accessToken = accessToken
        self.phoneNumber = phoneNumber
        self.username = username
        self.fullName = fullName
        self.userID = userID
        self.dateOfBirth = dateOfBirth
        self.profilePicture = profilePicture
        self.email = email
        self.gender = gender
        self.rate = rate
        self.roles = roles
        self.isOnline = isOnline
        self.exceededDueAmount = exceededDueAmount
    }
}
