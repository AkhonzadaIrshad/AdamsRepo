//
//  ImageSliderVC.swift
//  rzq
//
//  Created by Zaid najjar on 4/28/19.
//  Copyright © 2019 technzone. All rights reserved.
//

import UIKit
import ImageSlideshow
import Kingfisher

class ImageSliderVC: BaseVC {
    
    @IBOutlet weak var slideShow: ImageSlideshow!
    
    @IBOutlet weak var ivHandle: UIImageView!
    
    
    var orderImages = [String]()
    var images = [InputSource]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (self.isArabic()) {
            self.ivHandle.image = UIImage(named: "ic_back_arabic")
        }
        for str in self.orderImages{
            
            if (str.contains(find: "jpg") || str.contains(find: "jpeg") || str.contains(find: "png")) {
              
                    let alamofireSource = KingfisherSource(urlString: "\(Constants.IMAGE_URL)\(str)")!
                    self.images.append(alamofireSource)
                
            }
        }
        
        self.slideShow.setImageInputs(self.images)
        
        self.slideShow.zoomEnabled = true
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
