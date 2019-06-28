//
//  RealmUser.swift
//  rzq
//
//  Created by Zaid najjar on 4/9/19.
//  Copyright © 2019 technzone. All rights reserved.
//

import Foundation
import RealmSwift

class RealmUser : Object {
    @objc dynamic var userId = ""
    @objc dynamic var access_token = ""
    @objc dynamic var token_type = ""
    @objc dynamic var expires_in = 0
    @objc dynamic var user_name = ""
    @objc dynamic var full_name = ""
    @objc dynamic var date_of_birth = ""
    @objc dynamic var profile_picture = ""
    @objc dynamic var email = ""
    @objc dynamic var gender = 0
    @objc dynamic var phone_number = ""
    @objc dynamic var rate = 0.0
    @objc dynamic var roles = ""
    @objc dynamic var isOnline = false
    @objc dynamic var exceeded_amount = false
    @objc dynamic var dueAmount = 0.0
    @objc dynamic var earnings = 0.0
    
    override static func primaryKey() -> String? {
        return "userId"
    }
    
}
