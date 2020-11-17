//
//  Extension.swift
//  rzq
//
//  Created by Said Elmansour on 2020-11-17.
//  Copyright © 2020 technzone. All rights reserved.
//

import Foundation
import UIKit

// MARK: CGRect extension

extension CGRect {
    var x: CGFloat {
        get {
            return self.origin.x
        }
        set {
            self.origin.x = newValue
        }
    }
    
    var y: CGFloat {
        get {
            return self.origin.y
        }
        set {
            self.origin.y = newValue
        }
    }
    
    var center: CGPoint {
        return CGPoint(x: self.x + self.width / 2, y: self.y + self.height / 2)
    }
}

// MARK: CGPoint extension

extension CGPoint {
    func distance(to point: CGPoint) -> CGFloat {
        let xDist = self.x - point.x
        let yDist = self.y - point.y
        return CGFloat(sqrt((xDist * xDist) + (yDist * yDist)))
    }
    
    func farCornerDistance() -> CGFloat {
        let bounds = UIScreen.main.bounds
        let leftTopCorner = CGPoint.zero
        let rightTopCorner = CGPoint(x: bounds.width, y: 0)
        let leftBottomCorner = CGPoint(x: 0, y: bounds.height)
        let rightBottomCorner = CGPoint(x: bounds.width, y: bounds.height)
        return max(distance(to: leftTopCorner), max(distance(to: rightTopCorner), max(distance(to: leftBottomCorner), distance(to: rightBottomCorner))))
    }
}

// MARK: UIBarItem extension

extension UIBarItem {
    var view: UIView? {
        if let item = self as? UIBarButtonItem, let customView = item.customView {
            return customView
        }
        return self.value(forKey: "view") as? UIView
    }
}


