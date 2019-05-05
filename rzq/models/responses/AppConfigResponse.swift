//
//  AppConfigResponse.swift
//  rzq
//
//  Created by Zaid najjar on 4/17/19.
//  Copyright © 2019 technzone. All rights reserved.
//

import Foundation

class AppConfigResponse: Codable {
    let configData: ConfigData?
    let errorCode: Int?
    let errorMessage: String?
    
    enum CodingKeys: String, CodingKey {
        case configData = "Data"
        case errorCode = "ErrorCode"
        case errorMessage = "ErrorMessage"
    }
    
    init(configData: ConfigData?, errorCode: Int?, errorMessage: String?) {
        self.configData = configData
        self.errorCode = errorCode
        self.errorMessage = errorMessage
    }
}

class ConfigData: Codable {
    let description: String?
    let updateStatus: UpdateStatus?
    let developer, company: Company?
    let configString: ConfigString?
    let configSettings: ConfigSettings?
    let flag: Bool?
    let id: Int?
    
    enum CodingKeys: String, CodingKey {
        case description = "Description"
        case updateStatus = "UpdateStatus"
        case developer = "Developer"
        case company = "Company"
        case configString = "ConfigString"
        case configSettings = "ConfigSettings"
        case flag = "Flag"
        case id = "Id"
    }
    
    init(description: String?, updateStatus: UpdateStatus?, developer: Company?, company: Company?, configString: ConfigString?, configSettings: ConfigSettings?, flag: Bool?, id: Int?) {
        self.description = description
        self.updateStatus = updateStatus
        self.developer = developer
        self.company = company
        self.configString = configString
        self.configSettings = configSettings
        self.flag = flag
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

class ConfigSettings: Codable {
    let isMapView: Bool?
    let driversLimit, orderTimeConstraint: Int?
    let radius : Double?
    let MinimumOneKmValue,MinimumFiveKmValue,MaximumValue,IncrementValue : Double?
    
    enum CodingKeys: String, CodingKey {
        case isMapView = "IsMapView"
        case radius = "Radius"
        case driversLimit = "DriversLimit"
        case orderTimeConstraint = "OrderTimeConstraint"
        
        case MinimumOneKmValue = "MinimumOneKmValue"
        case MinimumFiveKmValue = "MinimumFiveKmValue"
        case MaximumValue = "MaximumValue"
        case IncrementValue = "IncrementValue"
    }
    
    init(isMapView: Bool?, radius: Double?, driversLimit: Int?, orderTimeConstraint: Int?,MinimumOneKmValue : Double?,MinimumFiveKmValue : Double?, MaximumValue : Double?, IncrementValue : Double?) {
        self.isMapView = isMapView
        self.radius = radius
        self.driversLimit = driversLimit
        self.orderTimeConstraint = orderTimeConstraint
        
        self.MinimumOneKmValue = MinimumOneKmValue
        self.MinimumFiveKmValue = MinimumFiveKmValue
        self.MaximumValue = MaximumValue
        self.IncrementValue = IncrementValue
    }
}

class ConfigString: Codable {
    let arabicTermsAndConditions, englishTermsAndConditions, arabicPrivacyPolicy, englishPrivacyPolicy: String?
    let arabicNewVersionText, englishNewVersionText, arabicTellAFriend, englishTellAFriend: String?
    let arabicDisclamier, englishDisclamier, help: String?
    let showDisclaimer: Bool?
    
    enum CodingKeys: String, CodingKey {
        case arabicTermsAndConditions = "ArabicTermsAndConditions"
        case englishTermsAndConditions = "EnglishTermsAndConditions"
        case arabicPrivacyPolicy = "ArabicPrivacyPolicy"
        case englishPrivacyPolicy = "EnglishPrivacyPolicy"
        case arabicNewVersionText = "ArabicNewVersionText"
        case englishNewVersionText = "EnglishNewVersionText"
        case arabicTellAFriend = "ArabicTellAFriend"
        case englishTellAFriend = "EnglishTellAFriend"
        case arabicDisclamier = "ArabicDisclamier"
        case englishDisclamier = "EnglishDisclamier"
        case help = "Help"
        case showDisclaimer = "ShowDisclaimer"
    }
    
    init(arabicTermsAndConditions: String?, englishTermsAndConditions: String?, arabicPrivacyPolicy: String?, englishPrivacyPolicy: String?, arabicNewVersionText: String?, englishNewVersionText: String?, arabicTellAFriend: String?, englishTellAFriend: String?, arabicDisclamier: String?, englishDisclamier: String?, help: String?, showDisclaimer: Bool?) {
        self.arabicTermsAndConditions = arabicTermsAndConditions
        self.englishTermsAndConditions = englishTermsAndConditions
        self.arabicPrivacyPolicy = arabicPrivacyPolicy
        self.englishPrivacyPolicy = englishPrivacyPolicy
        self.arabicNewVersionText = arabicNewVersionText
        self.englishNewVersionText = englishNewVersionText
        self.arabicTellAFriend = arabicTellAFriend
        self.englishTellAFriend = englishTellAFriend
        self.arabicDisclamier = arabicDisclamier
        self.englishDisclamier = englishDisclamier
        self.help = help
        self.showDisclaimer = showDisclaimer
    }
}

class UpdateStatus: Codable {
    let status: Bool?
    let appURL, version: String?
    let isMandatory: Bool?
    let arabicDescription, englishDescription: String?
    
    enum CodingKeys: String, CodingKey {
        case status = "Status"
        case appURL = "AppUrl"
        case version = "Version"
        case isMandatory = "IsMandatory"
        case arabicDescription = "ArabicDescription"
        case englishDescription = "EnglishDescription"
    }
    
    init(status: Bool?, appURL: String?, version: String?, isMandatory: Bool?, arabicDescription: String?, englishDescription: String?) {
        self.status = status
        self.appURL = appURL
        self.version = version
        self.isMandatory = isMandatory
        self.arabicDescription = arabicDescription
        self.englishDescription = englishDescription
    }
}
