//
//  AppDelegate.swift
//  rzq
//
//  Created by Zaid najjar on 3/30/19.
//  Copyright © 2019 technzone. All rights reserved.
//

import UIKit
import MOLH
import IQKeyboardManagerSwift
import GoogleMaps
import GooglePlaces
import Firebase
import FirebaseMessaging
import FirebaseInstanceID
import UserNotifications
import BRYXBanner
import Alamofire
import Branch
import RealmSwift
import Fabric
import Crashlytics
import MFSDK

var AFManager = SessionManager()
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, MOLHResetable,MessagingDelegate ,UNUserNotificationCenterDelegate {
    let gcmMessageIDKey = "gcm.message_id"
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        //maps
        UserDefaults.standard.set(false, forKey: "dispalyMakeOerderButton")

        GoogleApi.shared.initialiseWithKey("AIzaSyDY0pMaR18bji55KFsKX_PTm0AkuvaXpdE")

        GMSServices.provideAPIKey("\(Constants.GOOGLE_API_KEY)")
        GMSPlacesClient.provideAPIKey("\(Constants.GOOGLE_API_KEY)")
        
        MOLH.shared.activate(true)
        
        IQKeyboardManager.shared.enable = true
        
        
        //firebase
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        Messaging.messaging().shouldEstablishDirectChannel = true
        
        if #available(iOS 10.0, *) {
            
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        
        application.registerForRemoteNotifications()
        
        
        //branch
        // Branch.setUseTestBranchKey(true)
        // listener for Branch Deep Link data
        Branch.getInstance().initSession(launchOptions: launchOptions) { (params, error) in
            print(params as? [String: AnyObject] ?? {})
            let shopId = params?["ShopId"] as? String ?? "0"
            App.shared.deepLinkShopId = shopId
        }
        
        
        if let userInfo = launchOptions?[UIApplication.LaunchOptionsKey.remoteNotification] as? [String: AnyObject] {
            // your logic here!
            let type = userInfo["Type"] as? String ?? "0"
            let chatId = userInfo["Id"] as? String ?? "0"
            let deliveryId = userInfo["OrderId"] as? String ?? "0"
            
            App.shared.notificationType = type
            App.shared.notificationValue = chatId
            App.shared.notificationDeliveryId = deliveryId
            
        }
        
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 120 // seconds
        configuration.timeoutIntervalForResource = 120 //seconds
        AFManager = Alamofire.SessionManager(configuration: configuration)
        
        
        var realmConfig = Realm.Configuration(
            schemaVersion: 1,
            migrationBlock: { migration, oldSchemaVersion in
                if oldSchemaVersion < 1 {
                }
        }
        )
        
        Realm.Configuration.defaultConfiguration = realmConfig
        
        Fabric.with([Crashlytics.self])
        
                // set up your MyFatoorah Merchant details
                let directPaymentToken = "HFFwES7ic9EISSbu13KwBCc4CELuqnzHUHarY7PlYz0gmc19mNzw9OWpeHVCsikzrY67gtlYWiUvXGQXCIB4GDUhq8C-FPNq9oS_7MqwL_od_bcBQqPiZa-PTKKRLqqFoSWK0cl5Xid4f1ZB3rTyyeN7yRz1VUX0a21sNeogH6ic-AR0ZBIwtpaqpyOcC8r1NJ2qdDSJTI4lxEWySWSyqSPbiv8KXPDbvnIqFv3Dmo56PFaUzs74IE02uH17WdFIeCNKSWKZ85xD0Li3zal43bIvQqAjfY-k6l4CTmtbnYVPfz9H7cB-25jUPtPcHyr7O7vQLTxc_RshFPQciWKit6SEtHf7302mgk7a9Linf8v7JlySlH6yw3kioT0PgycFYoLyl3eWpDxl732nlgmKk_Se2ExYCr8889AedKZ5LYHQKR8Tsd_DVzwdAoL7Z8_ECOwvbADPx2-V03N4tTAzZbeP5O5KcRfiWvpSB8Ye5QIpX9AeKuUfBuZHEDm7EAu7dGP0j3Ud6puo6JZkgJHo_rqce28QaSiW717ZyxJnpm8aZ9lIr3S4wheQKRp46ZzwWYyZWAyPY0E2KN48tj-Ax2I1Kikq_p6WoRSq-kouEMSp0G5oUEtKuhpy9ipukSMov064ZsJUkMZgNF--3deQnOtJ2MGPw3XG372IF8yr-gPz64DZ"
                
                let baseURL = "https://api.myfatoorah.com"
                MFSettings.shared.configure(token: directPaymentToken, baseURL: baseURL)
                
                // you can change color and title of navigation bar
                let them = MFTheme(navigationTintColor: .white, navigationBarTintColor: .lightGray, navigationTitle: "Payment", cancelButtonTitle: "Cancel")
                MFSettings.shared.setTheme(theme: them)
        
        return true
    }
    
    
    func updateNotificationChatCount() {
        let defaults = UserDefaults.standard
        var notificationCount : Int = defaults.value(forKey: Constants.NOTIFICATION_CHAT_COUNT) as? Int ?? 0
        notificationCount = notificationCount + 1
        defaults.setValue(notificationCount, forKey: Constants.NOTIFICATION_CHAT_COUNT)
    }
    
    func updateNotificationCount() {
        let defaults = UserDefaults.standard
        var notificationCount : Int = defaults.value(forKey: Constants.NOTIFICATION_COUNT) as? Int ?? 0
        notificationCount = notificationCount + 1
        defaults.setValue(notificationCount, forKey: Constants.NOTIFICATION_COUNT)
    }
    
    //branch
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        Branch.getInstance().application(app, open: url, options: options)
        return true
    }
    //branch
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        // handler for Universal Links
        Branch.getInstance().continue(userActivity)
        return true
    }
    
    // Respond to URI scheme links
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        // pass the url to the handle deep link call
        let branchHandled = Branch.getInstance().application(application,
                                                             open: url,
                                                             sourceApplication: sourceApplication,
                                                             annotation: annotation
        )
        if (!branchHandled) {
            // If not handled by Branch, do other deep link routing for the Facebook SDK, Pinterest SDK, etc
        }
        
        // do other deep link routing for the Facebook SDK, Pinterest SDK, etc
        return true
    }
    
    
    
    //notifications
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        var title = ""
        var body = ""
        var type = ""
        var itemId = ""
        var deliveryId = ""
        
        if MOLHLanguage.isRTLLanguage() {
            title = remoteMessage.appData[AnyHashable("ArabicTitle")] as? String ?? ""
            body = remoteMessage.appData[AnyHashable("ArabicBody")] as? String ?? ""
        } else {
            title = remoteMessage.appData[AnyHashable("EnglishTitle")] as? String ?? ""
            body = remoteMessage.appData[AnyHashable("EnglishBody")] as? String ?? ""
        }
        type = remoteMessage.appData[AnyHashable("Type")] as? String ?? "0"
        itemId = remoteMessage.appData[AnyHashable("Id")] as? String ?? "0"
        deliveryId = remoteMessage.appData[AnyHashable("OrderId")] as? String ?? "0"
        
        App.shared.notificationType = type
        App.shared.notificationValue = itemId
        App.shared.notificationDeliveryId = deliveryId
        
        scheduleNotifications(title: title , message: body, type : type, itemId: itemId)
        
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let application = UIApplication.shared
        
        if(application.applicationState == .active) {
            print("user tapped the notification bar when the app is in foreground")
            let type = response.notification.request.content.userInfo["Type"] as? String ?? "0"
            let itemId = response.notification.request.content.userInfo["Id"] as? String ?? "0"
            let deliveryId = response.notification.request.content.userInfo["OrderId"] as? String ?? "0"
            App.shared.notificationType = type
            App.shared.notificationValue = itemId
            App.shared.notificationDeliveryId = deliveryId
            
            
        }
        
        if(application.applicationState == .inactive)
        {
            print("user tapped the notification bar when the app is in background")
            let type = response.notification.request.content.userInfo["Type"] as? String ?? "0"
            let itemId = response.notification.request.content.userInfo["Id"] as? String ?? "0"
            let deliveryId = response.notification.request.content.userInfo["OrderId"] as? String ?? "0"
            
            App.shared.notificationType = type
            App.shared.notificationValue = itemId
            App.shared.notificationDeliveryId = deliveryId
            
            
        }
        
        /* Change root view controller to a specific viewcontroller */
        // let storyboard = UIStoryboard(name: "Main", bundle: nil)
        // let vc = storyboard.instantiateViewController(withIdentifier: "ViewControllerStoryboardID") as? ViewController
        // self.window?.rootViewController = vc
        
        completionHandler()
    }
    
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        // Print message ID.
        
        Branch.getInstance().handlePushNotification(userInfo)
        
        
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        //  LabasNotificationsManager.shared.addNotification(userInfo: userInfo)
        
        
        var title = ""
        var body = ""
        var type = ""
        var ItemId = ""
        var deliveryId = ""
        
        if MOLHLanguage.isRTLLanguage() {
            title = userInfo["ArabicTitle"] as? String ?? ""
            body = userInfo["ArabicBody"] as? String ?? ""
        } else {
            title = userInfo["EnglishTitle"] as? String ?? ""
            body = userInfo["EnglishBody"] as? String ?? ""
        }
        type = userInfo["Type"] as? String ?? "0"
        ItemId = userInfo["Id"] as? String ?? "0"
        deliveryId = userInfo["OrderId"] as? String ?? "0"
        
        
        App.shared.notificationType = type
        App.shared.notificationValue = ItemId
        App.shared.notificationDeliveryId = deliveryId
        
        
        
        scheduleNotifications(title: title , message: body, type : type, itemId: ItemId)
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
    }
    
    func SBName() -> String{
        if (MOLHLanguage.currentAppleLanguage() == "ar") {
            return "MainAr"
        }else {
            return "Main"
        }
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        var title = ""
        var body = ""
        var type = ""
        var itemId = ""
        var deliveryId = ""
        
        let whole : [AnyHashable: Any] = userInfo["aps"] as! [AnyHashable : Any]
        let data : [AnyHashable: Any] = whole["alert"] as! [AnyHashable : Any]
        
        let notificationType = userInfo["Type"] as? String ?? ""
        if (notificationType == "5") {
            self.rateDriver()
            self.closeOrderDetails()
        }else if (notificationType == "2") {
            self.closeChat()
            self.closeOrderDetails()
        }
        else if (notificationType == "4") {
            self.removeCancelFromChat()
        }
        
        if MOLHLanguage.currentAppleLanguage() == "ar" {
            title = userInfo["ArabicTitle"] as? String ?? ""
            body = userInfo["ArabicBody"] as? String ?? ""
        } else {
            title = userInfo["EnglishTitle"] as? String ?? ""
            body = userInfo["EnglishBody"] as? String ?? ""
        }
        
        type = data["Type"] as? String ?? "0"
        itemId = data["Id"] as? String ?? "0"
        deliveryId = data["OrderId"] as? String ?? "0"
        
        
        App.shared.notificationType = type
        App.shared.notificationValue = itemId
        App.shared.notificationDeliveryId = deliveryId
        
        let state: UIApplication.State = UIApplication.shared.applicationState // or use  let state =  UIApplication.sharedApplication().applicationState
        
        if state == .background {
            scheduleNotifications(title: title , message: body,type: type,itemId: itemId)
        } else if state == .active {
            self.updateChat()
            self.updateNotifications()
            if (notificationType == "3" || notificationType == "14") {
                self.goToNotifications()
            }
            if (notificationType == "4" || notificationType == "18" || notificationType == "2") {
                self.loadTracks()
            }
            if (notificationType == "5" || notificationType == "19" || notificationType == "17") {
                self.loadTracks()
            }
            if (notificationType == "5") {
                self.rateDriver()
            }
            if (notificationType == "6" || notificationType == "15") {
                let orderIdStr = userInfo["OrderId"] as? String ?? "0"
                UserDefaults.standard.setValue(Int(orderIdStr), forKey: Constants.BID_ACCEPTED_ORDER)
                self.openWorkingOrders()
            }
            
            self.showBanner(title: title, message: body, style: UIColor.colorPrimary)
            
            
            if (notificationType == "11") {
                self.updateNotificationChatCount()
                self.loadTracks()
            }else {
                self.updateNotificationCount()
            }
            
            if (notificationType == "901") {
                self.reloadOrderPaymentMethod(method: 1)
            }
            if (notificationType == "902") {
                self.reloadOrderPaymentMethod(method: 3)
            }
            
        }
        
        // Print full message.
        print(userInfo)
        
        completionHandler(UIBackgroundFetchResult.newData)
    }
    
    func showBanner(title:String, message:String,style: UIColor) {
        
        let banner = Banner(title: title, subtitle: message, image: nil, backgroundColor: style)
        banner.dismissesOnTap = true
        banner.textColor = UIColor.white
        banner.titleLabel.font = UIFont(name: getFontName(), size: 16)
        banner.detailLabel.font = UIFont(name: getFontName(), size: 14)
        banner.show(duration: 2.0)
    }
    
    func getFontName() -> String {
        if (MOLHLanguage.currentAppleLanguage() == "ar") {
            return Constants.ARABIC_FONT_REGULAR
        }else {
            return Constants.ENGLISH_FONT_REGULAR
        }
    }
    
    func scheduleNotifications(title : String, message : String, type : String, itemId : String) {
        
        
        if (type == "11") {
            self.updateNotificationChatCount()
        }else {
            self.updateNotificationCount()
        }
        
        let requestIdentifier = "Notification"
        //   if #available(iOS 10.0, *) {
        let content = UNMutableNotificationContent()
        
        content.badge = 1
        content.title = title
        content.subtitle = "appname".localized
        content.body = message
        content.categoryIdentifier = "actionCategory"
        content.sound = UNNotificationSound.default
        
        self.updateChat()
        
        let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: 3.0, repeats: false)
        let request = UNNotificationRequest(identifier: requestIdentifier, content: content, trigger: trigger)
        
        let notificationFlag = UserDefaults.standard.value(forKey: Constants.IS_NOTIFICATION_ACTIVE) as? Bool ?? true
        if (notificationFlag) {
            UNUserNotificationCenter.current().add(request) { (error:Error?) in
                
                if error != nil {
                    print(error?.localizedDescription ?? "not localized")
                }
                print("Notification Register Success")
            }
        }
        
        //  } else {
        // Fallback on earlier versions
        //            let content = UILocalNotification()
        //
        //            content.alertTitle = title
        //            content.alertBody = message
        //            content.category = ""
        
        //   }
        
    }
    
    func getHomeView() -> String {
        if (App.shared.config?.configSettings?.isMapView ?? true) {
            return "MapNavigationController"
        }else {
            //  return "HomeListVC"
            return "MapNavigationController"
        }
    }
    
    
    func updateChat() {
        App.shared.notificationValue = "0"
        App.shared.notificationType = "0"
        App.shared.notificationDeliveryId = "0"
        if let rootViewController = UIApplication.topViewController() {
            if rootViewController is ZHCDemoMessagesViewController {
                let vc = rootViewController as! ZHCDemoMessagesViewController
                vc.getChatMessages()
                vc.getNewOrderData()
            }
        }
    }
    
    
    func reloadOrderPaymentMethod(method : Int) {
        App.shared.notificationValue = "0"
        App.shared.notificationType = "0"
        App.shared.notificationDeliveryId = "0"
        if let rootViewController = UIApplication.topViewController() {
            if rootViewController is ZHCDemoMessagesViewController {
                let vc = rootViewController as! ZHCDemoMessagesViewController
                vc.changeOrderPaymentMethod(method: method)
            }
        }
    }
    
    func closeChat() {
        App.shared.notificationValue = "0"
        App.shared.notificationType = "0"
        App.shared.notificationDeliveryId = "0"
        if let rootViewController = UIApplication.topViewController() {
            if rootViewController is ZHCDemoMessagesViewController {
                let vc = rootViewController as! ZHCDemoMessagesViewController
                vc.closeChat()
            }
        }
    }
    
    func closeOrderDetails() {
          App.shared.notificationValue = "0"
          App.shared.notificationType = "0"
          App.shared.notificationDeliveryId = "0"
          if let rootViewController = UIApplication.topViewController() {
              if rootViewController is OrderDetailsVC {
                  let vc = rootViewController as! OrderDetailsVC
                  vc.closeFromNotification()
              }
          }
      }
    
    
    func rateDriver() {
        App.shared.notificationValue = "0"
        App.shared.notificationType = "0"
        App.shared.notificationDeliveryId = "0"
        if let rootViewController = UIApplication.topViewController() {
            if rootViewController is ZHCDemoMessagesViewController {
                let vc = rootViewController as! ZHCDemoMessagesViewController
                vc.deliveryIsReceived()
            }
        }
    }
    
    func removeCancelFromChat() {
        App.shared.notificationValue = "0"
        App.shared.notificationType = "0"
        App.shared.notificationDeliveryId = "0"
        if let rootViewController = UIApplication.topViewController() {
            if rootViewController is ZHCDemoMessagesViewController {
                let vc = rootViewController as! ZHCDemoMessagesViewController
                vc.removeCancel()
            }
        }
    }
    func updateNotifications() {
        App.shared.notificationValue = "0"
        App.shared.notificationType = "0"
        App.shared.notificationDeliveryId = "0"
        if let rootViewController = UIApplication.topViewController() {
            if rootViewController is NotificationsVC {
                let vc = rootViewController as! NotificationsVC
                vc.updateNotifications()
            }
        }
    }
    
    
    func openWorkingOrders() {
        App.shared.notificationValue = "0"
        App.shared.notificationType = "0"
        App.shared.notificationDeliveryId = "0"
        if let rootViewController = UIApplication.topViewController() {
            if rootViewController is NotificationsVC {
                let vc = rootViewController as! NotificationsVC
                vc.goToWorkingOrders()
            }
        }
    }
    
    func goToNotifications() {
        App.shared.notificationValue = "0"
        App.shared.notificationType = "0"
        App.shared.notificationDeliveryId = "0"
        if let rootViewController = UIApplication.topViewController() {
            if rootViewController is SendingOrderVC {
                let vc = rootViewController as! SendingOrderVC
                vc.goToNotifications()
            }
        }
    }
    
    func loadTracks() {
        App.shared.notificationValue = "0"
        App.shared.notificationType = "0"
        App.shared.notificationDeliveryId = "0"
        if let rootViewController = UIApplication.topViewController() {
            if rootViewController is HomeMapVC {
                let vc = rootViewController as! HomeMapVC
                vc.loadTracks()
            }
        }
    }
    
    
    func reset() {
        let check = UserDefaults.standard.value(forKey: Constants.DID_SEE_INTRO) as? Bool ?? false
        if (check) {
            if let rootViewController = UIApplication.topViewController() {
                let mainStoryboardIpad : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let initialViewControlleripad : UIViewController = mainStoryboardIpad.instantiateViewController(withIdentifier: self.getHomeView()) as! UINavigationController
                self.window = UIWindow(frame: UIScreen.main.bounds)
                self.window?.rootViewController = initialViewControlleripad
                self.window?.makeKeyAndVisible()
            }else {
                let mainStoryboardIpad : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let initialViewControlleripad : UIViewController = mainStoryboardIpad.instantiateViewController(withIdentifier: self.getHomeView()) as! UINavigationController
                self.window = UIWindow(frame: UIScreen.main.bounds)
                self.window?.rootViewController = initialViewControlleripad
                self.window?.makeKeyAndVisible()
            }
            
        }else {
            let mainStoryboardIpad : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let initialViewControlleripad : UIViewController = mainStoryboardIpad.instantiateViewController(withIdentifier: "IntroNavigationController") as! UINavigationController
            self.window = UIWindow(frame: UIScreen.main.bounds)
            self.window?.rootViewController = initialViewControlleripad
            self.window?.makeKeyAndVisible()
        }
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        self.updateChat()
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
}


