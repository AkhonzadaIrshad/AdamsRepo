//
//  ApiService.swift
//  rzq
//
//  Created by Zaid najjar on 4/9/19.
//  Copyright © 2019 technzone. All rights reserved.
//

import Foundation
import Alamofire
import MOLH

class ApiService : NSObject {
    
    
    static func getLang() -> String {
        if (MOLHLanguage.currentAppleLanguage() == "ar") {
            return "ar"
        }else {
            return "en"
        }
    }
    
    static func goOnline(Authorization:String , completion:@escaping(_ response : BaseResponse)-> Void) {
        let headers = [Constants.AUTH_HEADER: "bearer \(Authorization)",
            Constants.LANG_HEADER : self.getLang()]
        
        AFManager.request("\(Constants.BASE_URL)User/GoOnline", method: .post, parameters: nil ,encoding: JSONEncoding.default, headers: headers)
            .responseJSON { response in
                if let json = response.data {
                    do {
                        let decoder = JSONDecoder()
                        let baseResponse = try decoder.decode(BaseResponse.self, from: json)
                        completion(baseResponse)
                    }catch let err{
                        print(err)
                    }
                }
        }
    }
    
    static func goOffline(Authorization:String , completion:@escaping(_ response : BaseResponse)-> Void) {
        let headers = [Constants.AUTH_HEADER: "bearer \(Authorization)",
            Constants.LANG_HEADER : self.getLang()]
        
        AFManager.request("\(Constants.BASE_URL)User/GoOffline", method: .post, parameters: nil ,encoding: JSONEncoding.default, headers: headers)
            .responseJSON { response in
                if let json = response.data {
                    do {
                        let decoder = JSONDecoder()
                        let baseResponse = try decoder.decode(BaseResponse.self, from: json)
                        completion(baseResponse)
                    }catch let err{
                        print(err)
                    }
                }
        }
    }
    
    static func registerUser(phoneNumber:String ,fullName : String, email : String, birthDate : String, gender : Int,isResend : Bool, completion:@escaping(_ response : RegisterResponse)-> Void) {
        
        let all : [String : Any] = ["PhoneNumber" : phoneNumber,
                                    "FullName" : fullName,
                                    "Email" : email,
                                    "DateOfBirth" : birthDate,
                                    "Gender" : gender,
                                    "IsResend" : isResend]
        
        AFManager.request("\(Constants.BASE_URL)User/Register", method: .post, parameters: all ,encoding: JSONEncoding.default, headers: nil)
            .responseJSON { response in
                if let json = response.data {
                    do {
                        let decoder = JSONDecoder()
                        let baseResponse = try decoder.decode(RegisterResponse.self, from: json)
                        completion(baseResponse)
                    }catch let err{
                        print(err)
                    }
                }
        }
    }
    
    static func verifyPinCode(userId:String ,code : String, completion:@escaping(_ response : VerifyResponse?, _ status : Int)-> Void) {
        
        let all : [String : Any] = ["UserId" : userId,
                                    "Code" : code]
        
        AFManager.request("\(Constants.BASE_URL)User/Verify", method: .post, parameters: all ,encoding: JSONEncoding.default, headers: nil)
            .responseJSON { response in
                if let json = response.data {
                    do {
                        let decoder = JSONDecoder()
                        let baseResponse = try decoder.decode(VerifyResponse.self, from: json)
                        completion(baseResponse, 0)
                    }catch let err{
                        print(err)
                        completion(nil, 101)
                    }
                }
        }
    }
    
    
    static func refreshToken(Authorization : String, completion:@escaping(_ response : VerifyResponse)-> Void) {
        
        let headers = [Constants.AUTH_HEADER: "bearer \(Authorization)",
            Constants.LANG_HEADER : self.getLang()]
        
        AFManager.request("\(Constants.BASE_URL)User/RefreshToken", method: .post, parameters: nil ,encoding: JSONEncoding.default, headers: headers)
            .responseJSON { response in
                if let json = response.data {
                    do {
                        let decoder = JSONDecoder()
                        let baseResponse = try decoder.decode(VerifyResponse.self, from: json)
                        completion(baseResponse)
                    }catch let err{
                        print(err)
                    }
                }
        }
    }
    
    static func updateProfile(Authorization : String, FullName:String ,Email : String, birthDate : String, gender : Int, profileImage : String, completion:@escaping(_ response : BaseResponse)-> Void) {
        
        let headers = [Constants.AUTH_HEADER: "bearer \(Authorization)",
            Constants.LANG_HEADER : self.getLang()]
        
        let all : [String : Any] = ["FullName" : FullName,
                                    "Email" : Email,
                                    "DateOfBirth" : birthDate,
                                    "Gender" : gender,
                                    "ProfileImage" : profileImage]
        
        AFManager.request("\(Constants.BASE_URL)User/UpdateProfile", method: .post, parameters: all ,encoding: JSONEncoding.default, headers: headers)
            .responseJSON { response in
                if let json = response.data {
                    do {
                        let decoder = JSONDecoder()
                        let baseResponse = try decoder.decode(BaseResponse.self, from: json)
                        completion(baseResponse)
                    }catch let err{
                        print(err)
                    }
                }
        }
    }
    
    static func updateLocation(Authorization : String, latitude:Double ,longitude: Double, completion:@escaping(_ response : BaseResponse)-> Void) {
        
        let headers = [Constants.AUTH_HEADER: "bearer \(Authorization)",
            Constants.LANG_HEADER : self.getLang()]
        
        let all : [String : Any] = ["Longitude" : longitude,
                                    "Latitude" : latitude]
        
        AFManager.request("\(Constants.BASE_URL)User/UpdateLocation", method: .post, parameters: all ,encoding: JSONEncoding.default, headers: headers)
            .responseJSON { response in
                if let json = response.data {
                    do {
                        let decoder = JSONDecoder()
                        let baseResponse = try decoder.decode(BaseResponse.self, from: json)
                        completion(baseResponse)
                    }catch let err{
                        print(err)
                    }
                }
        }
    }
    
