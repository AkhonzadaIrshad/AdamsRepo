//
//  MenuDetailsByShopResponse.swift
//  rzq
//
//  Created by Zaid Khaled on 10/23/19.
//  Copyright © 2019 technzone. All rights reserved.
//

import Foundation

// MARK: - MenuDetailsByShopResponse
class MenuDetailsByShopResponse: Codable {
    let shopMenuData: [ShopMenuDatum]?
    let errorCode: Int?
    let errorMessage: String?

    enum CodingKeys: String, CodingKey {
        case shopMenuData = "Data"
        case errorCode = "ErrorCode"
        case errorMessage = "ErrorMessage"
    }

    init(shopMenuData: [ShopMenuDatum]?, errorCode: Int?, errorMessage: String?) {
        self.shopMenuData = shopMenuData
        self.errorCode = errorCode
        self.errorMessage = errorMessage
    }
}

// MARK: - ShopMenuDatum
class ShopMenuDatum: Codable {
    let id: Int?
    let name, imageName: String?
    let shopMenuItems: [ShopMenuItem]?
    var isChecked : Bool?

    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case name = "Name"
        case imageName = "ImageName"
        case shopMenuItems = "Items"
    }

    init(id: Int?, name: String?, imageName: String?, shopMenuItems: [ShopMenuItem]?) {
        self.id = id
        self.name = name
        self.imageName = imageName
        self.shopMenuItems = shopMenuItems
    }
}

// MARK: - ShopMenuItem
class ShopMenuItem: Codable {
    let id: Int?
    let name, imageName: String?
    let price: Double?
    let shopMenuItemDescription: String?
    var quantity : Int?

    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case name = "Name"
        case imageName = "ImageName"
        case price = "Price"
        case shopMenuItemDescription = "Description"
    }

    init(id: Int?, name: String?, imageName: String?, price: Double?, shopMenuItemDescription: String?) {
        self.id = id
        self.name = name
        self.imageName = imageName
        self.price = price
        self.shopMenuItemDescription = shopMenuItemDescription
    }
}
