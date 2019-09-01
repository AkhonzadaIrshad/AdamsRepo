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
            let alamofireSource = KingfisherSource(urlString: "\(Constants.IMAGE_URL)\(str)")!
            images.append(alamofireSource)
        }
        
        self.slideShow.setImageInputs(images)
        
        self.slideShow.zoomEnabled = true
        
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