    static func updateRegId(Authorization : String, regId : String, completion:@escaping(_ response : BaseResponse)-> Void) {
        
        let headers = [Constants.AUTH_HEADER: "bearer \(Authorization)",
            Constants.LANG_HEADER : self.getLang()]
        
        let all : [String : Any] = ["RegistrationId" : regId,
                                    "Type" : "2"]
        
        AFManager.request("\(Constants.BASE_URL)User/UpdateRegistrationId", method: .post, parameters: all ,encoding: JSONEncoding.default, headers: headers)
            .responseJSON { response in
                if let json = response.data {
                    do {
                        let decoder = JSONDecoder()
                        let baseResponse = try decoder.decode(BaseResponse.self, from: json)
                        completion(baseResponse)
                    }catch let err{
                        print(err)
                    }
                }
        }
    }
    
    static func deleteNotification(Authorization : String, id : Int, completion:@escaping(_ response : CreateAddressResponse)-> Void) {
        
        let headers = [Constants.AUTH_HEADER: "bearer \(Authorization)",
            Constants.LANG_HEADER : self.getLang()]
        
        AFManager.request("\(Constants.BASE_URL)UserNotification/Delete?id=\(id)", method: .delete, parameters: nil ,encoding: JSONEncoding.default, headers: headers)
            .responseJSON { response in
                if let json = response.data {
                    do {
                        let decoder = JSONDecoder()
                        let baseResponse = try decoder.decode(CreateAddressResponse.self, from: json)
                        completion(baseResponse)
                    }catch let err{
                        print(err)
                    }
                }
        }
    }
    
    //delivery
    
    static func getDelivery(id : Int, completion:@escaping(_ response : DeliveryResponse)-> Void) {
        
        let headers = [Constants.LANG_HEADER : self.getLang()]
        
        AFManager.request("\(Constants.BASE_URL)Order/Get?id=\(id)", method: .get, parameters: nil ,encoding: JSONEncoding.default, headers: headers)
            .responseJSON { response in
                if let json = response.data {
                    do {
                        let decoder = JSONDecoder()
                        let baseResponse = try decoder.decode(DeliveryResponse.self, from: json)
                        completion(baseResponse)
                    }catch let err{
                        print(err)
                    }
                }
        }
    }
    
    static func createDelivery(Authorization : String, desc: String ,fromLongitude : Double, fromLatitude : Double, toLongitude : Double, toLatitude : Double, time : Int, estimatedPrice : String, fromAddress : String,toAddress : String, shopId : Int,pickUpDetails : String, dropOffDetails : String, completion:@escaping(_ response : DeliveryCreatedResponse)-> Void) {
        
        let headers = [Constants.AUTH_HEADER: "bearer \(Authorization)",
            Constants.LANG_HEADER : self.getLang()]
        
        let all : [String : Any] = ["Description" : desc,
                                    "FromLongitude" : fromLongitude,
                                    "FromLatitude" : fromLatitude,
                                    "ToLongitude" : toLongitude,
                                    "ToLatitude" : toLatitude,
                                    "FromAddress" : fromAddress,
                                    "ToAddress" : toAddress,
                                    "EstimatedTime" : time,
                                    "EstimatedPrice" : estimatedPrice,
                                    "ShopId" : shopId,
                                    "PickUpDetails" : pickUpDetails,
                                    "DropOffDetails" : dropOffDetails]
        // "ShopId" : shopId]
        
        AFManager.request("\(Constants.BASE_URL)Delivery/Create", method: .post, parameters: all ,encoding: JSONEncoding.default, headers: headers)
            .responseJSON { response in
                if let json = response.data {
                    do {
                        let decoder = JSONDecoder()
                        let baseResponse = try decoder.decode(DeliveryCreatedResponse.self, from: json)
                        completion(baseResponse)
                    }catch let err{
                        print(err)
                    }
                }
        }
    }
    
    
    
    static func createService(Authorization : String, desc: String ,toLongitude : Double, toLatitude : Double, time : Int, price : String, address : String, serviceId : Int, dropOffDetails : String, completion:@escaping(_ response : DeliveryCreatedResponse)-> Void) {
        
        let headers = [Constants.AUTH_HEADER: "bearer \(Authorization)",
            Constants.LANG_HEADER : self.getLang()]
        
        let all : [String : Any] = ["Description" : desc,
                                    "Longitude" : toLongitude,
                                    "Latitude" : toLatitude,
                                    "Address" : address,
                                    "ServiceId" : serviceId,
                                    "EstimatedTime" : time,
                                    "EstimatedPrice" : price,
                                    "DropOffDetails" : dropOffDetails]
        
        
        AFManager.request("\(Constants.BASE_URL)ServiceOrder/Create", method: .post, parameters: all ,encoding: JSONEncoding.default, headers: headers)
            .responseJSON { response in
                if let json = response.data {
                    do {
                        let decoder = JSONDecoder()
                        let baseResponse = try decoder.decode(DeliveryCreatedResponse.self, from: json)
                        completion(baseResponse)
                    }catch let err{
                        print(err)
                    }
                }
        }
    }
    
    
    
    
    static func createTender(Authorization : String, desc: String ,toLongitude : Double, toLatitude : Double, time : Int, price : String, address : String, serviceId : Int, dropOffDetails : String, completion:@escaping(_ response : DeliveryCreatedResponse)-> Void) {
        
        let headers = [Constants.AUTH_HEADER: "bearer \(Authorization)",
            Constants.LANG_HEADER : self.getLang()]
        
        let all : [String : Any] = ["Description" : desc,
                                    "Longitude" : toLongitude,
                                    "Latitude" : toLatitude,
                                    "Address" : address,
                                    "TenderId" : serviceId,
                                    "EstimatedTime" : time,
                                    "EstimatedPrice" : price,
                                    "DropOffDetails" : dropOffDetails]
        
        
        AFManager.request("\(Constants.BASE_URL)TenderOrder/Create", method: .post, parameters: all ,encoding: JSONEncoding.default, headers: headers)
            .responseJSON { response in
                if let json = response.data {
                    do {
                        let decoder = JSONDecoder()
                        let baseResponse = try decoder.decode(DeliveryCreatedResponse.self, from: json)
                        completion(baseResponse)
                    }catch let err{
                        print(err)
                    }
                }
        }
    }
    
    
    