extension UITextField {
    func addDoneButtonOnKeyboard()
    {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default
        
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "done".localized, style: .done, target: self, action: #selector(self.doneButtonAction))
        
        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        self.inputAccessoryView = doneToolbar
    }
    
    @objc func doneButtonAction()
    {
        self.resignFirstResponder()
    }
    
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
    
    @IBInspectable var placeHolderColor: UIColor? {
        get {
            return self.placeHolderColor
        }
        set {
            self.attributedPlaceholder = NSAttributedString(string:self.placeholder != nil ? self.placeholder! : "", attributes:[NSAttributedString.Key.foregroundColor: newValue!])
        }
    }
}

extension UISearchBar{
    
    @IBInspectable var doneAccessory: Bool{
        get{
            return self.doneAccessory
        }
        set (hasDone) {
            if true{
                addDoneButtonOnKeyboard()
            }
        }
    }
    
    func addDoneButtonOnKeyboard()
    {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "done".localized, style: .done, target: self, action: #selector(self.doneButtonAction))
        
        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        self.inputAccessoryView = doneToolbar
    }
    
    @objc func doneButtonAction()
    {
        self.resignFirstResponder()
    }
}

extension String {
    
    func toDouble() -> Double? {
        return NumberFormatter().number(from: self)?.doubleValue
    }
    
