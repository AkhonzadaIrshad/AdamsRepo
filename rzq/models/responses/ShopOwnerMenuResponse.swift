//
//  ShopOwnerDetailsResponse.swift
//  rzq
//
//  Created by Zaid Khaled on 10/24/19.
//  Copyright © 2019 technzone. All rights reserved.
//

import Foundation

// MARK: - ShopOwnerMenuResponse
class ShopOwnerMenuResponse: Codable {
    let shopOwnerData: [ShopOwnerDatum]?
    let errorCode: Int?
    let errorMessage: String?

    enum CodingKeys: String, CodingKey {
        case shopOwnerData = "Data"
        case errorCode = "ErrorCode"
        case errorMessage = "ErrorMessage"
    }

    init(shopOwnerData: [ShopOwnerDatum]?, errorCode: Int?, errorMessage: String?) {
        self.shopOwnerData = shopOwnerData
        self.errorCode = errorCode
        self.errorMessage = errorMessage
    }
}

// MARK: - ShopOwnerDatum
class ShopOwnerDatum: Codable {
    let id: Int?
    let arabicName, englishName, imageName: String?
    let shopID: Int?
    let showOwnerItems: [ShowOwnerItem]?

    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case arabicName = "ArabicName"
        case englishName = "EnglishName"
        case imageName = "ImageName"
        case shopID = "ShopId"
        case showOwnerItems = "Items"
    }

    init(id: Int?, arabicName: String?, englishName: String?, imageName: String?, shopID: Int?, showOwnerItems: [ShowOwnerItem]?) {
        self.id = id
        self.arabicName = arabicName
        self.englishName = englishName
        self.imageName = imageName
        self.shopID = shopID
        self.showOwnerItems = showOwnerItems
    }
}

// MARK: - ShowOwnerItem
class ShowOwnerItem: Codable {
    let id: Int?
    let arabicName, englishName, imageName: String?
    let price: Double?
    let arabicDescription, englishDescription: String?

    var status : Int?
    
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