    static func createBid(Authorization : String, deliveryId: Int ,time : Int, price : String, longitude : Double, latitude : Double, completion:@escaping(_ response : DeliveryCreatedResponse)-> Void) {
        
        let headers = [Constants.AUTH_HEADER: "bearer \(Authorization)",
            Constants.LANG_HEADER : self.getLang()]
        
        let all : [String : Any] = ["OrderId" : deliveryId,
                                    "Time" : time,
                                    "Price" : price,
                                    "Longitude" : longitude,
                                    "Latitude" : latitude]
        
        AFManager.request("\(Constants.BASE_URL)Order/CreateBid", method: .post, parameters: all ,encoding: JSONEncoding.default, headers: headers)
            .responseJSON { response in
                if let json = response.data {
                    do {
                        let decoder = JSONDecoder()
                        let baseResponse = try decoder.decode(DeliveryCreatedResponse.self, from: json)
                        completion(baseResponse)
                    }catch let err{
                        print(err)
                    }
                }
        }
    }
    
    
    static func cancelDelivery(Authorization : String, deliveryId: Int, completion:@escaping(_ response : BaseResponse)-> Void) {
        
        let headers = [Constants.AUTH_HEADER: "bearer \(Authorization)",
            Constants.LANG_HEADER : self.getLang()]
        
        AFManager.request("\(Constants.BASE_URL)Order/Cancel?id=\(deliveryId)", method: .post, parameters: nil ,encoding: JSONEncoding.default, headers: headers)
            .responseJSON { response in
                if let json = response.data {
                    do {
                        let decoder = JSONDecoder()
                        let baseResponse = try decoder.decode(BaseResponse.self, from: json)
                        completion(baseResponse)
                    }catch let err{
                        print(err)
                    }
                }
        }
    }
    
    
    static func cancelDeliveryByDriver(Authorization : String, deliveryId: Int, completion:@escaping(_ response : BaseResponse)-> Void) {
        
        let headers = [Constants.AUTH_HEADER: "bearer \(Authorization)",
            Constants.LANG_HEADER : self.getLang()]
        
        AFManager.request("\(Constants.BASE_URL)Order/CancelByProvider?id=\(deliveryId)", method: .post, parameters: nil ,encoding: JSONEncoding.default, headers: headers)
            .responseJSON { response in
                if let json = response.data {
                    do {
                        let decoder = JSONDecoder()
                        let baseResponse = try decoder.decode(BaseResponse.self, from: json)
                        completion(baseResponse)
                    }catch let err{
                        print(err)
                    }
                }
        }
    }
    
    
    static func acceptBid(Authorization : String, deliveryId: Int, bidId : Int, completion:@escaping(_ response : AcceptBidResponse)-> Void) {
        
        let headers = [Constants.AUTH_HEADER : "bearer \(Authorization)",
            Constants.LANG_HEADER : self.getLang()]
        
        //        let all : [String : Any] = ["DeliveryId" : deliveryId,
        //                                    "BidId" : bidId]
        
        AFManager.request("\(Constants.BASE_URL)Order/AcceptBid?id=\(bidId)", method: .post, parameters: nil ,encoding: JSONEncoding.default, headers: headers)
            .responseJSON { response in
                if let json = response.data {
                    do {
                        let decoder = JSONDecoder()
                        let baseResponse = try decoder.decode(AcceptBidResponse.self, from: json)
                        completion(baseResponse)
                    }catch let err{
                        print(err)
                    }
                }
        }
    }
    
    static func declineBid(Authorization : String, bidId : Int, completion:@escaping(_ response : BaseResponse)-> Void) {
        
        let headers = [Constants.AUTH_HEADER: "bearer \(Authorization)",
            Constants.LANG_HEADER : self.getLang()]
        
        AFManager.request("\(Constants.BASE_URL)Order/DeclineBid?id=\(bidId)", method: .post, parameters: nil ,encoding: JSONEncoding.default, headers: headers)
            .responseJSON { response in
                if let json = response.data {
                    do {
                        let decoder = JSONDecoder()
                        let baseResponse = try decoder.decode(BaseResponse.self, from: json)
                        completion(baseResponse)
                    }catch let err{
                        print(err)
                    }
                }
        }
    }
    
    
    
    
    static func startDelivery(Authorization : String, deliveryId: Int, actualPrice : Double, completion:@escaping(_ response : BaseResponse)-> Void) {
        
        let headers = [Constants.AUTH_HEADER: "bearer \(Authorization)",
            Constants.LANG_HEADER : self.getLang()]
        
        let all : [String : Any] = ["OrderId" : deliveryId,
                                    "OrderPrice" : actualPrice]
        
        AFManager.request("\(Constants.BASE_URL)Order/OnTheWay", method: .post, parameters: all ,encoding: JSONEncoding.default, headers: headers)
            .responseJSON { response in
                if let json = response.data {
                    do {
                        let decoder = JSONDecoder()
                        let baseResponse = try decoder.decode(BaseResponse.self, from: json)
                        completion(baseResponse)
                    }catch let err{
                        print(err)
                    }
                }
        }
    }
    
    static func completeDelivery(Authorization : String, deliveryId: Int, completion:@escaping(_ response : BaseResponse)-> Void) {
        
        let headers = [Constants.AUTH_HEADER: "bearer \(Authorization)",
            Constants.LANG_HEADER : self.getLang()]
        
        AFManager.request("\(Constants.BASE_URL)Order/Complete?id=\(deliveryId)", method: .post, parameters: nil ,encoding: JSONEncoding.default, headers: headers)
            .responseJSON { response in
                if let json = response.data {
                    do {
                        let decoder = JSONDecoder()
                        let baseResponse = try decoder.decode(BaseResponse.self, from: json)
                        completion(baseResponse)
                    }catch let err{
                        print(err)
                    }
                }
        }
    }
    
    
    //    static func createBid(Authorization : String, deliveryId: Int, Time : Int,price : Double, longitude : Double, latitude : Double, completion:@escaping(_ response : CreateBidResponse)-> Void) {
    //
    //        let headers = [Constants.AUTH_HEADER: "bearer \(Authorization)",
    //            Constants.LANG_HEADER : self.getLang()]
    //
    //        let all : [String : Any] = ["DeliveryId" : deliveryId,
    //                                    "Time" : time,
    //                                    "Price" : price,
    //                                    "Longitude" : longitude,
    //                                    "Latitude" : latitude]
    //
    //
    //        AFManager.request("\(Constants.BASE_URL)Delivery/CreateBid", method: .post, parameters: all ,encoding: JSONEncoding.default, headers: headers)
    //            .responseJSON { response in
    //                if let json = response.data {
    //                    do {
    //                        let decoder = JSONDecoder()
    //                        let baseResponse = try decoder.decode(CreateBidResponse.self, from: json)
    //                        completion(baseResponse)
    //                    }catch let err{
    //                        print(err)
    //                    }
    //                }
    //        }
    //    }
    
    
    static func getOnGoingDeliveries(Authorization : String, completion:@escaping(_ response : OnGoingDeliveriesResponse)-> Void) {
        
        let headers = [Constants.AUTH_HEADER: "bearer \(Authorization)",
            Constants.LANG_HEADER : self.getLang()]
        
        AFManager.request("\(Constants.BASE_URL)Order/GetOnGoingOrders", method: .get, parameters: nil ,encoding: JSONEncoding.default, headers: headers)
            .responseJSON { response in
                if let json = response.data {
                    do {
                        let decoder = JSONDecoder()
                        let baseResponse = try decoder.decode(OnGoingDeliveriesResponse.self, from: json)
                        completion(baseResponse)
                    }catch let err{
                        print(err)
                    }
                }
        }
    }
    
    
    