    func trim() -> String
    {
        return self.trimmingCharacters(in: CharacterSet.whitespaces)
    }
    
    func convertToDictionary() -> [String: Any]? {
        if let data = self.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    func isValidEmail() -> Bool {
        // here, `try!` will always succeed because the pattern is valid
        let regex = try! NSRegularExpression(pattern: "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$", options: .caseInsensitive)
        return regex.firstMatch(in: self, options: [], range: NSRange(location: 0, length: count)) != nil
    }
    
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
    
    var hex: Int? {
        return Int(self, radix: 16)
    }
    func contains(find: String) -> Bool{
        return self.range(of: find) != nil
    }
    func containsIgnoringCase(find: String) -> Bool{
        return self.range(of: find, options: .caseInsensitive) != nil
    }
    func convertToEnglishNumber()->String{
        let format = NumberFormatter()
        format.locale = Locale(identifier: "en")
        if let number = format.number(from: self) {
            let faNumber = format.string(from: number)
            return faNumber ?? ""
        }
        return ""
    }
    public var replacedArabicDigitsWithEnglish: String {
        var str = self
        let map = ["٠": "0",
                   "١": "1",
                   "٢": "2",
                   "٣": "3",
                   "٤": "4",
                   "٥": "5",
                   "٦": "6",
                   "٧": "7",
                   "٨": "8",
                   "٩": "9",
                   "،" : ".",
                   "," : ".",
                   "٫" : "."]
        map.forEach { str = str.replacingOccurrences(of: $0, with: $1) }
        return str
    }
}
extension UIViewController {
//    open override func awakeFromNib() {
//        super.awakeFromNib()
//        if (MOLHLanguage.currentAppleLanguage() == "ar") {
//            navigationController?.view.semanticContentAttribute = .forceRightToLeft
//            navigationController?.navigationBar.semanticContentAttribute = .forceRightToLeft
//        }else {
//            navigationController?.view.semanticContentAttribute = .forceLeftToRight
//            navigationController?.navigationBar.semanticContentAttribute = .forceLeftToRight
//        }
//
//    }
    
