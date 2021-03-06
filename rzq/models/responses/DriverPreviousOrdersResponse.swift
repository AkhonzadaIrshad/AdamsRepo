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
    let id, time: Int?
    let title: String?
    let status: Int?
    let statusString, image, createdDate: String?
    let chatId: Int?
    let fromAddress: String?
    let fromLatitude, fromLongitude: Double?
    let toAddress: String?
    let toLatitude, toLongitude: Double?
    let providerID, providerName, providerImage: String?
    let providerRate, price: Double?
    let serviceName: String?
    let paymentMethod : Int?
    let items : [ShopMenuItem]?
    let isPaid : Bool?
    let invoiceId : String?
    let toFemaleOnly : Bool?
    let shopId : Int?
    let OrderPrice : Double?
    let KnetCommission: Double?
    
    
    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case title = "Title"
        case status = "Status"
        case statusString = "StatusString"
        case image = "Image"
        case createdDate = "CreatedDate"
        case chatId = "ChatId"
        case fromAddress = "FromAddress"
        case fromLatitude = "FromLatitude"
        case fromLongitude = "FromLongitude"
        case toAddress = "ToAddress"
        case toLatitude = "ToLatitude"
        case toLongitude = "ToLongitude"
        case providerID = "ProviderId"
        case providerName = "ProviderName"
        case providerImage = "ProviderImage"
        case providerRate = "ProviderRate"
        case time = "Time"
        case price = "Price"
        case serviceName = "ServiceName"
        case items = "Items"
        case paymentMethod = "PaymentMethod"
        case isPaid = "IsPaid"
        case invoiceId = "InvoiceId"
        case toFemaleOnly = "ToFemaleOnly"
        case shopId = "ShopId"
        case OrderPrice = "OrderPrice"
        case KnetCommission = "KnetCommission"
    }
    
    init(id: Int?, title: String?, status: Int?, statusString: String?, image: String?, createdDate: String?, chatId: Int?, fromAddress: String?, fromLatitude: Double?, fromLongitude: Double?, toAddress: String?, toLatitude: Double?, toLongitude: Double?, providerID: String?, providerName: String?, providerImage: String?, providerRate: Double?, time: Int?, price: Double?, serviceName: String?, paymentMethod: Int?, items: [ShopMenuItem]?, isPaid : Bool?, invoiceId : String?, toFemaleOnly: Bool?, shopId : Int?,OrderPrice: Double?, KnetCommission: Double?) {
        self.id = id
        self.title = title
        self.status = status
        self.statusString = statusString
        self.image = image
        self.createdDate = createdDate
        self.chatId = chatId
        self.fromAddress = fromAddress
        self.fromLatitude = fromLatitude
        self.fromLongitude = fromLongitude
        self.toAddress = toAddress
        self.toLatitude = toLatitude
        self.toLongitude = toLongitude
        self.providerID = providerID
        self.providerName = providerName
        self.providerImage = providerImage
        self.providerRate = providerRate
        self.time = time
        self.price = price
        self.serviceName = serviceName
        self.paymentMethod = paymentMethod
        self.items = items
        self.isPaid = isPaid
        self.invoiceId = invoiceId
        self.toFemaleOnly = toFemaleOnly
        self.shopId = shopId
        self.OrderPrice = OrderPrice
        self.KnetCommission = KnetCommission
    }
}