    static func getPreviousDeliveries(Authorization : String,pageSize : Int, pageNumber : Int, completion:@escaping(_ response : PreviousDeliveriesResponse)-> Void) {
        
        let headers = [Constants.AUTH_HEADER: "bearer \(Authorization)",
            Constants.LANG_HEADER : self.getLang(),
            "pageSize" : "\(pageSize)",
            "pageNumber" : "\(pageNumber)"]
        
        AFManager.request("\(Constants.BASE_URL)Order/GetPreviousOrders", method: .get, parameters: nil ,encoding: JSONEncoding.default, headers: headers)
            .responseJSON { response in
                if let json = response.data {
                    do {
                        let decoder = JSONDecoder()
                        let baseResponse = try decoder.decode(PreviousDeliveriesResponse.self, from: json)
                        completion(baseResponse)
                    }catch let err{
                        print(err)
                    }
                }
        }
    }
    
    
    
    static func getShopPendingDeliveries(Authorization : String,shopId : Int, completion:@escaping(_ response : ShopDeliveriesResponse)-> Void) {
        
        let headers = [Constants.AUTH_HEADER: "bearer \(Authorization)",
            Constants.LANG_HEADER : self.getLang()]
        
        AFManager.request("\(Constants.BASE_URL)Delivery/GetShopPendingDeliveries?id=\(shopId)", method: .get, parameters: nil ,encoding: JSONEncoding.default, headers: headers)
            .responseJSON { response in
                if let json = response.data {
                    do {
                        let decoder = JSONDecoder()
                        let baseResponse = try decoder.decode(ShopDeliveriesResponse.self, from: json)
                        completion(baseResponse)
                    }catch let err{
                        print(err)
                    }
                }
        }
    }
    
    
    static func getDriverOnGoingDeliveries(Authorization : String, completion:@escaping(_ response : DriverOnGoingOrdersResponse)-> Void) {
        
        let headers = [Constants.AUTH_HEADER: "bearer \(Authorization)",
            Constants.LANG_HEADER : self.getLang()]
        
        AFManager.request("\(Constants.BASE_URL)Order/GetProviderOnGoingOrders", method: .get, parameters: nil ,encoding: JSONEncoding.default, headers: headers)
            .responseJSON { response in
                if let json = response.data {
                    do {
                        let decoder = JSONDecoder()
                        let baseResponse = try decoder.decode(DriverOnGoingOrdersResponse.self, from: json)
                        completion(baseResponse)
                    }catch let err{
                        print(err)
                    }
                }
        }
    }
    
    
    static func getDriverPreviousDeliveries(Authorization : String, completion:@escaping(_ response : DriverPreviousOrdersResponse)-> Void) {
        
        let headers = [Constants.AUTH_HEADER: "bearer \(Authorization)",
            Constants.LANG_HEADER : self.getLang()]
        
        AFManager.request("\(Constants.BASE_URL)Order/GetProviderPreviousOrders", method: .get, parameters: nil ,encoding: JSONEncoding.default, headers: headers)
            .responseJSON { response in
                if let json = response.data {
                    do {
                        let decoder = JSONDecoder()
                        let baseResponse = try decoder.decode(DriverPreviousOrdersResponse.self, from: json)
                        completion(baseResponse)
                    }catch let err{
                        print(err)
                    }
                }
        }
    }
    
    
    
    static func rateDriver(Authorization : String, deliveryId: Int,rate : Int,comment : String, completion:@escaping(_ response : BaseResponse)-> Void) {
        
        let headers = [Constants.AUTH_HEADER: "bearer \(Authorization)",
            Constants.LANG_HEADER : self.getLang()]
        
        let all : [String : Any] = ["OrderId" : deliveryId,
                                    "Rate" : rate,
                                    "Comment" : comment]
        
        AFManager.request("\(Constants.BASE_URL)Order/RateProvider", method: .post, parameters: all ,encoding: JSONEncoding.default, headers: headers)
            .responseJSON { response in
                if let json = response.data {
                    do {
                        let decoder = JSONDecoder()
                        let baseResponse = try decoder.decode(BaseResponse.self, from: json)
                        completion(baseResponse)
                    }catch let err{
                        print(err)
                    }
                }
        }
    }
    
    
    
    static func rateUser(Authorization : String, deliveryId: Int,rate : Int,comment : String, completion:@escaping(_ response : BaseResponse)-> Void) {
        
        let headers = [Constants.AUTH_HEADER: "bearer \(Authorization)",
            Constants.LANG_HEADER : self.getLang()]
        
        let all : [String : Any] = ["OrderId" : deliveryId,
                                    "Rate" : rate,
                                    "Comment" : comment]
        
        AFManager.request("\(Constants.BASE_URL)Order/RateUser", method: .post, parameters: all ,encoding: JSONEncoding.default, headers: headers)
            .responseJSON { response in
                if let json = response.data {
                    do {
                        let decoder = JSONDecoder()
                        let baseResponse = try decoder.decode(BaseResponse.self, from: json)
                        completion(baseResponse)
                    }catch let err{
                        print(err)
                    }
                }
        }
    }
    
    
    
