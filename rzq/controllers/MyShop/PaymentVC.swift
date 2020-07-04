//
//  PaymentVC.swift
//  rzq
//
//  Created by Zaid Khaled on 10/22/19.
//  Copyright © 2019 technzone. All rights reserved.
//

import UIKit
import WebKit
import MOLH
import MFSDK
//import SwiftWebVC

protocol PaymentDelegate {
    func onPaymentSuccess(payment : PaymentStatusResponse)
    func onPaymentFail()
}

class PaymentVC: BaseVC, WKNavigationDelegate, WKUIDelegate {
    
    @IBOutlet weak var webView: WKWebView!
   // var webView: WKWebView!
    var total : Double?
    var items = [ShopMenuItem]()
    var invoiceId : String?
    var delegate : PaymentDelegate?
    
    var activityIndicator: UIActivityIndicatorView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.webView.addObserver(self, forKeyPath: "URL", options: .new, context: nil)
        self.webView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
        
      
        self.showLoading()
        ApiService.placePayment(user: DataManager.loadUser(), total: total ?? 0.0, items: self.items) { (response) in
            self.hideLoading()
            if (response.isSuccess ?? false) {
                self.invoiceId = "\(response.paymentData?.invoiceID ?? 0)"
                let link = URL(string:response.paymentData?.paymentURL ?? "")!
                let request = URLRequest(url: link)
                self.webView.load(request)
                
                //test this
//                let webVC = SwiftModalWebVC(urlString: response.paymentData?.paymentURL ?? "")
//                self.present(webVC, animated: true, completion: nil)
                //
                
            }else {
                self.showBanner(title: "alert".localized, message: response.message ?? "", style: UIColor.ERROR)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.dismiss(animated: true, completion: nil)
                }
            }
            
        }
        
        activityIndicator = UIActivityIndicatorView()
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = UIActivityIndicatorView.Style.gray
        
        view.addSubview(activityIndicator)
                
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath(WKWebView.url) {
            print("### URL:", self.webView.url!)
            let currentUrl = self.webView.url?.absoluteString ?? ""
            if (currentUrl.contains(find: Constants.PAYMENT_SUCCESS_URL)) {
                self.getPaymentStatus()
            } else   if (currentUrl.contains(find: Constants.PAYMENT_FAIL_URL)) {
                self.showBanner(title: "alert".localized, message: "payment_failed".localized, style: UIColor.INFO)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.delegate?.onPaymentFail()
                    self.dismiss(animated: true, completion: nil)
                }
            }else {
                //nth
            }
        }
        
        if keyPath == #keyPath(WKWebView.estimatedProgress) {
            // When page load finishes. Should work on each page reload.
            if (self.webView.estimatedProgress == 1) {
                print("### EP:", self.webView.estimatedProgress)
            }
        }
    }
    
    
    func getPaymentStatus() {
        self.showLoading()
        ApiService.getPaymentStatus(invoiceId: self.invoiceId ?? "") { (response) in
            self.hideLoading()
            if (response.isSuccess ?? false) {
                if (response.paymentStatusData?.invoiceStatus == "Paid") {
                    self.showBanner(title: "alert".localized, message: "paid_successfully".localized, style: UIColor.SUCCESS)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        self.delegate?.onPaymentSuccess(payment : response)
                        self.dismiss(animated: true, completion: nil)
                    }
                }else {
                    self.showBanner(title: "alert".localized, message: response.paymentStatusData?.invoiceStatus ?? "", style: UIColor.INFO)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        self.delegate?.onPaymentFail()
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            }else {
                self.showBanner(title: "alert".localized, message: response.message ?? "", style: UIColor.ERROR)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    func showActivityIndicator(show: Bool) {
        if show {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        showActivityIndicator(show: false)
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        showActivityIndicator(show: true)
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        showActivityIndicator(show: false)
    }
    
    @IBAction func closeAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

