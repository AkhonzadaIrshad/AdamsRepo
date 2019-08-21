//
//  FormTextField.swift
//  rzq
//
//  Created by Zaid najjar on 5/14/19.
//  Copyright © 2019 technzone. All rights reserved.
//

import Foundation
import UIKit

//@IBDesignable
class FormTextField: UITextField {
    
    @IBInspectable var borderColor: UIColor? {
        didSet {
            layer.borderColor = borderColor?.cgColor
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
}
