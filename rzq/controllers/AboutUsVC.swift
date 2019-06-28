//
//  AboutUsVC.swift
//  rzq
//
//  Created by Zaid najjar on 4/16/19.
//  Copyright © 2019 technzone. All rights reserved.
//

import UIKit
import JJFloatingActionButton

class AboutUsVC: BaseVC {

    @IBOutlet weak var ivHandle: UIImageView!
    
    @IBOutlet weak var ivLogo: UIImageView!
    
    @IBOutlet weak var tvContent: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let urlStr = App.shared.config?.company?.logo ?? ""
        if (urlStr.count > 0) {
            let url = URL(string: "\(Constants.IMAGE_URL)\(urlStr)")
            self.ivLogo.kf.setImage(with: url)
        }
        
        if (self.isArabic()) {
            self.tvContent.textAlignment = NSTextAlignment.right
          self.tvContent.text = App.shared.config?.company?.arabicDescription ?? ""
              self.ivHandle.image = UIImage(named: "ic_back_arabic")
            
            let style = NSMutableParagraphStyle()
            style.lineSpacing = 10
            let attributes = [NSAttributedString.Key.paragraphStyle : style]
            self.tvContent.attributedText = NSAttributedString(string: self.tvContent.text, attributes: attributes)
            
            
        }else {
         self.tvContent.text = App.shared.config?.company?.englishDescription ?? ""
        }
        self.setupFloating()
    }
    
    func openFacebookPage() {
        if let url = URL(string: "fb://profile/\(Constants.FACEBOOK_PAGE_ID)") {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url, options: [:],completionHandler: { (success) in
                    print("Open fb://profile/\(Constants.FACEBOOK_PAGE_ID): \(success)")
                })
            } else {
                let success = UIApplication.shared.openURL(url)
                print("Open fb://profile/\(Constants.FACEBOOK_PAGE_ID): \(success)")
            }
        }
    }
    
    func openTwitterProfile() {
        let twitterURL = NSURL(string: Constants.TWITTER_URL)!
        if UIApplication.shared.canOpenURL(twitterURL as URL) {
            UIApplication.shared.open(twitterURL as URL)
        } else {
            UIApplication.shared.open(NSURL(string: Constants.TWITTER_URL_ALT)! as URL)
        }
    }
    
    func openInstagramAccount() {
        let Username =  Constants.INSTAGRAM_ACC // Your Instagram Username here
        let appURL = URL(string: "instagram://user?username=\(Username)")!
        let application = UIApplication.shared
        
        if application.canOpenURL(appURL) {
            application.open(appURL)
        } else {
            // if Instagram app is not installed, open URL inside Safari
            let webURL = URL(string: "https://instagram.com/\(Username)")!
            application.open(webURL)
        }
    }
    
    func openWebsite() {
        let application = UIApplication.shared
        let webURL = URL(string: App.shared.config?.company?.website ?? "")!
        application.open(webURL)
    }
    
    func callNumber()
    {
        if let url = URL(string: "https://api.whatsapp.com/send?phone=\(App.shared.config?.company?.phone ?? "")"), UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    
    func setupFloating() {
        let actionButton = JJFloatingActionButton()
        
        
        let item = actionButton.addItem()
        item.titleLabel.text = "our_facebook".localized
        item.titleLabel.font = UIFont(name: self.getFontName(), size: 13)
        item.imageView.image = UIImage(named: "ic_about1")
        item.buttonColor = UIColor.facebookColor
        item.buttonImageColor = .white
        item.action = { item in
            
            self.openFacebookPage()
        }
        
        let item2 = actionButton.addItem()
        item2.titleLabel.text = "our_instagram".localized
        item2.titleLabel.font = UIFont(name: self.getFontName(), size: 13)
        item2.imageView.image = UIImage(named: "ic_about2")
        item2.buttonColor = UIColor.instagramColor
        item2.buttonImageColor = .white
        item2.action = { item in
            
            self.openInstagramAccount()
        }
        
        let item3 = actionButton.addItem()
        item3.titleLabel.text = "our_website".localized
        item3.titleLabel.font = UIFont(name: self.getFontName(), size: 13)
        item3.imageView.image = UIImage(named: "ic_about3")
        item3.buttonColor = UIColor.colorPrimary
        item3.buttonImageColor = .white
        item3.action = { item in
            
            self.openWebsite()
        }
        
        let item4 = actionButton.addItem()
        item4.titleLabel.text = "call_us".localized
        item4.titleLabel.font = UIFont(name: self.getFontName(), size: 13)
        item4.imageView.image = UIImage(named: "ic_about4")
        item4.buttonColor = UIColor.colorPrimary
        item4.buttonImageColor = .white
        item4.action = { item in
            self.callNumber()
        }
        let item5 = actionButton.addItem()
        item5.titleLabel.text = "our_twitter".localized
        item5.titleLabel.font = UIFont(name: self.getFontName(), size: 13)
        item5.imageView.image = UIImage(named: "ic_about5")
        item5.buttonColor = UIColor.twitterColor
        item5.buttonImageColor = .white
        item5.action = { item in
            self.openTwitterProfile()
        }
        
        actionButton.buttonColor = UIColor.white
        actionButton.shadowColor = UIColor.blue
        actionButton.buttonImage = UIImage(named: "ic_fab_menu")
        
        view.addSubview(actionButton)
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 11.0, *) {
            actionButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16).isActive = true
        } else {
            // Fallback on earlier versions
        }
        if #available(iOS 11.0, *) {
            actionButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16).isActive = true
        } else {
            // Fallback on earlier versions
        }
        
        // last 4 lines can be replaced with
        // actionButton.display(inViewController: self)
    }
    
    @IBAction func backAction(_ sender: Any) {
    self.navigationController?.popViewController(animated: true)
    }
    
}
