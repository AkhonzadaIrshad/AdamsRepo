//
//  UINib+Loader.swift
//  rzq
//
//  Created by Said Elmansour on 2021-05-03.
//  Copyright © 2021 technzone. All rights reserved.
//

import UIKit

// MARK: - Loader Method

extension UINib {

    /// Load Nib with name
    ///
    /// - Parameter nibName: Nib name
    /// - Returns: UINib
    static func nib(named nibName: String) -> UINib {
        UINib(nibName: nibName, bundle: nil)
    }

    /// Load Nib with name and attach it to owner
    ///
    /// - Parameters:
    ///   - nibName: Nib name
    ///   - owner: Owner
    /// - Returns: UINib
    static func loadSingleView(_ nibName: String, owner: Any?) -> UIView {
        // swiftlint:disable:next force_cast
        nib(named: nibName).instantiate(withOwner: owner, options: nil)[0] as! UIView
    }
}