    func popBack(_ nb: Int) {
        if let viewControllers: [UIViewController] = self.navigationController?.viewControllers {
            guard viewControllers.count < nb else {
                self.navigationController?.popToViewController(viewControllers[viewControllers.count - nb], animated: true)
                return
            }
        }
    }
}
extension UIColor {
    static var colorPrimary:UIColor {
        return #colorLiteral(red: 0.5137254902, green: 0.5019607843, blue: 0.968627451, alpha: 1)
    }
    static var appLogoColor:UIColor {
        return #colorLiteral(red: 0.1450980392, green: 0.1098039216, blue: 0.3725490196, alpha: 1)
    }
    static var appDarkBlue:UIColor {
        return #colorLiteral(red: 0.2431372549, green: 0.05490196078, blue: 0.4039215686, alpha: 1)
    }
    static var appLightGray:UIColor {
        return #colorLiteral(red: 0.7333333333, green: 0.7333333333, blue: 0.7333333333, alpha: 1)
    }
    
    static var ERROR:UIColor{
        return #colorLiteral(red: 0.9568627451, green: 0.262745098, blue: 0.2117647059, alpha: 1)
    }
    static var SUCCESS:UIColor{
        return #colorLiteral(red: 0.5450980392, green: 0.7647058824, blue: 0.2901960784, alpha: 1)
    }
    static var INFO:UIColor{
        return #colorLiteral(red: 0.3764705882, green: 0.4901960784, blue: 0.5450980392, alpha: 1)
    }
    static var WARNING:UIColor{
        return #colorLiteral(red: 0.7764705882, green: 1, blue: 0, alpha: 1)
    }
    
