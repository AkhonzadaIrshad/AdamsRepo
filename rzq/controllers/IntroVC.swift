//
//  IntroVC.swift
//  rzq
//
//  Created by Zaid najjar on 3/30/19.
//  Copyright © 2019 technzone. All rights reserved.
//

import UIKit
import EAIntroView
import RealmSwift

protocol IntroDelegate {
    func nextAction(index : Int)
    func doneAction()
}

class IntroVC: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate, IntroDelegate {

    var pages = [UIViewController]()
    var p1: Intro1?
    var p2: Intro2?
    var p3: Intro3?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
        self.dataSource = self
        
        p1 = storyboard?.instantiateViewController(withIdentifier: "Intro1") as? Intro1
        p1?.delegate = self
        p2 = storyboard?.instantiateViewController(withIdentifier: "Intro2") as? Intro2
        p2?.delegate = self
        p3 = storyboard?.instantiateViewController(withIdentifier: "Intro3") as? Intro3
        p3?.delegate = self
        
        pages.append(p1!)
        pages.append(p2!)
        pages.append(p3!)
        
        // etc ...
        
        setViewControllers([p1!], direction: UIPageViewController.NavigationDirection.forward, animated: false, completion: nil)
        
    }
    
    func nextAction(index : Int) {
        switch index {
        case 1:
            setViewControllers([p2!], direction: .forward, animated: true, completion: nil)
            break
        case 2:
            setViewControllers([p3!], direction: .forward, animated: true, completion: nil)
            break
        default:
            setViewControllers([p2!], direction: .forward, animated: true, completion: nil)
        }
        
    }
    
    func doneAction() {
        UserDefaults.standard.setValue(true, forKey: Constants.DID_SEE_INTRO)
        if (self.loadUser().data?.userID?.count ?? 0 > 0) {
            let mainStoryboardIpad : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let initialViewControlleripad : UIViewController = mainStoryboardIpad.instantiateViewController(withIdentifier: self.getHomeView()) as! UINavigationController
            self.present(initialViewControlleripad, animated: true, completion: {})
        }else {
            let mainStoryboardIpad : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let initialViewControlleripad : UIViewController = mainStoryboardIpad.instantiateViewController(withIdentifier: "LoginNavController") as! UINavigationController
            self.present(initialViewControlleripad, animated: true, completion: {})
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController)-> UIViewController? {
        
        let cur = pages.index(of: viewController)!
        
        // if you prefer to NOT scroll circularly, simply add here:
        // if cur == 0 { return nil }
        
        let prev = abs((cur - 1) % pages.count)
        return pages[prev]
        
    }
    
    func getHomeView() -> String {
        if (App.shared.config?.configSettings?.isMapView ?? true) {
            // return "HomeMapVC"
            return "MapNavigationController"
        }else {
            //  return "HomeListVC"
            return "MapNavigationController"
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController)-> UIViewController? {
        
        let cur = pages.index(of: viewController)!
        
        // if you prefer to NOT scroll circularly, simply add here:
        // if cur == (pages.count - 1) { return nil }
        
        let nxt = abs((cur + 1) % pages.count)
        return pages[nxt]
    }
    
    func presentationIndex(for pageViewController: UIPageViewController)-> Int {
        return pages.count
    }
    
    func deleteUsers() {
        let realm = try! Realm()
        let results = realm.objects(RealmUser.self)
        try! realm.write {
            realm.delete(results)
        }
    }
    
    
    func getRealmUser (userProfile  : VerifyResponse) -> RealmUser {
        
        let realmUser = RealmUser()
        
        realmUser.access_token = userProfile.data?.accessToken ?? ""
        realmUser.phone_number = userProfile.data?.phoneNumber ?? ""
        realmUser.user_name = userProfile.data?.username ?? ""
        realmUser.full_name = userProfile.data?.fullName ?? ""
        realmUser.userId = userProfile.data?.userID ?? ""
        realmUser.date_of_birth = userProfile.data?.dateOfBirth ?? ""
        realmUser.profile_picture = userProfile.data?.profilePicture ?? ""
        realmUser.email = userProfile.data?.email ?? ""
        realmUser.gender = userProfile.data?.gender ?? 1
        realmUser.rate = userProfile.data?.rate ?? 0.0
        realmUser.roles = userProfile.data?.roles ?? ""
        realmUser.isOnline = userProfile.data?.isOnline ?? false
        realmUser.exceeded_amount = userProfile.data?.exceededDueAmount ?? false
        realmUser.dueAmount = userProfile.data?.dueAmount ?? 0.0
        realmUser.earnings = userProfile.data?.earnings ?? 0.0
        
        return realmUser
    }
    
    
    func getUser (realmUser  : RealmUser) -> VerifyResponse {
      let userData = DataClass(accessToken: realmUser.access_token, phoneNumber: realmUser.phone_number, username: realmUser.user_name, fullName: realmUser.full_name, userID: realmUser.userId, dateOfBirth: realmUser.date_of_birth, profilePicture: realmUser.profile_picture, email: realmUser.email, gender: realmUser.gender, rate: realmUser.rate, roles: realmUser.roles, isOnline: realmUser.isOnline,exceededDueAmount: realmUser.exceeded_amount, dueAmount: realmUser.dueAmount, earnings: realmUser.earnings)
        let verifyResponse = VerifyResponse(data: userData, errorCode: 0, errorMessage: "")
        
        return verifyResponse
    }
    
    func updateUser(_ objects: RealmUser) {
        let realm = try! Realm()
        try! realm.write {
            realm.add(objects, update: true)
        }
    }
    
    
    func loadUser() -> VerifyResponse{
        let realm = try! Realm()
        let realmUser = Array(realm.objects(RealmUser.self))
        if (realmUser.count > 0) {
            return self.getUser(realmUser: realmUser[0])
        }else {
        return VerifyResponse(data: DataClass(accessToken: "", phoneNumber: "", username: "", fullName: "", userID: "", dateOfBirth: "", profilePicture: "", email: "", gender: 1, rate: 0, roles: "", isOnline: false,exceededDueAmount:  false,dueAmount: 0.0, earnings: 0.0), errorCode: 0, errorMessage: "")
        }
        
    }
    
}