    static func reportDriver(Authorization : String, deliveryId: Int,desc : String, completion:@escaping(_ response : BaseResponse)-> Void) {
        
        let headers = [Constants.AUTH_HEADER: "bearer \(Authorization)",
            Constants.LANG_HEADER : self.getLang()]
        
        let all : [String : Any] = ["OrderId" : deliveryId,
                                    "Description" : desc]
        
        AFManager.request("\(Constants.BASE_URL)Order/ReportProvider", method: .post, parameters: all ,encoding: JSONEncoding.default, headers: headers)
            .responseJSON { response in
                if let json = response.data {
                    do {
                        let decoder = JSONDecoder()
                        let baseResponse = try decoder.decode(BaseResponse.self, from: json)
                        completion(baseResponse)
                    }catch let err{
                        print(err)
                    }
                }
        }
    }
    
    
    static func getAllTypes(completion:@escaping(_ response : AllTypesResponse)-> Void) {
        
        let headers = [Constants.LANG_HEADER : self.getLang()]
        
        AFManager.request("\(Constants.BASE_URL)Shop/GetAllTypes", method: .get, parameters: nil ,encoding: JSONEncoding.default, headers: headers)
            .responseJSON { response in
                if let json = response.data {
                    do {
                        let decoder = JSONDecoder()
                        let baseResponse = try decoder.decode(AllTypesResponse.self, from: json)
                        completion(baseResponse)
                    }catch let err{
                        print(err)
                    }
                }
        }
    }
    
    
    static func getAllServices(name : String, completion:@escaping(_ response : AllServicesResponse)-> Void) {
        
        let headers = [Constants.LANG_HEADER : self.getLang()]
        
        AFManager.request("\(Constants.BASE_URL)Service/GetAll", method: .get, parameters: nil ,encoding: JSONEncoding.default, headers: headers)
            .responseJSON { response in
                if let json = response.data {
                    do {
                        let decoder = JSONDecoder()
                        let baseResponse = try decoder.decode(AllServicesResponse.self, from: json)
                        completion(baseResponse)
                    }catch let err{
                        print(err)
                    }
                }
        }
    }
    
    
    static func getAllTenders(name : String, completion:@escaping(_ response : AllTendersResponse)-> Void) {
        
        let headers = [Constants.LANG_HEADER : self.getLang()]
        
        AFManager.request("\(Constants.BASE_URL)Tender/GetAll", method: .get, parameters: nil ,encoding: JSONEncoding.default, headers: headers)
            .responseJSON { response in
                if let json = response.data {
                    do {
                        let decoder = JSONDecoder()
                        let baseResponse = try decoder.decode(AllTendersResponse.self, from: json)
                        completion(baseResponse)
                    }catch let err{
                        print(err)
                    }
                }
        }
    }
    
    
    static func getAllNotifications(Authorization : String, sortBy : Int, completion:@escaping(_ response : AllNotificationsResponse)-> Void) {
        
        let headers = [Constants.AUTH_HEADER: "bearer \(Authorization)",
            Constants.LANG_HEADER : self.getLang()]
        
        AFManager.request("\(Constants.BASE_URL)UserNotification/GetAll?sortBy=\(sortBy)", method: .get, parameters: nil ,encoding: JSONEncoding.default, headers: headers)
            .responseJSON { response in
                if let json = response.data {
                    do {
                        let decoder = JSONDecoder()
                        let baseResponse = try decoder.decode(AllNotificationsResponse.self, from: json)
                        completion(baseResponse)
                    }catch let err{
                        print(err)
                    }
                }
        }
    }
    
    
    static func suggestShop(Authorization: String,address: String, latitude : Double,longitude : Double, phoneNumber : String, workingHours : String, name : String, type : Int,completion:@escaping(_ response : DeliveryCreatedResponse)-> Void) {
        
        let headers = [Constants.AUTH_HEADER: "bearer \(Authorization)",
                      Constants.LANG_HEADER : self.getLang()]
        
        let all : [String : Any] = ["Address" : address,
                                    "Latitude" : latitude,
                                    "Longitude" : longitude,
                                    "PhoneNumber" : phoneNumber,
                                    "WorkingHours" : workingHours,
                                    "Name" : name,
                                    "Type" : type]
        
        AFManager.request("\(Constants.BASE_URL)Shop/Suggest", method: .post, parameters: all ,encoding: JSONEncoding.default, headers: headers)
            .responseJSON { response in
                if let json = response.data {
                    do {
                        let decoder = JSONDecoder()
                        let baseResponse = try decoder.decode(DeliveryCreatedResponse.self, from: json)
                        completion(baseResponse)
                    }catch let err{
                        print(err)
                    }
                }
        }
    }
    
    
    static func editShop(Authorization: String, address: String, latitude : Double,longitude : Double, phoneNumber : String, workingHours : String, name : String, type : Int, shopId: Int,completion:@escaping(_ response : DeliveryCreatedResponse)-> Void) {
        
        let headers = [Constants.AUTH_HEADER: "bearer \(Authorization)",
                      Constants.LANG_HEADER : self.getLang()]
        
        let all : [String : Any] = ["Address" : address,
                                    "Latitude" : latitude,
                                    "Longitude" : longitude,
                                    "PhoneNumber" : phoneNumber,
                                    "WorkingHours" : workingHours,
                                    "Name" : name,
                                    "Type" : type,
                                    "ShopId" : shopId]
        
        AFManager.request("\(Constants.BASE_URL)Shop/Suggest", method: .post, parameters: all ,encoding: JSONEncoding.default, headers: headers)
            .responseJSON { response in
                if let json = response.data {
                    do {
                        let decoder = JSONDecoder()
                        let baseResponse = try decoder.decode(DeliveryCreatedResponse.self, from: json)
                        completion(baseResponse)
                    }catch let err{
                        print(err)
                    }
                }
        }
    }
    
    
    static func getShops(latitude : Double, longitude : Double, radius : Float,rating : Double,types : Int, completion:@escaping(_ response : ShopListResponse)-> Void) {
        
        let headers = [Constants.LANG_HEADER : self.getLang()]
        
        AFManager.request("\(Constants.BASE_URL)Shop/List?latitude=\(latitude)&longitude=\(longitude)&radius=\(radius)&rate=\(Int(rating))", method: .get, parameters: nil ,encoding: JSONEncoding.default, headers: headers)
            .responseJSON { response in
                if let json = response.data {
                    do {
                        let decoder = JSONDecoder()
                        let baseResponse = try decoder.decode(ShopListResponse.self, from: json)
                        completion(baseResponse)
                    }catch let err{
                        print(err)
                    }
                }
        }
    }
    
