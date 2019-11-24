//
//  ProviderRatingRespones.swift
//  rzq
//
//  Created by Zaid Khaled on 11/1/19.
//  Copyright © 2019 technzone. All rights reserved.
//

import Foundation

// MARK: - ProviderRatingRespones
class ProviderRatingRespones: Codable {
    let ratingsData: RatingsData?
    let errorCode: Int?
    let errorMessage: String?

    enum CodingKeys: String, CodingKey {
        case ratingsData = "Data"
        case errorCode = "ErrorCode"
        case errorMessage = "ErrorMessage"
    }

    init(ratingsData: RatingsData?, errorCode: Int?, errorMessage: String?) {
        self.ratingsData = ratingsData
        self.errorCode = errorCode
        self.errorMessage = errorMessage
    }
}

// MARK: - RatingsData
class RatingsData: Codable {
    let ratingData: [RatingDatum]?
    let totalRows: Int?

    enum CodingKeys: String, CodingKey {
        case ratingData = "Data"
        case totalRows = "TotalRows"
    }

    init(ratingData: [RatingDatum]?, totalRows: Int?) {
        self.ratingData = ratingData
        self.totalRows = totalRows
    }
}

// MARK: - RatingDatum
class RatingDatum: Codable {
    let userID, fullName: String?
    let rate: Int?
    let createdDate, comment: String?

    enum CodingKeys: String, CodingKey {
        case userID = "UserId"
        case fullName = "FullName"
        case rate = "Rate"
        case createdDate = "CreatedDate"
        case comment = "Comment"
    }

    init(userID: String?, fullName: String?, rate: Int?, createdDate: String?, comment: String?) {
        self.userID = userID
        self.fullName = fullName
        self.rate = rate
        self.createdDate = createdDate
        self.comment = comment
    }
}
