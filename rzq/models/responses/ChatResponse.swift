//
//  ChatResponse.swift
//  rzq
//
//  Created by Zaid najjar on 4/24/19.
//  Copyright © 2019 technzone. All rights reserved.
//

import Foundation

class ChatResponse: Codable {
    let chatData: ChatData?
    let errorCode: Int?
    let errorMessage: String?
    
    enum CodingKeys: String, CodingKey {
        case chatData = "Data"
        case errorCode = "ErrorCode"
        case errorMessage = "ErrorMessage"
    }
    
    init(chatData: ChatData?, errorCode: Int?, errorMessage: String?) {
        self.chatData = chatData
        self.errorCode = errorCode
        self.errorMessage = errorMessage
    }
}

class ChatData: Codable {
    let id: Int?
    let messages: [Message]?
    
    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case messages = "Messages"
    }
    
    init(id: Int?, messages: [Message]?) {
        self.id = id
        self.messages = messages
    }
}

class Message: Codable {
    let id: Int?
    let content: String?
    let type: Int?
    let image, voice, userID, userName: String?
    let userImage, createdDate: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case content = "Content"
        case type = "Type"
        case image = "Image"
        case voice = "Voice"
        case userID = "UserId"
        case userName = "UserName"
        case userImage = "UserImage"
        case createdDate = "CreatedDate"
    }
    
    init(id: Int?, content: String?, type: Int?, image: String?, voice: String?, userID: String?, userName: String?, userImage: String?, createdDate: String?) {
        self.id = id
        self.content = content
        self.type = type
        self.image = image
        self.voice = voice
        self.userID = userID
        self.userName = userName
        self.userImage = userImage
        self.createdDate = createdDate
    }
}
