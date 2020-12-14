//
//  MarkerInfo.swift
//  rzq
//
//  Created by Said Elmansour on 2020-12-14.
//  Copyright © 2020 technzone. All rights reserved.
//

import UIKit

class MarkerInfo: UIView {

    @IBOutlet weak var storeNameLabel: UILabel!
    @IBOutlet weak var markerImageView: UIImageView!
    
    class func instanceFromNib() -> MarkerInfo {
        return UINib(nibName: "MarkerInfo", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! MarkerInfo
      }

}
