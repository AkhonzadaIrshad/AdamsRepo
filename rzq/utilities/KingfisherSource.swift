//
//  KingfisherSource.swift
//  rzq
//
//  Created by Zaid najjar on 4/28/19.
//  Copyright © 2019 technzone. All rights reserved.
//

import Foundation
import Kingfisher
import ImageSlideshow

public class KingfisherSource: NSObject, InputSource {
    public func load(to imageView: UIImageView, with callback: @escaping (UIImage?) -> Void) {
        imageView.kf.setImage(with: self.url, placeholder: self.placeholder, options: nil, progressBlock: nil) { (image, _, _, _) in
            if let image = image {
                callback(image)
            }
        }
    }
    
    var url: URL
    var placeholder: UIImage?
    
    /// Initializes a new source with a URL
    /// - parameter url: a url to be loaded
    public init(url: URL) {
        self.url = url
        super.init()
    }
    
    /// Initializes a new source with URL and placeholder
    /// - parameter url: a url to be loaded
    /// - parameter placeholder: a placeholder used before image is loaded
    public init(url: URL, placeholder: UIImage) {
        self.url = url
        self.placeholder = placeholder
        super.init()
    }
    
    /// Initializes a new source with a URL string
    /// - parameter urlString: a string url to be loaded
    public init?(urlString: String) {
        if let validUrl = URL(string: urlString) {
            self.url = validUrl
            super.init()
        } else {
            return nil
        }
    }
    
}