    static var facebookColor:UIColor {
        return #colorLiteral(red: 0.231372549, green: 0.3490196078, blue: 0.5960784314, alpha: 1)
    }
    static var instagramColor:UIColor {
        return #colorLiteral(red: 0.8039215686, green: 0.2823529412, blue: 0.4196078431, alpha: 1)
    }
    static var twitterColor:UIColor {
        return #colorLiteral(red: 0.2549019608, green: 0.5647058824, blue: 0.8039215686, alpha: 1)
    }
    static var whatsapp_color:UIColor {
        return #colorLiteral(red: 0.1450980392, green: 0.8274509804, blue: 0.4, alpha: 1)
    }
    static var linkedinColor:UIColor {
        return #colorLiteral(red: 0, green: 0.4666666667, blue: 0.7098039216, alpha: 1)
    }
    static var technzoneRed:UIColor {
        return #colorLiteral(red: 0.968627451, green: 0.2784313725, blue: 0.368627451, alpha: 1)
    }
    static var appLightBlue:UIColor {
        return #colorLiteral(red: 0.2235294118, green: 0.631372549, blue: 0.968627451, alpha: 1)
    }
    
    static var pending:UIColor {
        return #colorLiteral(red: 0.5019607843, green: 0.5019607843, blue: 0.5019607843, alpha: 1)
    }
    static var processing:UIColor {
        return #colorLiteral(red: 0.9607843137, green: 0.6509803922, blue: 0.137254902, alpha: 1)
    }
    static var on_the_way:UIColor {
        return #colorLiteral(red: 0.4745098039, green: 0.5176470588, blue: 0.9529411765, alpha: 1)
    }
    static var cancelled:UIColor {
        return #colorLiteral(red: 0.7137254902, green: 0.06274509804, blue: 0.2705882353, alpha: 1)
    }
    static var delivered:UIColor {
        return #colorLiteral(red: 0.4941176471, green: 0.8274509804, blue: 0.1294117647, alpha: 1)
    }
    static var uncheckedView:UIColor {
        return #colorLiteral(red: 0.9490196078, green: 0.9568627451, blue: 0.968627451, alpha: 1)
    }
    static var uncheckedText:UIColor {
        return #colorLiteral(red: 0.1960784314, green: 0.231372549, blue: 0.2705882353, alpha: 1)
    }
    static var expired:UIColor {
        return #colorLiteral(red: 0.7411764706, green: 0.06274509804, blue: 0.8784313725, alpha: 1)
    }
    
