//
//  ActionSheetMultiSelectToggleItemAppearance.swift
//  Sheeeeeeeeet
//
//  Created by Daniel Saidi on 2018-03-31.
//  Copyright © 2018 Daniel Saidi. All rights reserved.
//

import UIKit

open class ActionSheetMultiSelectToggleItemAppearance: ActionSheetItemAppearance {
    
    public override init() {
        super.init()
    }
    
    public override init(copy: ActionSheetItemAppearance) {
        super.init(copy: copy)
        let copy = copy as? ActionSheetMultiSelectToggleItemAppearance
        deselectAllTextColor = copy?.deselectAllTextColor
        selectAllTextColor = copy?.selectAllTextColor
    }
    
    public var deselectAllTextColor: UIColor?
    public var selectAllTextColor: UIColor?
}
