//
//  AllTypeCell.swift
//  rzq
//
//  Created by Zaid Khaled on 2/12/20.
//  Copyright © 2020 technzone. All rights reserved.
//

import UIKit
import Cosmos

class AllTypeCell: UICollectionViewCell {
    
    @IBOutlet weak var lblName: MyUILabel!
    
    @IBOutlet weak var viewLine: UIView!
    
    @IBOutlet weak var ivLogo: CircleImage!
    
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var ratingView: CosmosView!
}
