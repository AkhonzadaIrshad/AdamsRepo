//
//  AppConfigResponse.swift
//  rzq
//
//  Created by Zaid najjar on 4/17/19.
//  Copyright © 2019 technzone. All rights reserved.
//

import Foundation

// MARK: - AppConfigResponse
class AppConfigResponse: Codable {
    let data: ConfigData?
    let errorCode: Int?
    let errorMessage: String?
    
    enum CodingKeys: String, CodingKey {
        case data = "Data"
        case errorCode = "ErrorCode"
        case errorMessage = "ErrorMessage"
    }
    
    init(data: ConfigData?, errorCode: Int?, errorMessage: String?) {
        self.data = data
        self.errorCode = errorCode
        self.errorMessage = errorMessage
    }
}

// MARK: - DataClass
class ConfigData: Codable {
    let updateStatus: UpdateStatus?
    let developer, company: Company?
    let configString: ConfigString?
    let configSettings: ConfigSettings?
    let id: Int?
    
    
    enum CodingKeys: String, CodingKey {
        case updateStatus = "UpdateStatus"
        case developer = "Developer"
        case company = "Company"
        case configString = "ConfigString"
        case configSettings = "ConfigSettings"
        case id = "Id"
    }
    
    init(updateStatus: UpdateStatus?, developer: Company?, company: Company?, configString: ConfigString?, configSettings: ConfigSettings?, id: Int?) {
        self.updateStatus = updateStatus
        self.developer = developer
        self.company = company
        self.configString = configString
        self.configSettings = configSettings
        self.id = id
    }
}

class Company: Codable {
    let name, logo, arabicDescription, englishDescription: String?
    let facebook, twitter, instagram, email: String?
    let website, phone: String?
    
    enum CodingKeys: String, CodingKey {
        case name = "Name"
        case logo = "Logo"
        case arabicDescription = "ArabicDescription"
        case englishDescription = "EnglishDescription"
        case facebook = "Facebook"
        case twitter = "Twitter"
        case instagram = "Instagram"
        case email = "Email"
        case website = "Website"
        case phone = "Phone"
    }
    
    init(name: String?, logo: String?, arabicDescription: String?, englishDescription: String?, facebook: String?, twitter: String?, instagram: String?, email: String?, website: String?, phone: String?) {
        self.name = name
        self.logo = logo
        self.arabicDescription = arabicDescription
        self.englishDescription = englishDescription
        self.facebook = facebook
        self.twitter = twitter
        self.instagram = instagram
        self.email = email
        self.website = website
        self.phone = phone
    }
}

// MARK: - ConfigSettings
class ConfigSettings: Codable {
    let flag: Bool?
    let percentage, dueAmountLimit, showNotificationPeriod: Double?
    let isMapView: Bool?
    let radius, driversLimit, orderTimeConstraint, minimumOneKMValue: Double?
    let minimumFiveKMValue, maximumValue, incrementValue, shopLimit: Double?
    let KnetCommission: Double?
    
    enum CodingKeys: String, CodingKey {
        case flag = "Flag"
        case percentage = "Percentage"
        case dueAmountLimit = "DueAmountLimit"
        case showNotificationPeriod = "ShowNotificationPeriod"
        case isMapView = "IsMapView"
        case radius = "Radius"
        case driversLimit = "DriversLimit"
        case orderTimeConstraint = "OrderTimeConstraint"
        case minimumOneKMValue = "MinimumOneKmValue"
        case minimumFiveKMValue = "MinimumFiveKmValue"
        case maximumValue = "MaximumValue"
        case incrementValue = "IncrementValue"
        case shopLimit = "ShopLimit"
        case KnetCommission = "KnetCommission"
    }
    
    init(flag: Bool?, percentage: Double?, dueAmountLimit: Double?, showNotificationPeriod: Double?, isMapView: Bool?, radius: Double?, driversLimit: Double?, orderTimeConstraint: Double?, minimumOneKMValue: Double?, minimumFiveKMValue: Double?, maximumValue: Double?, incrementValue: Double?, shopLimit: Double?, KnetCommission: Double?) {
        self.flag = flag
        self.percentage = percentage
        self.dueAmountLimit = dueAmountLimit
        self.showNotificationPeriod = showNotificationPeriod
        self.isMapView = isMapView
        self.radius = radius
        self.driversLimit = driversLimit
        self.orderTimeConstraint = orderTimeConstraint
        self.minimumOneKMValue = minimumOneKMValue
        self.minimumFiveKMValue = minimumFiveKMValue
        self.maximumValue = maximumValue
        self.incrementValue = incrementValue
        self.shopLimit = shopLimit
        self.KnetCommission = KnetCommission
    }
}

// MARK: - ConfigString
class ConfigString: Codable {
    let arabicTermsAndConditions, englishTermsAndConditions, arabicPrivacyPolicy, englishPrivacyPolicy: String?
    let arabicNewVersionText, englishNewVersionText, arabicTellAFriend, englishTellAFriend: String?
    
    enum CodingKeys: String, CodingKey {
        case arabicTermsAndConditions = "ArabicTermsAndConditions"
        case englishTermsAndConditions = "EnglishTermsAndConditions"
        case arabicPrivacyPolicy = "ArabicPrivacyPolicy"
        case englishPrivacyPolicy = "EnglishPrivacyPolicy"
        case arabicNewVersionText = "ArabicNewVersionText"
        case englishNewVersionText = "EnglishNewVersionText"
        case arabicTellAFriend = "ArabicTellAFriend"
        case englishTellAFriend = "EnglishTellAFriend"
    }
    
    init(arabicTermsAndConditions: String?, englishTermsAndConditions: String?, arabicPrivacyPolicy: String?, englishPrivacyPolicy: String?, arabicNewVersionText: String?, englishNewVersionText: String?, arabicTellAFriend: String?, englishTellAFriend: String?) {
        self.arabicTermsAndConditions = arabicTermsAndConditions
        self.englishTermsAndConditions = englishTermsAndConditions
        self.arabicPrivacyPolicy = arabicPrivacyPolicy
        self.englishPrivacyPolicy = englishPrivacyPolicy
        self.arabicNewVersionText = arabicNewVersionText
        self.englishNewVersionText = englishNewVersionText
        self.arabicTellAFriend = arabicTellAFriend
        self.englishTellAFriend = englishTellAFriend
    }
}

// MARK: - UpdateStatus
class UpdateStatus: Codable {
    let arabicDescription, englishDescription, appURL, version: String?
    let isMandatory: Bool?
    let iosAppURL, iosVersion: String?
    let iosIsMandatory: Bool?
    
    enum CodingKeys: String, CodingKey {
        case arabicDescription = "ArabicDescription"
        case englishDescription = "EnglishDescription"
        case appURL = "AppUrl"
        case version = "Version"
        case isMandatory = "IsMandatory"
        case iosAppURL = "IOSAppUrl"
        case iosVersion = "IOSVersion"
        case iosIsMandatory = "IOSIsMandatory"
    }
    
    init(arabicDescription: String?, englishDescription: String?, appURL: String?, version: String?, isMandatory: Bool?, iosAppURL: String?, iosVersion: String?, iosIsMandatory: Bool?) {
        self.arabicDescription = arabicDescription
        self.englishDescription = englishDescription
        self.appURL = appURL
        self.version = version
        self.isMandatory = isMandatory
        self.iosAppURL = iosAppURL
        self.iosVersion = iosVersion
        self.iosIsMandatory = iosIsMandatory
    }
}
