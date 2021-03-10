//
//  ScalingCarouselCell.swift
//  rzq
//
//  Created by Said Elmansour on 2021-03-06.
//  Copyright © 2021 technzone. All rights reserved.
//

import UIKit
import Cosmos

class ScalingCarouselCell: UICollectionViewCell {
    @IBOutlet weak var shopName: UILabel!
    @IBOutlet weak var ratingView: CosmosView!
    
    @IBOutlet weak var shopeImageView: UIImageView!
    @IBOutlet weak var ratingLabe: UILabel!
    @IBOutlet weak var makeOrderButton: UIButton!
    
    var onMakeOrderAction: (() -> Void)? = nil

    // MARK: - Properties (Public)
    
    /// The minimum value to scale to, should be set between 0 and 1
    open var scaleMinimum: CGFloat = 0.9
    
    /// Divisior used when calculating the scale value.
    /// Lower values cause a greater difference in scale between subsequent cells.
    open var scaleDivisor: CGFloat = 10.0
    
    /// The minimum value to alpha to, should be set between 0 and 1
    open var alphaMinimum: CGFloat = 0.85
    
    /// The corner radius value of the cell's main view
    open var cornerRadius: CGFloat = 20.0
    
    // MARK: - IBOutlets
    
    // This property should be connected to the main cell subview
    @IBOutlet public var mainView: UIView!
    
    // MARK: - Overrides
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        
        guard let carouselView = superview as? ScalingCarouselView else { return }
        
        scale(withCarouselInset: carouselView.inset)
    }
    
    override open func prepareForReuse() {
        super.prepareForReuse()
        mainView.transform = CGAffineTransform.identity
        mainView.alpha = 1.0
    }
    
    /// Scale the cell when it is scrolled
    ///
    /// - parameter carouselInset: The inset of the related SPBCarousel view
    open func scale(withCarouselInset carouselInset: CGFloat) {
        
        // Ensure we have a superView, and mainView
        guard let superview = superview,
            let mainView = mainView else { return }
        
        // Get our absolute origin value and width/height based on the scroll direction
        var origin = superview.convert(frame, to: superview.superview).origin.x
        var contentWidthOrHeight = frame.size.width
        if let collectionView = superview as? ScalingCarouselView, collectionView.scrollDirection == .vertical {
            origin = superview.convert(frame, to: superview.superview).origin.y
            contentWidthOrHeight = frame.size.height
        }
        
        // Calculate our actual origin.x value using our inset
        let originActual = origin - carouselInset
        
        
        // Calculate our scale values
        let scaleCalculator = abs(contentWidthOrHeight - abs(originActual))
        let percentageScale = (scaleCalculator/contentWidthOrHeight)
        
        let scaleValue = scaleMinimum
            + (percentageScale/scaleDivisor)
        
        let alphaValue = alphaMinimum
            + (percentageScale/scaleDivisor)
        
        let affineIdentity = CGAffineTransform.identity
        
        // Scale our mainView and set it's alpha value
        mainView.transform = affineIdentity.scaledBy(x: scaleValue, y: scaleValue)
        mainView.alpha = 1
        
        // ..also..round the corners
        mainView.layer.cornerRadius = cornerRadius
    }
    
    
    @IBAction func onMakeOrder(_ sender: Any) {
        if let onMakeOrderAction = self.onMakeOrderAction {
            onMakeOrderAction()
        }
    }
    
    @IBAction func onYourplace(_ sender: Any) {
    }
    
}
