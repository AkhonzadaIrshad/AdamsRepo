//
//  App.swift
//  rzq
//
//  Created by Zaid najjar on 4/7/19.
//  Copyright © 2019 technzone. All rights reserved.
//

import Foundation
import CoreFoundation

class App: NSObject {
    
    var tabOpen : String?
    var config : ConfigData?
    var notificationType : String?
    var notificationValue : String?
    var deepLinkShopId : String?
    // MARK:- Singleton
    static var shared : App = {
        let instance = App()
        return instance
    }()
    
    
}
