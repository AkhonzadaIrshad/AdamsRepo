//
//  PaymentMethodSheet.swift
//  rzq
//
//  Created by Zaid Khaled on 10/30/19.
//  Copyright © 2019 technzone. All rights reserved.
//

import UIKit

protocol PaymentSheetDelegate {
    func onSubmit(method : Int)
}
class PaymentMethodSheet: BaseVC {
    
    @IBOutlet weak var ivKnetCheck: UIImageView!
    
    @IBOutlet weak var ivCashCheck: UIImageView!
    
    var selectedMethod : Int?
    
    var delegate : PaymentSheetDelegate?
    
    //240
    //ic_checked
    //ic_unchecked_orange
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.selectPaymentMethod(method: self.selectedMethod ?? Constants.PAYMENT_METHOD_CASH)
        // Do any additional setup after loading the view.
    }
    
    @IBAction func submitAction(_ sender: Any) {
        self.delegate?.onSubmit(method: self.selectedMethod ?? Constants.PAYMENT_METHOD_CASH)
    }
    
    @IBAction func knetAction(_ sender: Any) {
        self.selectPaymentMethod(method: Constants.PAYMENT_METHOD_KNET)
    }
    
    @IBAction func cashAction(_ sender: Any) {
        self.selectPaymentMethod(method: Constants.PAYMENT_METHOD_CASH)
    }
    
    func selectPaymentMethod(method: Int) {
        switch method {
        case Constants.PAYMENT_METHOD_CASH:
            self.ivCashCheck.image = UIImage(named: "ic_checked")
            self.ivKnetCheck.image = UIImage(named: "ic_unchecked_orange")
            self.selectedMethod = Constants.PAYMENT_METHOD_CASH
            break
        case Constants.PAYMENT_METHOD_BALANCE:
            self.ivCashCheck.image = UIImage(named: "ic_checked")
            self.ivKnetCheck.image = UIImage(named: "ic_unchecked_orange")
            self.selectedMethod = Constants.PAYMENT_METHOD_CASH
            break
        case Constants.PAYMENT_METHOD_KNET:
            self.ivCashCheck.image = UIImage(named: "ic_unchecked_orange")
            self.ivKnetCheck.image = UIImage(named: "ic_checked")
            self.selectedMethod = Constants.PAYMENT_METHOD_KNET
            break
        default:
            self.ivCashCheck.image = UIImage(named: "ic_checked")
            self.ivKnetCheck.image = UIImage(named: "ic_unchecked_orange")
            self.selectedMethod = Constants.PAYMENT_METHOD_CASH
            break
        }
    }
    
    
}
