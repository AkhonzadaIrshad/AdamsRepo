//
//  PaymentVC.swift
//  rzq
//
//  Created by Zaid Khaled on 10/22/19.
//  Copyright © 2019 technzone. All rights reserved.
//

import UIKit
import WebKit

class PaymentVC: BaseVC, WKNavigationDelegate, WKUIDelegate {
    
    
    @IBOutlet weak var webView: WKWebView!
    
    var total : Double?
    var items = [ShopMenuItem]()
    
    var activityIndicator: UIActivityIndicatorView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.showLoading()
        ApiService.placePayment(user: self.loadUser(), total: total ?? 0.0, items: self.items) { (response) in
            self.hideLoading()
            if (response.isSuccess ?? false) {
                let link = URL(string:response.paymentData?.paymentURL ?? "")!
                let request = URLRequest(url: link)
                self.webView.load(request)
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
