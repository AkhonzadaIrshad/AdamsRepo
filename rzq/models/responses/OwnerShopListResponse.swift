//
//  OwnerShopListResponse.swift
//  rzq
//
//  Created by Zaid Khaled on 10/24/19.
//  Copyright © 2019 technzone. All rights reserved.
//

import Foundation

// MARK: - OwnerShopListResponse
class OwnerShopListResponse: Codable {
    let shopOwnerListData: [ShopOwnerListDatum]?
    let errorCode: Int?
    let errorMessage: String?

    enum CodingKeys: String, CodingKey {
        case shopOwnerListData = "Data"
        case errorCode = "ErrorCode"
        case errorMessage = "ErrorMessage"
    }

    init(shopOwnerListData: [ShopOwnerListDatum]?, errorCode: Int?, errorMessage: String?) {
        self.shopOwnerListData = shopOwnerListData
        self.errorCode = errorCode
        self.errorMessage = errorMessage
    }
}

// MARK: - ShopOwnerListDatum
class ShopOwnerListDatum: Codable {
    let id: Int?
    let arabicName, englishName, googlePlaceID, address: String?
    let latitude, longitude: Double?
    let phoneNumber, workingHours: String?
    let rate: Double?
    let isOpen: Bool?
    let images: [String]?
    let employees: [Employee]?
    let type: TypeClass?

    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case arabicName = "ArabicName"
        case englishName = "EnglishName"
        case googlePlaceID = "GooglePlaceId"
        case address = "Address"
        case latitude = "Latitude"
        case longitude = "Longitude"
        case phoneNumber = "PhoneNumber"
        case workingHours = "WorkingHours"
        case rate = "Rate"
        case isOpen = "IsOpen"
        case images = "Images"
        case employees = "Employees"
        case type = "Type"
    }

    init(id: Int?, arabicName: String?, englishName: String?, googlePlaceID: String?, address: String?, latitude: Double?, longitude: Double?, phoneNumber: String?, workingHours: String?, rate: Double?, isOpen: Bool?, images: [String]?, employees: [Employee]?, type: TypeClass?) {
        self.id = id
        self.arabicName = arabicName
        self.englishName = englishName
        self.googlePlaceID = googlePlaceID
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
        self.phoneNumber = phoneNumber
        self.workingHours = workingHours
        self.rate = rate
        self.isOpen = isOpen
        self.images = images
        self.employees = employees
        self.type = type
    }
}

// MARK: - Employee
class Employee: Codable {
    let id, username, fullName, phoneNumber: String?
    let email: String?
    let isActive: Bool?
    let longitude, latitude: Double?
    let dateOfBirth, profilePictureName: String?
    let gender: Int?
    let roles: [Role]?
    let rate: Double?
    let isOnline, allowNotifications: Bool?
    let dueAmount, earnings, balance: Double?
    let exceededDueAmount: Bool?

    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case username = "Username"
        case fullName = "FullName"
        case phoneNumber = "PhoneNumber"
        case email = "Email"
        case isActive = "IsActive"
        case longitude = "Longitude"
        case latitude = "Latitude"
        case dateOfBirth = "DateOfBirth"
        case profilePictureName = "ProfilePictureName"
        case gender = "Gender"
        case roles = "Roles"
        case rate = "Rate"
        case isOnline = "IsOnline"
        case allowNotifications = "AllowNotifications"
        case dueAmount = "DueAmount"
        case earnings = "Earnings"
        case balance = "Balance"
        case exceededDueAmount = "ExceededDueAmount"
    }

    init(id: String?, username: String?, fullName: String?, phoneNumber: String?, email: String?, isActive: Bool?, longitude: Double?, latitude: Double?, dateOfBirth: String?, profilePictureName: String?, gender: Int?, roles: [Role]?, rate: Double?, isOnline: Bool?, allowNotifications: Bool?, dueAmount: Double?, earnings: Double?, balance: Double?, exceededDueAmount: Bool?) {
        self.id = id
        self.username = username
        self.fullName = fullName
        self.phoneNumber = phoneNumber
        self.email = email
        self.isActive = isActive
        self.longitude = longitude
        self.latitude = latitude
        self.dateOfBirth = dateOfBirth
        self.profilePictureName = profilePictureName
        self.gender = gender
        self.roles = roles
        self.rate = rate
        self.isOnline = isOnline
        self.allowNotifications = allowNotifications
        self.dueAmount = dueAmount
        self.earnings = earnings
        self.balance = balance
        self.exceededDueAmount = exceededDueAmount
    }
}

// MARK: - Role
class Role: Codable {
    let id: Int?
    let name: String?
    let permissions: [Permission]?

    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case name = "Name"
        case permissions = "Permissions"
    }

    init(id: Int?, name: String?, permissions: [Permission]?) {
        self.id = id
        self.name = name
        self.permissions = permissions
    }
}

// MARK: - Permission
class Permission: Codable {
    let id: Int?
    let name: String?

    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case name = "Name"
    }

    init(id: Int?, name: String?) {
        self.id = id
        self.name = name
    }
}