    static var app_green:UIColor {
        return #colorLiteral(red: 0.4078431373, green: 0.6235294118, blue: 0.2196078431, alpha: 1)
    }
    static var app_red:UIColor {
        return #colorLiteral(red: 0.9019607843, green: 0.2901960784, blue: 0.09803921569, alpha: 1)
    }
}

extension UIButton {
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        if ((self.restorationIdentifier?.contains(find: "dont_touch") ?? false) == false) {
            let colorAnimation = CABasicAnimation(keyPath: "backgroundColor")
            colorAnimation.fromValue = UIColor.appLightGray.cgColor
            colorAnimation.duration = 1  // animation duration
            // colorAnimation.autoreverses = true // optional in my case
            // colorAnimation.repeatCount = FLT_MAX // optional in my case
            self.layer.add(colorAnimation, forKey: "ColorPulse")
        }
    }
}

extension UIImageView {
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        let colorAnimation = CABasicAnimation(keyPath: "backgroundColor")
        colorAnimation.fromValue = UIColor.appLightGray.cgColor
        colorAnimation.duration = 1  // animation duration
        // colorAnimation.autoreverses = true // optional in my case
        // colorAnimation.repeatCount = FLT_MAX // optional in my case
        self.layer.add(colorAnimation, forKey: "ColorPulse")
    }
}