    static func getShopsByName(name : String,latitude : Double, longitude : Double, radius : Float, completion:@escaping(_ response : ShopListResponse)-> Void) {
        
        let headers = ["Content-Type": "application/json",
                       Constants.LANG_HEADER : self.getLang()]
        
        let url = "\(Constants.BASE_URL)Shop/ListByName?latitude=\(latitude)&longitude=\(longitude)&radius=\(radius)&name=\(name)"
        let encodedUrl = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? url
        AFManager.request(encodedUrl, method: .get, parameters: nil ,encoding: JSONEncoding.default, headers: headers)
            .response { response in
                if let json = response.data {
                    do {
                        let decoder = JSONDecoder()
                        let baseResponse = try decoder.decode(ShopListResponse.self, from: json)
                        completion(baseResponse)
                    } catch let err{
                        print(err)
                    }
                }
        }
    }
    
    
    static func getShopDetails(Authorization: String, id : Int, completion:@escaping(_ response : ShopDetailsResponse)-> Void) {
        
        let headers = [Constants.AUTH_HEADER: "bearer \(Authorization)",
                      Constants.LANG_HEADER : self.getLang()]
        
        AFManager.request("\(Constants.BASE_URL)Shop/Get?id=\(id)", method: .get, parameters: nil ,encoding: JSONEncoding.default, headers: headers)
            .responseJSON { response in
                if let json = response.data {
                    do {
                        let decoder = JSONDecoder()
                        let baseResponse = try decoder.decode(ShopDetailsResponse.self, from: json)
                        completion(baseResponse)
                    }catch let err{
                        print(err)
                    }
                }
        }
    }
    
    
    static func registerAsDriver(Authorization : String, NationalId: String,DrivingLicense : String,ProfilePicture : String,Email : String, completion:@escaping(_ response : BaseResponse)-> Void) {
        
        let headers = [Constants.AUTH_HEADER: "bearer \(Authorization)",
            Constants.LANG_HEADER : self.getLang()]
        
        let all : [String : Any] = ["NationalId" : NationalId,
                                    "DrivingLicense" : DrivingLicense,
                                    "ProfilePicture" : ProfilePicture,
                                    "Email" : Email]
        
        AFManager.request("\(Constants.BASE_URL)DriverRequest/RegisterAsDriver", method: .post, parameters: all ,encoding: JSONEncoding.default, headers: headers)
            .responseJSON { response in
                if let json = response.data {
                    do {
                        let decoder = JSONDecoder()
                        let baseResponse = try decoder.decode(BaseResponse.self, from: json)
                        completion(baseResponse)
                    }catch let err{
                        print(err)
                    }
                }
        }
    }
    
    
    
    static func registerAsServiceProvider(Authorization : String, services: [Int], serviceName : String, nationalId : String, profilePicture : String, email : String, completion:@escaping(_ response : BaseResponse)-> Void) {
        
        let headers = [Constants.AUTH_HEADER: "bearer \(Authorization)",
            Constants.LANG_HEADER : self.getLang()]
        
        let all : [String : Any] = ["Services" : services,
                                    "ServiceName" : serviceName,
                                    "NationalId" : nationalId,
                                    "ProfilePicture" : profilePicture,
                                    "Email" : email]
        
        AFManager.request("\(Constants.BASE_URL)DriverRequest/RegisterAsServiceProvider", method: .post, parameters: all ,encoding: JSONEncoding.default, headers: headers)
            .responseJSON { response in
                if let json = response.data {
                    do {
                        let decoder = JSONDecoder()
                        let baseResponse = try decoder.decode(BaseResponse.self, from: json)
                        completion(baseResponse)
                    }catch let err{
                        print(err)
                    }
                }
        }
    }
    
    
    
    static func getProfile(Authorization : String, completion:@escaping(_ response : ProfileResponse)-> Void) {
        
        let headers = [Constants.AUTH_HEADER: "bearer \(Authorization)",
            Constants.LANG_HEADER : self.getLang()]
        
        AFManager.request("\(Constants.BASE_URL)User/Profile", method: .get, parameters: nil ,encoding: JSONEncoding.default, headers: headers)
            .responseJSON { response in
                if let json = response.data {
                    do {
                        let decoder = JSONDecoder()
                        let baseResponse = try decoder.decode(ProfileResponse.self, from: json)
                        completion(baseResponse)
                    }catch let err{
                        print(err)
                    }
                }
        }
    }
    
    
    static func getAllFAQs(completion:@escaping(_ response : FAQsResponse)-> Void) {
        
        let headers = [Constants.LANG_HEADER : self.getLang()]
        
        AFManager.request("\(Constants.BASE_URL)Configuration/GetAllFAQs", method: .get, parameters: nil ,encoding: JSONEncoding.default, headers: headers)
            .responseJSON { response in
                if let json = response.data {
                    do {
                        let decoder = JSONDecoder()
                        let baseResponse = try decoder.decode(FAQsResponse.self, from: json)
                        completion(baseResponse)
                    }catch let err{
                        print(err)
                    }
                }
        }
    }
    
    
    static func getAppConfig(completion:@escaping(_ response : AppConfigResponse)-> Void) {
        
        let headers = [Constants.LANG_HEADER : self.getLang()]
        
        AFManager.request("\(Constants.BASE_URL)Configuration/Get", method: .get, parameters: nil ,encoding: JSONEncoding.default, headers: headers)
            .responseJSON { response in
                if let json = response.data {
                    do {
                        let decoder = JSONDecoder()
                        let baseResponse = try decoder.decode(AppConfigResponse.self, from: json)
                        completion(baseResponse)
                    }catch let err{
                        print(err)
                    }
                }
        }
    }
    
