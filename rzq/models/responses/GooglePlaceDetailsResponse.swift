import Foundation

// MARK: - GooglePlaceDetailsResponse
class GooglePlaceDetailsResponse: Codable {
    let detailsResult: DetailsResult?
    let status: String?
    
    enum CodingKeys: String, CodingKey {
        case detailsResult = "result"
        case status
    }
    
    init(detailsResult: DetailsResult?, status: String?) {
        self.detailsResult = detailsResult
        self.status = status
    }
}

// MARK: - DetailsResult
class DetailsResult: Codable {
    let openingHours: DetailsOpeningHours?
    
    enum CodingKeys: String, CodingKey {
        case openingHours = "opening_hours"
    }
    
    init(openingHours: DetailsOpeningHours?) {
        self.openingHours = openingHours
    }
}

// MARK: - OpeningHours
class DetailsOpeningHours: Codable {
    let openNow: Bool?
    let detailsPeriods: [DetailsPeriod]?
    let weekdayText: [String]?
    
    enum CodingKeys: String, CodingKey {
        case openNow = "open_now"
        case detailsPeriods = "periods"
        case weekdayText = "weekday_text"
    }
    
    init(openNow: Bool?, detailsPeriods: [DetailsPeriod]?, weekdayText: [String]?) {
        self.openNow = openNow
        self.detailsPeriods = detailsPeriods
        self.weekdayText = weekdayText
    }
}

// MARK: - DetailsPeriod
class DetailsPeriod: Codable {
    let close, detailsPeriodOpen: Close?
    
    enum CodingKeys: String, CodingKey {
        case close
        case detailsPeriodOpen = "open"
    }
    
    init(close: Close?, detailsPeriodOpen: Close?) {
        self.close = close
        self.detailsPeriodOpen = detailsPeriodOpen
    }
}

// MARK: - Close
class Close: Codable {
    let day: Int?
    let time: String?
    
    init(day: Int?, time: String?) {
        self.day = day
        self.time = time
    }
}
