//
//  AdressCell.swift
//  rzq
//
//  Created by Said Elmansour on 2021-05-03.
//  Copyright © 2021 technzone. All rights reserved.
//

import UIKit

protocol AdressCellDelegate: class {
    func selectedAdress()
}

class AdressCell: UITableViewCell {

    // MARK: - Type Properties

    static var identifier: String {
        String(describing: self)
    }
    let userAdressData: userAdressData? = nil
    
    // MARK: - Views

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var checkMarkView: CheckMarkView!
    @IBOutlet weak var adressLabel: UILabel!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // MARK: - Local Halpers
    
    private func setupUI() {
        containerView.layer.applyCornerRadiusShadow(color: .lightGray,
                                    alpha: 0.2,
                                    x: 2, y: 2,
                                    blur: 10,
                                    spread: 0,
                                    cornerRadiusValue: 20)
        
    }
    
    // MARK: - Public Interfaces
    
    func configure(userAdressData: userAdressData?) {
        self.adressLabel.text = userAdressData?.name ?? ""
    }
    
    // MARK: - Drawing Constants
    
    private let checkBoxHeightAnchor: CGFloat = 25
    private let checkBoxWidthAnchor: CGFloat = 25
}

extension UIView {

    func applyShadowWithCornerRadius(color:UIColor, opacity:Float, radius: CGFloat, edge:AIEdge, shadowSpace:CGFloat)    {

        var sizeOffset:CGSize = CGSize.zero
        switch edge {
        case .Top:
            sizeOffset = CGSize(width: 0, height: -shadowSpace)
        case .Left:
            sizeOffset = CGSize(width: -shadowSpace, height: 0)
        case .Bottom:
            sizeOffset = CGSize(width: 0, height: shadowSpace)
        case .Right:
            sizeOffset = CGSize(width: shadowSpace, height: 0)


        case .Top_Left:
            sizeOffset = CGSize(width: -shadowSpace, height: -shadowSpace)
        case .Top_Right:
            sizeOffset = CGSize(width: shadowSpace, height: -shadowSpace)
        case .Bottom_Left:
            sizeOffset = CGSize(width: -shadowSpace, height: shadowSpace)
        case .Bottom_Right:
            sizeOffset = CGSize(width: shadowSpace, height: shadowSpace)


        case .All:
            sizeOffset = CGSize(width: 0, height: 0)
        case .None:
            sizeOffset = CGSize.zero
        }

        self.layer.cornerRadius = self.frame.size.height / 2
        self.layer.masksToBounds = true;

        self.layer.shadowColor = color.cgColor
        self.layer.shadowOpacity = opacity
        self.layer.shadowOffset = sizeOffset
        self.layer.shadowRadius = radius
        self.layer.masksToBounds = false

        self.layer.shadowPath = UIBezierPath(roundedRect:self.bounds, cornerRadius:self.layer.cornerRadius).cgPath
    }
}

enum AIEdge:Int {
    case
    Top,
    Left,
    Bottom,
    Right,
    Top_Left,
    Top_Right,
    Bottom_Left,
    Bottom_Right,
    All,
    None
}
