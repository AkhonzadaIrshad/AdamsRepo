//
//  MenuListResponse.swift
//  rzq
//
//  Created by Zaid Khaled on 10/23/19.
//  Copyright © 2019 technzone. All rights reserved.
//

import Foundation

// MARK: - MenuListResponse
class MenuListResponse: Codable {
    let menuList: MenuList?
    let errorCode: Int?
    let errorMessage: String?

    enum CodingKeys: String, CodingKey {
        case menuList = "Data"
        case errorCode = "ErrorCode"
        case errorMessage = "ErrorMessage"
    }

    init(menuList: MenuList?, errorCode: Int?, errorMessage: String?) {
        self.menuList = menuList
        self.errorCode = errorCode
        self.errorMessage = errorMessage
    }
}

// MARK: - MenuList
class MenuList: Codable {
    let menuListData: [MenuListDatum]?
    let totalRows: Int?

    enum CodingKeys: String, CodingKey {
        case menuListData = "Data"
        case totalRows = "TotalRows"
    }

    init(menuListData: [MenuListDatum]?, totalRows: Int?) {
        self.menuListData = menuListData
        self.totalRows = totalRows
    }
}

// MARK: - MenuListDatum
class MenuListDatum: Codable {
    let id: Int?
    let name, imageName: String?
    let menuListItems: [MenuListItem]?

    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case name = "Name"
        case imageName = "ImageName"
        case menuListItems = "Items"
    }

    init(id: Int?, name: String?, imageName: String?, menuListItems: [MenuListItem]?) {
        self.id = id
        self.name = name
        self.imageName = imageName
        self.menuListItems = menuListItems
    }
}

// MARK: - MenuListItem
class MenuListItem: Codable {
    let id: Int?
    let name, imageName: String?
    let price: Double?
    let menuListItemDescription: String?

    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case name = "Name"
        case imageName = "ImageName"
        case price = "Price"
        case menuListItemDescription = "Description"
    }

    init(id: Int?, name: String?, imageName: String?, price: Double?, menuListItemDescription: String?) {
        self.id = id
        self.name = name
        self.imageName = imageName
        self.price = price
        self.menuListItemDescription = menuListItemDescription
    }
}
