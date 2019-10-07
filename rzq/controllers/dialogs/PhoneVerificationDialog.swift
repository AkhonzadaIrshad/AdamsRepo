//
//  PhoneVerificationDialog.swift
//  rzq
//
//  Created by Zaid najjar on 4/2/19.
//  Copyright © 2019 technzone. All rights reserved.
//

import UIKit
import CBPinEntryView

protocol PhoneVerificationDelegate {
    func resend()
}
class PhoneVerificationDialog: BaseVC, CBPinEntryViewDelegate {

    @IBOutlet weak var pinView: CBPinEntryView!
    
    @IBOutlet weak var lblCounter: MyUILabel!
    
    @IBOutlet weak var btnResend: MyUIButton!
    
    @IBOutlet weak var resendView: CardView!
    var countDown:Int = 60
    var timer:Timer?
    
    var userId : String?
    
    var delegate : PhoneVerificationDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if (self.isArabic()) {
            navigationController?.view.semanticContentAttribute = .forceRightToLeft
            navigationController?.navigationBar.semanticContentAttribute = .forceRightToLeft
        }
        
        self.startTimer()
        
        self.pinView.delegate = self
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        stopTimer()
    }
    
    func entryChanged(_ completed: Bool) {
        if (completed) {
            self.pinView.resignFirstResponder()
            self.confirm()
        }
    }
    
    @objc func updateTimer() {
        if(countDown > 0) {
            countDown = countDown - 1
            lblCounter.text = String(countDown)
        }else{
            // self.sendRequest()
            self.resendView.backgroundColor = UIColor.processing
            self.btnResend.isEnabled = true
        }
    }
    
    func startTimer() {
        stopTimer()
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }
    
    func stopTimer() {
        if timer != nil {
            timer?.invalidate()
            timer = nil
        }
        countDown = 60
        lblCounter.text = ""
        
    }
    

    @IBAction func resendAction(_ sender: Any) {
        self.resendView.backgroundColor = UIColor.appLightGray
        self.btnResend.isEnabled = false
        self.startTimer()
        self.delegate?.resend()
    }
    
    @IBAction func confirmAction(_ sender: Any) {
       self.confirm()
    }
    
    func confirm() {
        if (self.pinView.getPinAsString().count == 4) {
            self.showLoading()
            ApiService.verifyPinCode(userId: self.userId ?? "", code: self.pinView.getPinAsString().replacedArabicDigitsWithEnglish) { (response, status) in
                self.hideLoading()
                if (status != 0) {
                    self.showBanner(title: "alert".localized, message: "wrong_verification_code".localized, style: UIColor.INFO)
                    return
                }
                if (response?.errorCode == 0) {
                    self.deleteUsers()
                    self.updateUser(self.getRealmUser(userProfile: response!))
                    
                    //                    let mainStoryboardIpad : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    //                    let initialViewControlleripad : UIViewController = mainStoryboardIpad.instantiateViewController(withIdentifier: self.getHomeView()) as! UINavigationController
                    //                    self.present(initialViewControlleripad, animated: true, completion: {})
                    
                    if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "step1navigation") as? UINavigationController
                    {
                        vc.modalPresentationStyle = .fullScreen
                        self.present(vc, animated: true, completion: nil)
                    }
                    
                    
                }else if (response?.errorCode == 18) {
                    self.showBanner(title: "alert".localized, message: "account_inactive".localized, style: UIColor.INFO)
                }else {
                    self.showBanner(title: "alert".localized, message: "wrong_verification_code".localized, style: UIColor.INFO)
                }
            }
        }else {
            self.showBanner(title: "alert".localized, message: "wrong_verification_code".localized, style: UIColor.INFO)
        }
    }
    
    func loadTracks() {
        ApiService.getOnGoingDeliveries(Authorization: self.loadUser().data?.accessToken ?? "") { (response) in
            if (response.data?.count ?? 0 > 0) {
                let mainStoryboardIpad : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let initialViewControlleripad : UIViewController = mainStoryboardIpad.instantiateViewController(withIdentifier: self.getHomeView()) as! UINavigationController
                initialViewControlleripad.modalPresentationStyle = .fullScreen
                self.present(initialViewControlleripad, animated: true, completion: {})
            }else {
                if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "step1navigation") as? UINavigationController
                {
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true, completion: nil)
                }
            }
        }
    }
    
    
    @IBAction func dismissAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
}
