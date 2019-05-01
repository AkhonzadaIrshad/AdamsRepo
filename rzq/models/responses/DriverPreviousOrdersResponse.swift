// To parse the JSON, add this file to your project and do:
//
//   let driverPreviousOrdersResponse = try? newJSONDecoder().decode(DriverPreviousOrdersResponse.self, from: jsonData)

import Foundation

class DriverPreviousOrdersResponse: Codable {
    let data: DataClassDriverDel?
    let errorCode: Int?
    let errorMessage: String?
    
    enum CodingKeys: String, CodingKey {
        case data = "Data"
        case errorCode = "ErrorCode"
        case errorMessage = "ErrorMessage"
    }
    
    init(data: DataClassDriverDel?, errorCode: Int?, errorMessage: String?) {
        self.data = data
        self.errorCode = errorCode
        self.errorMessage = errorMessage
    }
}

class DataClassDriverDel: Codable {
    let data: [DatumDelObj]?
    let totalRows: Int?
    
    enum CodingKeys: String, CodingKey {
        case data = "Data"
        case totalRows = "TotalRows"
    }
    
    init(data: [DatumDelObj]?, totalRows: Int?) {
        self.data = data
        self.totalRows = totalRows
    }
}

class DatumDelObj: Codable {
    let id: Int?
    let driverId: String?
    let fromAddress, toAddress, title: String?
    let status, time: Int?
    let statusString, image, createdDate: String?
    let toLatitude, toLongitude, fromLatitude, fromLongitude, price: Double?
    let driverName, driverImage: String?
    let driverRate: Double?
    let canRate, canCancel, canChat: Bool?
    
    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case driverId = "DriverId"
        case fromAddress = "FromAddress"
        case toAddress = "ToAddress"
        case title = "Title"
        case status = "Status"
        case price = "Price"
        case time = "Time"
        case statusString = "StatusString"
        case image = "Image"
        case createdDate = "CreatedDate"
        case toLatitude = "ToLatitude"
        case toLongitude = "ToLongitude"
        case fromLatitude = "FromLatitude"
        case fromLongitude = "FromLongitude"
        case driverName = "DriverName"
        case driverImage = "DriverImage"
        case driverRate = "DriverRate"
        case canRate = "CanRate"
        case canCancel = "CanCancel"
        case canChat = "CanChat"
    }
    
    init(id: Int?,driverId : String?, fromAddress: String?, toAddress: String?, title: String?, status: Int?, price: Double?, time: Int?, statusString: String?, image: String?, createdDate: String?, toLatitude: Double?, toLongitude: Double?, fromLatitude: Double?, fromLongitude: Double?, driverName: String?, driverImage: String?, driverRate: Double?, canRate: Bool?, canCancel: Bool?, canChat: Bool?) {
        self.id = id
        self.driverId = driverId
        self.fromAddress = fromAddress
        self.toAddress = toAddress
        self.title = title
        self.status = status
        self.price = price
        self.time = time
        self.statusString = statusString
        self.image = image
        self.createdDate = createdDate
        self.toLatitude = toLatitude
        self.toLongitude = toLongitude
        self.fromLatitude = fromLatitude
        self.fromLongitude = fromLongitude
        self.driverName = driverName
        self.driverImage = driverImage
        self.driverRate = driverRate
        self.canRate = canRate
        self.canCancel = canCancel
        self.canChat = canChat
    }
}
