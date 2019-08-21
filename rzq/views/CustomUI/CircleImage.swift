//
//  CircleImage.swift
//  rzq
//
//  Created by Zaid najjar on 4/7/19.
//  Copyright © 2019 technzone. All rights reserved.
//

import Foundation
import UIKit

//@IBDesignable
class CircleImage : UIImageView {
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = self.frame.size.width/2
        self.clipsToBounds = true
    }
}
