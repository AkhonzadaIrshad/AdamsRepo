//
//  ZHUserModel.swift
//  ZHChatSwift
//
//  Created by aimoke on 16/12/15.
//  Copyright © 2016年 zhuo. All rights reserved.
//

import UIKit
import Foundation

class ZHUserModel: NSObject {
    var id : Int?
    var content: String?
    var type : Int?
    var image: String?
    var voice: String?
    var userId : String?
    var userName : String?
    var userImage : String?
    var createDate : String?
    var identifier : String?
    
    
    func initialDataWithDictionary(dic: NSDictionary) -> Void {
        self.id = dic.object(forKey: "Id") as! Int?
        self.content = dic.object(forKey: "Content")as! String?
        self.type = dic.object(forKey: "Type")as! Int?
        self.image = dic.object(forKey: "Image") as! String?
        self.voice = dic.object(forKey: "Voice") as! String?
        self.userId = dic.object(forKey: "UserId") as! String?
        self.userName = dic.object(forKey: "UserName") as! String?
        self.userImage = dic.object(forKey: "UserImage") as! String?
        self.createDate = dic.object(forKey: "CreateDate") as! String?
        self.identifier = uniqueIdentifier()
    }
    
    func uniqueIdentifier() -> String {
        let counter = 0;
        let identifier: String;
        identifier = NSString.localizedStringWithFormat("unique-id-%d", counter) as String;
        return identifier;
    }

}

