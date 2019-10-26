//
//  MenuDetailsResponse.swift
//  rzq
//
//  Created by Zaid Khaled on 10/23/19.
//  Copyright © 2019 technzone. All rights reserved.
//
import Foundation

// MARK: - MenuDetailsResponse
class MenuDetailsResponse: Codable {
    let menuDetailsData: MenuDetailsData?
    let errorCode: Int?
    let errorMessage: String?

    enum CodingKeys: String, CodingKey {
        case menuDetailsData = "Data"
        case errorCode = "ErrorCode"
        case errorMessage = "ErrorMessage"
    }

    init(menuDetailsData: MenuDetailsData?, errorCode: Int?, errorMessage: String?) {
        self.menuDetailsData = menuDetailsData
        self.errorCode = errorCode
        self.errorMessage = errorMessage
    }
}

// MARK: - MenuDetailsData
class MenuDetailsData: Codable {
    let id: Int?
    let arabicName, englishName, imageName: String?
    let shopID: Int?
    let menuItems: [MenuItem]?

    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case arabicName = "ArabicName"
        case englishName = "EnglishName"
        case imageName = "ImageName"
        case shopID = "ShopId"
        case menuItems = "Items"
    }

    init(id: Int?, arabicName: String?, englishName: String?, imageName: String?, shopID: Int?, menuItems: [MenuItem]?) {
        self.id = id
        self.arabicName = arabicName
        self.englishName = englishName
        self.imageName = imageName
        self.shopID = shopID
        self.menuItems = menuItems
    }
}

// MARK: - MenuItem
class MenuItem: Codable {
    let id: Int?
    let arabicName, englishName, imageName: String?
    let price: Double?
    let arabicDescription, englishDescription: String?

    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case arabicName = "ArabicName"
        case englishName = "EnglishName"
        case imageName = "ImageName"
        case price = "Price"
        case arabicDescription = "ArabicDescription"
        case englishDescription = "EnglishDescription"
    }

    init(id: Int?, arabicName: String?, englishName: String?, imageName: String?, price: Double?, arabicDescription: String?, englishDescription: String?) {
        self.id = id
        self.arabicName = arabicName
        self.englishName = englishName
        self.imageName = imageName
        self.price = price
        self.arabicDescription = arabicDescription
        self.englishDescription = englishDescription
    }
}
