//
//  StoreMarkerView.swift
//  rzq
//
//  Created by Said Elmansour on 2020-12-08.
//  Copyright © 2020 technzone. All rights reserved.
//

import UIKit

class StoreMarkerView: UIView {

    @IBOutlet weak var storiImaView: UIImageView!
   
    @IBOutlet weak var shopNameHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var ShopNameStackView: UIStackView!
    @IBOutlet weak var shopeNameLabel: UILabel!
   
    class func instanceFromNib() -> StoreMarkerView {
        return UINib(nibName: "StoreMarkerView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! StoreMarkerView
      }
}
