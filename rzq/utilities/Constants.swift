//
//  Constants.swift
//  rzq
//
//  Created by Zaid najjar on 3/31/19.
//  Copyright © 2019 technzone. All rights reserved.
//

import Foundation
class Constants {
    static var ENGLISH_FONT_LIGHT = "Dosis-Light"
    static var ENGLISH_FONT_REGULAR = "Dosis-Regular"
    static var ENGLISH_FONT_MEDIUM = "Dosis-Medium"
    static var ENGLISH_FONT_SEMIBOLD = "Dosis-SemiBold"
    static var ENGLISH_FONT_BOLD = "Dosis-Bold"
    
    static var ARABIC_FONT_LIGHT = "Tajawal-Light"
    static var ARABIC_FONT_REGULAR = "Tajawal-Regular"
    static var ARABIC_FONT_MEDIUM = "Tajawal-Medium"
    static var ARABIC_FONT_SEMIBOLD = "Tajawal-Medium"
    static var ARABIC_FONT_BOLD = "Tajawal-Bold"
    
    static var AUTH_HEADER = "Authorization"
    static var LANG_HEADER = "Accept-Language"
    
    
    static var BASE_URL = "http://rzq.rzqapp.com/api/"
    static var IMAGE_URL = "http://rzq.rzqapp.com/api/file/get?name="
    
    
    //    static var BASE_URL = "https://c93fdc01.ngrok.io/api/"
    //    static var IMAGE_URL = "https://c93fdc01.ngrok.io/api/file/get?name="
    
    
    static var PAYMENT_SUCCESS_URL = "success.html"
    static var PAYMENT_FAIL_URL = "failed.html"
    
    static var MENU_ITEM_UNLOCKED = 1
    static var MENU_ITEM_LOCKED = 2
    
    
    static let PAYMENT_METHOD_CASH = 1
    static let PAYMENT_METHOD_BALANCE = 2
    static let PAYMENT_METHOD_KNET = 3
    
    
    static let TRACK_TIMER = 180
    static let TRACK_TIMER_DOUBLE = 180.0
    
    
    //live
    static var PAYMENT_URL = "https://apitest.myfatoorah.com/v2/"
    static var PAYMENT_TOKEN = "cxu2LdP0p0j5BGna0velN9DmzKJTrx3Ftc0ptV8FmvOgoDqvXivkxZ_oqbi_XM9k7jgl3SUriQyRE2uaLWdRumxDLKTn1iNglbQLrZyOkmkD6cjtpAsk1_ctrea_MeOQCMavsQEJ4EZHnP4HoRDOTVRGvYQueYZZvVjsaOLOubLkdovx6STu9imI1zf5OvuC9rB8p0PNIR90rQ0-ILLYbaDZBoQANGND10HdF7zM4qnYFF1wfZ_HgQipC5A7jdrzOoIoFBTCyMz4ZuPPPyXtb30IfNp47LucQKUfF1ySU7Wy_df0O73LVnyV8mpkzzonCJHSYPaum9HzbvY5pvCZxPYw39WGo8pOMPUgEugtaqepILwtGKbIJR3_T5Iimm_oyOoOJFOtTukb_-jGMTLMZWB3vpRI3C08itm7ealISVZb7M3OMPPXgcss9_gFvwYND0Q3zJRPmDASg5NxRlEDHWRnlwNKqcd6nW4JJddffaX8p-ezWB8qAlimoKTTBJCe5CnjT4vNjnWlJWscvk38VNIIslv4gYpC09OLWn4rDNeoUaGXi5kONdEQ0vQcRjENOPAavP7HXtW1-Vz83jMlU3lDOoZsdEKZReNYpvdFrGJ5c3aJB18eLiPX6mI4zxjHCZH25ixDCHzo-nmgs_VTrOL7Zz6K7w6fuu_eBK9P0BDr2fpS"
    //
    
    static var DEFAULT_RADIUS = 20000.0
    
    static var ORDER_NUMBER_PREFIX = "RZQ_"
    
    static var NOTIFICATION_COUNT = "KEY_NOTIFICATION_COUNT"
    static let WORKING_ORDERS_COUNT = "KEY_WORKING_ORDERS_COUNT"
    static let ORDERS_COUNT = "KEY_ORDERS_COUNT"
    
    static var NOTIFICATION_CHAT_COUNT = "NOTIFICATION_CHAT_COUNT"
    
    static var BID_ACCEPTED_ORDER = "BID_ACCEPTED_ORDER"
    
    static var OPEN_MENU = "OPEN_MENU"
    
    static var IS_NOTIFICATION_ACTIVE = "IS_NOTIFICATION_ACTIVE"
    static var DID_SEE_INTRO = "DID_SEE_INTRO"
    static var DID_CHOOSE_LANGUAGE = "DID_CHOOSE_LANGUAGE"
    
    static var LAST_LATITUDE = "lastSelectedLatitude"
    static var LAST_LONGITUDE = "lastSelectedLongitude"
    
    static let INSTAGRAM_ACC = "rzqapp"
    static let FACEBOOK_URL = "https://www.facebook.com/rzqapp"
    static let FACEBOOK_PAGE_ID = "123456"
    static let TWITTER_URL = "twitter://user?screen_name=rzqapp"
    static let TWITTER_URL_ALT = "https://twitter.com/rzqapp"
    
    static let GOOGLE_API_KEY = "AIzaSyDY0pMaR18bji55KFsKX_PTm0AkuvaXpdE"
    
    
    static let SEE_DRIVER_TERMS = "SEE_DRIVER_TERMS"
    