extension UIView {
    
    
    class func fromNib<T: UIView>() -> T {
        return Bundle.main.loadNibNamed(String(describing: T.self), owner: nil, options: nil)![0] as! T
    }
    func bindFrameToSuperviewBounds() {
        guard let superview = self.superview else {
            print("Error! `superview` was nil – call `addSubview(view: UIView)` before calling `bindFrameToSuperviewBounds()` to fix this.")
            return
        }
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.topAnchor.constraint(equalTo: superview.topAnchor, constant: 0).isActive = true
        self.bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: 0).isActive = true
        self.leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: 0).isActive = true
        self.trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: 0).isActive = true
        
    }
    
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        if (self.restorationIdentifier?.contains(find: "touch_event") ?? false) {
            let colorAnimation = CABasicAnimation(keyPath: "backgroundColor")
            colorAnimation.fromValue = UIColor.appLightGray.cgColor
            colorAnimation.duration = 1  // animation duration
            // colorAnimation.autoreverses = true // optional in my case
            // colorAnimation.repeatCount = FLT_MAX // optional in my case
            self.layer.add(colorAnimation, forKey: "ColorPulse")
        }
    }
    
    
    //anchors
    var safeTopAnchor: NSLayoutYAxisAnchor {
        if #available(iOS 11.0, *) {
            return self.safeAreaLayoutGuide.topAnchor
        }
        return self.topAnchor
    }
    
    var safeLeftAnchor: NSLayoutXAxisAnchor {
        if #available(iOS 11.0, *){
            return self.safeAreaLayoutGuide.leftAnchor
        }
        return self.leftAnchor
    }
    
    var safeRightAnchor: NSLayoutXAxisAnchor {
        if #available(iOS 11.0, *){
            return self.safeAreaLayoutGuide.rightAnchor
        }
        return self.rightAnchor
    }
    
    var safeBottomAnchor: NSLayoutYAxisAnchor {
        if #available(iOS 11.0, *) {
            return self.safeAreaLayoutGuide.bottomAnchor
        }
        return self.bottomAnchor
    }
    
    
    
}

extension UIImage {
    func toBase64() -> String? {
        guard let imageData = self.jpegData(compressionQuality: 0) else { return nil }
        return imageData.base64EncodedString(options: Data.Base64EncodingOptions.lineLength64Characters)
    }
    
    func cropped() -> UIImage? {
        let cropRect = CGRect(x: 0, y: 0, width: 44 * scale, height: 44 * scale)
        
        guard let croppedCGImage = cgImage?.cropping(to: cropRect) else { return nil }
        
        return UIImage(cgImage: croppedCGImage, scale: scale, orientation: imageOrientation)
    }
}
extension UIApplication {
    class func topViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(base: selected)
            }
        }
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        return base
    }
}

