//
//  ActionSheetLinkItemAppearance.swift
//  Sheeeeeeeeet
//
//  Created by Daniel Saidi on 2017-11-24.
//  Copyright © 2017 Daniel Saidi. All rights reserved.
//

import UIKit

open class ActionSheetLinkItemAppearance: ActionSheetItemAppearance {
    
    public override init() {
        super.init()
    }
    
    public override init(copy: ActionSheetItemAppearance) {
        super.init(copy: copy)
        let copy = copy as? ActionSheetLinkItemAppearance
        linkIcon = copy?.linkIcon
    }
    
    public var linkIcon: UIImage?
}
