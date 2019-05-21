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
    
    static var IMAGE_URL = "http://35.192.208.228/RZQ/api/file/get?name="
    
    static var AUTH_HEADER = "Authorization"
    static var LANG_HEADER = "Accept-Language"
   // static var BASE_URL = "http://35.192.208.228/RZQ/api/"
    static var BASE_URL = "http://35.192.208.228/RZQ2/api/"
    
    static var DEFAULT_RADIUS = 20000.0
    
    static var ORDER_NUMBER_PREFIX = "RZQ_"
    
    static var NOTIFICATION_COUNT = "KEY_NOTIFICATION_COUNT"
    
    static var IS_NOTIFICATION_ACTIVE = "IS_NOTIFICATION_ACTIVE"
    static var DID_SEE_INTRO = "DID_SEE_INTRO"
    static var DID_CHOOSE_LANGUAGE = "DID_CHOOSE_LANGUAGE"
    
    
    static let INSTAGRAM_ACC = "rzqapp"
    static let FACEBOOK_URL = "https://www.facebook.com/rzqapp"
    static let FACEBOOK_PAGE_ID = "123456"
    static let TWITTER_URL = "twitter://user?screen_name=rzqapp"
    static let TWITTER_URL_ALT = "https://twitter.com/rzqapp"
    
    static let GOOGLE_API_KEY = "AIzaSyDtBOSpJ-Afpa7yvzkyuVEGfVxuxpam4JE"
    
    
    static var DELIVERY_CREATED = 1
    static var DELIVERY_CANCELLED = 2
    static var BID_CREATED = 3
    static var ON_THE_WAY = 4
    static var DELIVERY_COMPLETED = 5
    static var BID_ACCEPTED = 6
    static var NEW_MESSAGE = 11
    
   
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
