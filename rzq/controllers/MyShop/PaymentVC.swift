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
        
//        let autocorrectJavaScript = "var inputTextElement = document.getElementById('debitNumber');"
//              + "   if (inputTextElement != null) {"
//              + "     var autocorrectAttribute = document.createAttribute('autocorrect');"
//              + "     autocorrectAttribute.value = 'off';"
//              + "     inputTextElement.setAttributeNode(autocorrectAttribute);"
//              + "   }"
//              let userScript = WKUserScript(source: autocorrectJavaScript, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
//              let webConfiguration = WKWebViewConfiguration()
//              webConfiguration.userContentController.addUserScript(userScript)
//
//        let frame = self.view.frame
//        self.webView = WKWebView(frame: frame, configuration: webConfiguration)
//        self.view.addSubview(self.webView)
        
        // self.webView.scrollView.delegate = self
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
        
        // Do any additional setup after loading the view.
        
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        MOLH.setLanguageTo("en")
//        MOLH.reset()
//    }
    
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        MOLH.setLanguageTo("ar")
//        MOLH.reset()
//    }
    
    //    func sdk_placePayment() {
    //        let card = MFCardInfo(cardNumber: "8888880000000001", cardExpiryMonth: "09", cardExpiryYear: "21", cardSecurityCode: "1234", saveToken: true) //MFCardInfo(cardToken: "token")
    //         let invoiceValue = 5.0
    //
    //         let request = MFExecutePaymentRequest(invoiceValue: invoiceValue, paymentMethod: 1)
    //         MFPaymentRequest.shared.executeDirectPayment(request: request, cardInfo: card, apiLanguage: .english) { [weak self] response, invoiceId in
    //             switch response {
    //             case .success(let directPaymentResponse):
    //                 if let cardInfoResponse = directPaymentResponse.cardInfoResponse, let card = cardInfoResponse.cardInfo {
    //                     print("Status: with card number \(card.number)")
    //                 }
    //                 if let invoiceId = invoiceId {
    //                     print("Success with invoiceId \(invoiceId)")
    //                 }
    //             case .failure(let failError):
    //                 print("Error: \(failError.errorDescription)")
    //                 if let invoiceId = invoiceId {
    //                     print("Fail: \(failError.statusCode) with invoiceId \(invoiceId)")
    //                 }
    //             }
    //         }
    //    }
    
    
    
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

//extension PaymentVC: UIScrollViewDelegate {
//    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
//        return nil
//    }
//    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
//       scrollView.pinchGestureRecognizer?.isEnabled = false
//    }
//}
