//
//  DataManager.swift
//  rzq
//
//  Created by Safoine Moncef Amine on 5/31/20.
//  Copyright © 2020 technzone. All rights reserved.
//

import Foundation
import RealmSwift

struct DataManager {
    static func loadUser() -> VerifyResponse{
        let realm = try! Realm()
        let realmUser = Array(realm.objects(RealmUser.self))
        if (realmUser.count > 0) {
            return self.getUser(realmUser: realmUser[0])
        }else {
            return VerifyResponse(data: DataClass(accessToken: "", phoneNumber: "", username: "", fullName: "", userID: "", dateOfBirth: "", profilePicture: "", email: "", gender: 1, rate: 0, roles: "", isOnline: false,exceededDueAmount: false, dueAmount: 0.0, earnings: 0.0, balance: 0.0), errorCode: 0, errorMessage: "")
        }
    }
    
    static private func getUser(realmUser: RealmUser) -> VerifyResponse {
        let userData = DataClass(accessToken: realmUser.access_token, phoneNumber: realmUser.phone_number, username: realmUser.user_name, fullName: realmUser.full_name, userID: realmUser.userId, dateOfBirth: realmUser.date_of_birth, profilePicture: realmUser.profile_picture, email: realmUser.email, gender: realmUser.gender, rate: realmUser.rate, roles: realmUser.roles, isOnline: realmUser.isOnline,exceededDueAmount: realmUser.exceeded_amount, dueAmount: realmUser.dueAmount, earnings: realmUser.earnings, balance: realmUser.balance)
        let verifyResponse = VerifyResponse(data: userData, errorCode: 0, errorMessage: "")
        
        return verifyResponse
    }
}