    static func contactUs(subject: String,body : String, completion:@escaping(_ response : BaseResponse)-> Void) {
        
        let headers = [Constants.LANG_HEADER : self.getLang()]
        
        let all : [String : Any] = ["Subject" : subject,
                                    "Body" : body]
        
        AFManager.request("\(Constants.BASE_URL)Configuration/ContactUs", method: .post, parameters: all ,encoding: JSONEncoding.default, headers: headers)
            .responseJSON { response in
                if let json = response.data {
                    do {
                        let decoder = JSONDecoder()
                        let baseResponse = try decoder.decode(BaseResponse.self, from: json)
                        completion(baseResponse)
                    }catch let err{
                        print(err)
                    }
                }
        }
    }
    
    
    static func getOrderLocation(Authorization : String,deliveryId : Int, completion:@escaping(_ response : DeliveryLocationResponse)-> Void) {
        
        let headers = [Constants.AUTH_HEADER: "bearer \(Authorization)",
            Constants.LANG_HEADER : self.getLang()]
        
        AFManager.request("\(Constants.BASE_URL)Order/GetOrderLocation?id=\(deliveryId)", method: .get, parameters: nil ,encoding: JSONEncoding.default, headers: headers)
            .responseJSON { response in
                if let json = response.data {
                    do {
                        let decoder = JSONDecoder()
                        let baseResponse = try decoder.decode(DeliveryLocationResponse.self, from: json)
                        completion(baseResponse)
                    }catch let err {
                        print(err)
                    }
                }
        }
    }
    
