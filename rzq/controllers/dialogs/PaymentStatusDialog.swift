//
//  PaymentStatusDialog.swift
//  rzq
//
//  Created by Zaid Khaled on 11/4/19.
//  Copyright © 2019 technzone. All rights reserved.
//

import UIKit

protocol PaymentStatusDelegate {
    func onCashPaid()
    func onCashFail()
    func onKnetPaid()
    func onKnetFail()
}
class PaymentStatusDialog: BaseVC {
    
    @IBOutlet weak var ivLogo: UIImageView!
    
    @IBOutlet weak var lblContent: MyUILabel!
    
    @IBOutlet weak var btnDismiss: MyUIButton!
    
    @IBOutlet weak var btnConfirm: MyUIButton!
    
    @IBOutlet weak var viewDismiss: CardView!
    
    
    var delegate : PaymentStatusDelegate?
    
    var order : DatumDel?
    var isPaid : Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        switch self.order?.paymentMethod {
        case Constants.PAYMENT_METHOD_CASH:
            self.ivLogo.image = UIImage(named: "payment_cash_paid")
            self.lblContent.text = "paid_cash".localized
            self.btnDismiss.setTitle("didnt_pay".localized, for: .normal)
            self.btnConfirm.setTitle("confirm".localized, for: .normal)
            break
        case Constants.PAYMENT_METHOD_KNET:
            if (self.isPaid ?? false) {
                self.ivLogo.image = UIImage(named: "payment_knet_paid")
                self.lblContent.text = "payment_knet_paid".localized
                self.viewDismiss.isHidden = true
                self.btnConfirm.setTitle("confirm".localized, for: .normal)
            }else {
                self.ivLogo.image = UIImage(named: "payment_knet_fail")
                self.lblContent.text = "payment_knet_fail".localized
                self.btnDismiss.setTitle("cash_collected".localized, for: .normal)
                self.btnConfirm.setTitle("send_knet_link".localized, for: .normal)
            }
            break
        default:
            self.ivLogo.image = UIImage(named: "payment_cash_paid")
            self.lblContent.text = "paid_cash".localized
            self.btnDismiss.setTitle("didnt_pay".localized, for: .normal)
            self.btnConfirm.setTitle("confirm".localized, for: .normal)
            break
        }
    }
    
    @IBAction func dismissAction(_ sender: Any) {
        if (self.order?.paymentMethod == Constants.PAYMENT_METHOD_CASH) {
            self.delegate?.onCashFail()
        }else  if (self.order?.paymentMethod == Constants.PAYMENT_METHOD_KNET) {
            if (self.isPaid ?? false) {
                //no action
            }else {
                self.delegate?.onCashPaid()
            }
        }else if (self.order?.paymentMethod == Constants.PAYMENT_METHOD_BALANCE) {
              //for testing, restore cash
             self.delegate?.onCashFail()
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func confirmAction(_ sender: Any) {
        if (self.order?.paymentMethod == Constants.PAYMENT_METHOD_CASH) {
            self.delegate?.onCashPaid()
        }else  if (self.order?.paymentMethod == Constants.PAYMENT_METHOD_KNET) {
            if (self.isPaid ?? false) {
                self.delegate?.onKnetPaid()
            }else {
                self.delegate?.onKnetFail()
            }
        }else if (self.order?.paymentMethod == Constants.PAYMENT_METHOD_BALANCE) {
            //for testing, restore cash
            self.delegate?.onCashPaid()
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    
}