extension UITableView {
    func setEmptyView(title: String, message: String, image : String) {
        let emptyView = UIView(frame: CGRect(x: self.center.x, y: self.center.y, width: self.bounds.size.width, height: self.bounds.size.height))
        let img = UIImage(named: image)
        let imageView = UIImageView(image: img!)
        
        let titleLabel = UILabel()
        let messageLabel = UILabel()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textColor = UIColor.black
        messageLabel.textColor = UIColor.lightGray
        
        if (MOLHLanguage.currentAppleLanguage() == "ar") {
            titleLabel.font = UIFont(name: Constants.ARABIC_FONT_BOLD, size: 17)
            messageLabel.font = UIFont(name: Constants.ARABIC_FONT_REGULAR, size: 15)
        }else {
            titleLabel.font = UIFont(name: Constants.ENGLISH_FONT_BOLD, size: 17)
            messageLabel.font = UIFont(name: Constants.ENGLISH_FONT_REGULAR, size: 15)
        }
        
        imageView.contentMode = .scaleAspectFit
        emptyView.addSubview(imageView)
        emptyView.addSubview(titleLabel)
        emptyView.addSubview(messageLabel)
        
        imageView.widthAnchor.constraint(equalToConstant: 200.0).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 200.0).isActive = true
        
        imageView.centerYAnchor.constraint(equalTo: emptyView.centerYAnchor).isActive = true
        imageView.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor).isActive = true
        
        titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20).isActive = true
        titleLabel.leftAnchor.constraint(equalTo: emptyView.leftAnchor, constant: 20).isActive = true
        titleLabel.rightAnchor.constraint(equalTo: emptyView.rightAnchor, constant: -20).isActive = true
        
        messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20).isActive = true
        messageLabel.leftAnchor.constraint(equalTo: emptyView.leftAnchor, constant: 20).isActive = true
        messageLabel.rightAnchor.constraint(equalTo: emptyView.rightAnchor, constant: -20).isActive = true
        
        titleLabel.text = title
        messageLabel.text = message
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        titleLabel.textAlignment = .center
        // The only tricky part is here:
        self.backgroundView = emptyView
        self.separatorStyle = .none
    }
    func restore() {
        self.backgroundView = nil
        self.separatorStyle = .none
    }
}


extension UICollectionView {
    func setEmptyView(title: String, message: String, image : String) {
        let emptyView = UIView(frame: CGRect(x: self.center.x, y: self.center.y, width: self.bounds.size.width, height: self.bounds.size.height))
        let img = UIImage(named: image)
        let imageView = UIImageView(image: img!)
        
        let titleLabel = UILabel()
        let messageLabel = UILabel()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textColor = UIColor.black
        messageLabel.textColor = UIColor.lightGray
        
        if (MOLHLanguage.currentAppleLanguage() == "ar") {
            titleLabel.font = UIFont(name: Constants.ARABIC_FONT_BOLD, size: 17)
            messageLabel.font = UIFont(name: Constants.ARABIC_FONT_REGULAR, size: 15)
        }else {
            titleLabel.font = UIFont(name: Constants.ENGLISH_FONT_BOLD, size: 17)
            messageLabel.font = UIFont(name: Constants.ENGLISH_FONT_REGULAR, size: 15)
        }
        
        imageView.contentMode = .scaleAspectFit
        emptyView.addSubview(imageView)
        emptyView.addSubview(titleLabel)
        emptyView.addSubview(messageLabel)
        
        imageView.widthAnchor.constraint(equalToConstant: 200.0).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 200.0).isActive = true
        
        imageView.centerYAnchor.constraint(equalTo: emptyView.centerYAnchor).isActive = true
        imageView.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor).isActive = true
        
        titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20).isActive = true
        titleLabel.leftAnchor.constraint(equalTo: emptyView.leftAnchor, constant: 20).isActive = true
        titleLabel.rightAnchor.constraint(equalTo: emptyView.rightAnchor, constant: -20).isActive = true
        
        messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20).isActive = true
        messageLabel.leftAnchor.constraint(equalTo: emptyView.leftAnchor, constant: 20).isActive = true
        messageLabel.rightAnchor.constraint(equalTo: emptyView.rightAnchor, constant: -20).isActive = true
        
        titleLabel.text = title
        messageLabel.text = message
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        titleLabel.textAlignment = .center
        // The only tricky part is here:
        self.backgroundView = emptyView
        // self.separatorStyle = .none
    }
    func restore() {
        self.backgroundView = nil
        // self.separatorStyle = .none
    }
}