    static func uploadMedia(Authorization : String, deliveryId: Int, imagesData : [Data], audioData : Data, completion:@escaping(_ response : BaseResponse)-> Void) {
        
        let headers = [Constants.AUTH_HEADER: "bearer \(Authorization)",
            Constants.LANG_HEADER : self.getLang(),
            "Content_Type": "multipart/form-data"]
        
        AFManager.upload(multipartFormData: { (multipartFormData) in
            
            for data in imagesData {
                multipartFormData.append(data, withName: "1",fileName: "image.jpg", mimeType: "image/jpg")
            }
            if (audioData.base64EncodedString().count > 0) {
                multipartFormData.append(audioData, withName: "2",fileName: "audio.m4a", mimeType: "audio/m4a")
            }
            
        }, usingThreshold: UInt64.init(), to: "\(Constants.BASE_URL)Order/Upload?orderId=\(deliveryId)", method: .post, headers: headers) { (result) in
            switch result{
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    if let json = response.data {
                        do {
                            let decoder = JSONDecoder()
                            let baseResponse = try decoder.decode(BaseResponse.self, from: json)
                            completion(baseResponse)
                        }catch let err{
                            print(err)
                        }
                    }
                }
            case .failure(let error):
                completion(BaseResponse(errorCode: 100, errorMessage: error.localizedDescription, message: error.localizedDescription))
            }
        }
        
    }
    
    
    
    static func uploadShopImages(Authorization : String, requestId: Int, imagesData : [Data],completion:@escaping(_ response : BaseResponse)-> Void) {
        
        let headers = [Constants.AUTH_HEADER: "bearer \(Authorization)",
            Constants.LANG_HEADER : self.getLang(),
            "Content_Type": "multipart/form-data"]
        
        AFManager.upload(multipartFormData: { (multipartFormData) in
            
            for data in imagesData {
                multipartFormData.append(data, withName: "1",fileName: "image.jpg", mimeType: "image/jpg")
            }
            
        }, usingThreshold: UInt64.init(), to: "\(Constants.BASE_URL)Shop/UploadRequestImage?requestId=\(requestId)", method: .post, headers: headers) { (result) in
            switch result{
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    if let json = response.data {
                        do {
                            let decoder = JSONDecoder()
                            let baseResponse = try decoder.decode(BaseResponse.self, from: json)
                            completion(baseResponse)
                        }catch let err{
                            print(err)
                        }
                    }
                }
            case .failure(let error):
                completion(BaseResponse(errorCode: 100, errorMessage: error.localizedDescription, message: error.localizedDescription))
            }
        }
        
    }
    
    
    static func getMySubscriptions(Authorization : String, completion:@escaping(_ response : MySubscriptionsResponse)-> Void) {
        
        let headers = [Constants.AUTH_HEADER: "bearer \(Authorization)",
            Constants.LANG_HEADER : self.getLang()]
        
        AFManager.request("\(Constants.BASE_URL)Shop/MySubscriptions", method: .get, parameters: nil ,encoding: JSONEncoding.default, headers: headers)
            .responseJSON { response in
                if let json = response.data {
                    do {
                        let decoder = JSONDecoder()
                        let baseResponse = try decoder.decode(MySubscriptionsResponse.self, from: json)
                        completion(baseResponse)
                    }catch let err {
                        print(err)
                    }
                }
        }
    }
    
    
    
    static func subscribeToShop(Authorization : String,shopId: Int, completion:@escaping(_ response : BaseResponse)-> Void) {
        
        let headers = [Constants.AUTH_HEADER: "bearer \(Authorization)",
            Constants.LANG_HEADER : self.getLang()]
        
        let all : [String : Any] = ["ShopId" : shopId]
        
        AFManager.request("\(Constants.BASE_URL)Shop/Subscribe", method: .post, parameters: all ,encoding: JSONEncoding.default, headers: headers)
            .responseJSON { response in
                if let json = response.data {
                    do {
                        let decoder = JSONDecoder()
                        let baseResponse = try decoder.decode(BaseResponse.self, from: json)
                        completion(baseResponse)
                    }catch let err{
                        print(err)
                    }
                }
        }
    }
    
    
    
    static func subscribeToPlace(Authorization : String,id: String, name: String, address: String, latitude: Double, longitude: Double, phoneNumber: String, workingHours: String, image: String, rate: Int, completion:@escaping(_ response : BaseResponse)-> Void) {
        
        let headers = [Constants.AUTH_HEADER: "bearer \(Authorization)",
            Constants.LANG_HEADER : self.getLang()]
        
        let all : [String : Any] = ["Id" : "\(id)",
                                    "Name" : name,
                                    "Address" : address,
                                    "Latitude": latitude,
                                    "Longitude" : longitude,
                                    "PhoneNumber" : phoneNumber,
                                    "WorkingHours" : workingHours,
                                    "Image" : image,
                                    "Rate" : rate]
        
        AFManager.request("\(Constants.BASE_URL)Shop/SubscribeToPlace", method: .post, parameters: all ,encoding: JSONEncoding.default, headers: headers)
            .responseJSON { response in
                if let json = response.data {
                    do {
                        let decoder = JSONDecoder()
                        let baseResponse = try decoder.decode(BaseResponse.self, from: json)
                        completion(baseResponse)
                    }catch let err{
                        print(err)
                    }
                }
        }
    }
    
    
    static func unsubscribeToShop(Authorization : String,shopId: Int, completion:@escaping(_ response : BaseResponse)-> Void) {
        
        let headers = [Constants.AUTH_HEADER: "bearer \(Authorization)",
            Constants.LANG_HEADER : self.getLang()]
        
        let all : [String : Any] = ["ShopId" : shopId]
        
        AFManager.request("\(Constants.BASE_URL)Shop/Unsubscribe", method: .post, parameters: all ,encoding: JSONEncoding.default, headers: headers)
            .responseJSON { response in
                if let json = response.data {
                    do {
                        let decoder = JSONDecoder()
                        let baseResponse = try decoder.decode(BaseResponse.self, from: json)
                        completion(baseResponse)
                    }catch let err{
                        print(err)
                    }
                }
        }
    }
    
    static func unsubscribeFromPlace(Authorization : String,id: String, completion:@escaping(_ response : BaseResponse)-> Void) {
        
        let headers = [Constants.AUTH_HEADER: "bearer \(Authorization)",
            Constants.LANG_HEADER : self.getLang()]
        
        let all : [String : Any] = ["Id" : id]
        
        AFManager.request("\(Constants.BASE_URL)Shop/UnsubscribeFromPlace", method: .post, parameters: all ,encoding: JSONEncoding.default, headers: headers)
            .responseJSON { response in
                if let json = response.data {
                    do {
                        let decoder = JSONDecoder()
                        let baseResponse = try decoder.decode(BaseResponse.self, from: json)
                        completion(baseResponse)
                    }catch let err{
                        print(err)
                    }
                }
        }
    }
    
    
    static func getChatData(Authorization : String,id : Int, completion:@escaping(_ response : ChatResponse)-> Void) {
        
        let headers = [Constants.AUTH_HEADER: "bearer \(Authorization)",
            Constants.LANG_HEADER : self.getLang()]
        
        AFManager.request("\(Constants.BASE_URL)Chat/Get?id=\(id)", method: .get, parameters: nil ,encoding: JSONEncoding.default, headers: headers)
            .responseJSON { response in
                if let json = response.data {
                    do {
                        let decoder = JSONDecoder()
                        let baseResponse = try decoder.decode(ChatResponse.self, from: json)
                        completion(baseResponse)
                    }catch let err {
                        print(err)
                    }
                }
        }
    }
    
    
    static func sendChatMessage(Authorization : String,chatId: Int,type : Int ,message : String, image : String, voice : String, completion:@escaping(_ response : BaseResponse)-> Void) {
        
        let headers = [Constants.AUTH_HEADER: "bearer \(Authorization)",
            Constants.LANG_HEADER : self.getLang()]
        
        let all : [String : Any] = ["ChatId" : chatId,
                                    "Type"  : type,
                                    "Content" : message,
                                    "Image" : image,
                                    "Voice" : voice]
        
        AFManager.request("\(Constants.BASE_URL)Chat/SendMessage", method: .post, parameters: all ,encoding: JSONEncoding.default, headers: headers)
            .responseJSON { response in
                if let json = response.data {
                    do {
                        let decoder = JSONDecoder()
                        let baseResponse = try decoder.decode(BaseResponse.self, from: json)
                        completion(baseResponse)
                    }catch let err{
                        print(err)
                    }
                }
        }
    }
    
    
    
    static func getPlacesAPI(input : String, latitude : Double, longitude : Double, completion:@escaping(_ response : GooglePlaceResponse)-> Void) {
        
        let headers = ["Content-Type": "application/json"]
       
        let url = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?keyword=\(input)&name=\(input)&location=\(latitude),\(longitude)&rankby=distance&language=en&sensor=false&key=\(Constants.GOOGLE_API_KEY)"
        
        let encodedUrl = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? url
        
        AFManager.request(encodedUrl, method: .get, parameters: nil ,encoding: JSONEncoding.default, headers: headers)
            .responseJSON { response in
                if let json = response.data {
                    do {
                        let decoder = JSONDecoder()
                        let baseResponse = try decoder.decode(GooglePlaceResponse.self, from: json)
                        completion(baseResponse)
                    }catch let err{
                        print(err)
                    }
                }
        }
    }
    
    
    static func getPlaceDetails(placeid : String, completion:@escaping(_ response : GooglePlaceDetailsResponse)-> Void) {
        
        let headers = ["Content-Type": "application/json"]
        
        let url = "https://maps.googleapis.com/maps/api/place/details/json?placeid=\(placeid)&fields=opening_hours&language=\(self.getLang())&key=\(Constants.GOOGLE_API_KEY)"
        
        let encodedUrl = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? url
        
        AFManager.request(encodedUrl, method: .get, parameters: nil ,encoding: JSONEncoding.default, headers: headers)
            .responseJSON { response in
                if let json = response.data {
                    do {
                        let decoder = JSONDecoder()
                        let baseResponse = try decoder.decode(GooglePlaceDetailsResponse.self, from: json)
                        completion(baseResponse)
                    }catch let err {
                        print(err)
                    }
                }
        }
    }
    
    
    static func redeemCoupon(Authorization : String, code: String, completion:@escaping(_ response : BaseResponse)-> Void) {
        
        let headers = [Constants.AUTH_HEADER: "bearer \(Authorization)",
            Constants.LANG_HEADER : self.getLang()]
        
        AFManager.request("\(Constants.BASE_URL)Coupon/Redeem?code=\(code)", method: .get, parameters: nil ,encoding: JSONEncoding.default, headers: headers)
            .responseJSON { response in
                if let json = response.data {
                    do {
                        let decoder = JSONDecoder()
                        let baseResponse = try decoder.decode(BaseResponse.self, from: json)
                        completion(baseResponse)
                    }catch let err{
                        print(err)
                    }
                }
        }
    }
    
    
    
}
