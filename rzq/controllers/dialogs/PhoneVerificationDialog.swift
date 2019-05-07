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
class PhoneVerificationDialog: BaseVC {

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
        self.startTimer()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        stopTimer()
    }
    
    @objc func updateTimer() {
        if(countDown > 0) {
            countDown = countDown - 1
            lblCounter.text = String(countDown)
        }else{
            // self.sendRequest()
            self.btnResend.isHidden = false
            self.resendView.isHidden = false
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
        self.btnResend.isHidden = true
        self.resendView.isHidden = true
        self.startTimer()
        self.delegate?.resend()
    }
    
    @IBAction func confirmAction(_ sender: Any) {
        if (self.pinView.getPinAsString().count == 4) {
            self.showLoading()
            ApiService.verifyPinCode(userId: self.userId ?? "", code: self.pinView.getPinAsString()) { (response, status) in
                self.hideLoading()
                if (status != 0) {
                     self.showBanner(title: "alert".localized, message: "wrong_verification_code".localized, style: UIColor.INFO)
                     return
                }
                if (response?.errorCode == 0) {
                    self.deleteUsers()
                    self.updateUser(self.getRealmUser(userProfile: response!))
                    let mainStoryboardIpad : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    let initialViewControlleripad : UIViewController = mainStoryboardIpad.instantiateViewController(withIdentifier: self.getHomeView()) as! UINavigationController
                    self.present(initialViewControlleripad, animated: true, completion: {})
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
    
    @IBAction func dismissAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
}
