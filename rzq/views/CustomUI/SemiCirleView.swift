//
//  SemiCirleView.swift
//  rzq
//
//  Created by Zaid najjar on 4/1/19.
//  Copyright © 2019 technzone. All rights reserved.
//

import UIKit

//@IBDesignable
class SemiCirleView: UIView {
    
    var semiCirleLayer: CAShapeLayer!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if semiCirleLayer == nil {
            let arcCenter = CGPoint(x: bounds.size.width / 2, y: bounds.size.height)
            let circleRadius = bounds.size.width / 1.3
            let circlePath = UIBezierPath(arcCenter: arcCenter, radius: circleRadius, startAngle: CGFloat.pi, endAngle: CGFloat.pi * 2, clockwise: true)
            
            semiCirleLayer = CAShapeLayer()
            semiCirleLayer.path = circlePath.cgPath
            semiCirleLayer.fillColor = UIColor.white.cgColor
            layer.addSublayer(semiCirleLayer)
            // Make the view color transparent
            backgroundColor = UIColor.clear
        }
    }
}