    static var DELIVERY_CREATED = 1
    static var DELIVERY_CANCELLED = 2
    static var BID_CREATED = 3
    static var ON_THE_WAY = 4
    static var DELIVERY_COMPLETED = 5
    static var BID_ACCEPTED = 6
    static var NEW_MESSAGE = 11
    
    static var SERVICE_CREATED = 13
    static var SERVICE_BID_CREATED = 14
    static var SERVICE_BID_ACCEPTED = 15
    static var SERVICE_BID_DECLINED = 16
    static var SERVICE_CANCELLED = 17
    static var SERVICE_ON_THE_WAY = 18
    static var SERVICE_COMPLETED = 19
    
    
    static var PLACE_BAKERY = 1
    static var PLACE_BOOK_STORE = 2
    static var PLACE_CAFE = 4
    static var PLACE_MEAL_DELIVERY = 8
    static var PLACE_MEAL_TAKEAWAY = 16
    static var PLACE_PHARMACY = 32
    static var PLACE_RESTAURANT = 64
    static var PLACE_SHOPPING_MALL = 128
    static var PLACE_STORE = 256
    static var PLACE_SUPERMARKET = 1512
    
    
    static var ORDER_ON_THE_WAY = 3
    static var ORDER_PENDING = 1
    static var ORDER_PROCESSING = 2
    static var ORDER_CANCELLED = 5
    static var ORDER_COMPLETED = 4
    static var ORDER_EXPIRED = 6
    
    
    static func getPlaces() -> Array<ShopType> {
        var places : Array<ShopType> = Array()
        
        var item = ShopType()
        item.id = Constants.PLACE_RESTAURANT
        item.name = "restaurant".localized
        // item.icChecked = true
        places.append(item)
        
        item = ShopType()
        item.id = Constants.PLACE_BAKERY
        item.name = "bakery".localized
        places.append(item)
        
        item = ShopType()
        item.id = Constants.PLACE_BOOK_STORE
        item.name = "book_store".localized
        places.append(item)
        
        item = ShopType()
        item.id = Constants.PLACE_CAFE
        item.name = "cafe".localized
        places.append(item)
        
        item = ShopType()
        item.id = Constants.PLACE_MEAL_DELIVERY
        item.name = "meal_delivery".localized
        places.append(item)
        
        item = ShopType()
        item.id = Constants.PLACE_MEAL_TAKEAWAY
        item.name = "meal_takeaway".localized
        places.append(item)
        
        item = ShopType()
        item.id = Constants.PLACE_PHARMACY
        item.name = "pharmacy".localized
        places.append(item)
        
        
        item = ShopType()
        item.id = Constants.PLACE_SHOPPING_MALL
        item.name = "shopping_mall".localized
        places.append(item)
        
        item = ShopType()
        item.id = Constants.PLACE_STORE
        item.name = "store".localized
        places.append(item)
        
        item = ShopType()
        item.id = Constants.PLACE_SUPERMARKET
        item.name = "super_market".localized
        places.append(item)
        
        return places
    }
    
    static func getHoursStr() -> Array<String> {
        var hours : Array<String> = Array()
        
        var item = "01:00"
        hours.append(item)
        item = "02:00"
        hours.append(item)
        item = "03:00"
        hours.append(item)
        item = "04:00"
        hours.append(item)
        item = "05:00"
        hours.append(item)
        item = "06:00"
        hours.append(item)
        item = "07:00"
        hours.append(item)
        item = "08:00"
        hours.append(item)
        item = "09:00"
        hours.append(item)
        item = "10:00"
        hours.append(item)
        item = "11:00"
        hours.append(item)
        item = "12:00"
        hours.append(item)
        item = "13:00"
        hours.append(item)
        item = "14:00"
        hours.append(item)
        item = "15:00"
        hours.append(item)
        item = "16:00"
        hours.append(item)
        item = "17:00"
        hours.append(item)
        item = "18:00"
        hours.append(item)
        item = "19:00"
        hours.append(item)
        item = "20:00"
        hours.append(item)
        item = "21:00"
        hours.append(item)
        item = "22:00"
        hours.append(item)
        item = "23:00"
        hours.append(item)
        
        return hours
    }
    
    static func getHours() -> Array<HourItem> {
        var hours : Array<HourItem> = Array()
        
        var item = HourItem()
        item.id = 1
        item.name = "monday".localized
        item.from = "12:00"
        item.to = "18:00"
        hours.append(item)
        
        item = HourItem()
        item.id = 2
        item.name = "tuesday".localized
        item.from = "12:00"
        item.to = "18:00"
        hours.append(item)
        
        item = HourItem()
        item.id = 3
        item.name = "wednesday".localized
        item.from = "12:00"
        item.to = "18:00"
        hours.append(item)
        
        item = HourItem()
        item.id = 4
        item.name = "thursday".localized
        item.from = "12:00"
        item.to = "18:00"
        hours.append(item)
        
        item = HourItem()
        item.id = 5
        item.name = "friday".localized
        item.from = "12:00"
        item.to = "18:00"
        hours.append(item)
        
        item = HourItem()
        item.id = 6
        item.name = "saturday".localized
        item.from = "12:00"
        item.to = "18:00"
        hours.append(item)
        
        item = HourItem()
        item.id = 7
        item.name = "sunday".localized
        item.from = "12:00"
        item.to = "18:00"
        hours.append(item)
        
        return hours
    }
    
}
