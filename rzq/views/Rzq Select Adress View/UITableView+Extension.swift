//
//  UITableView+Extension.swift
//  rzq
//
//  Created by Said Elmansour on 2021-05-03.
//  Copyright © 2021 technzone. All rights reserved.
//

import UIKit

extension UITableView {
    
    /// Resgister a cell
    /// - Parameter identifier: Cell Identifier
    func registerCell(identifier: String) {
        self.register(UINib(nibName: identifier, bundle: nil), forCellReuseIdentifier: identifier)
    }
    
    /// Register Header View
    /// - Parameter identifier: Header Identifier
    func registerHeader(identifier: String) {
        self.register(UINib(nibName: identifier, bundle: nil), forHeaderFooterViewReuseIdentifier: identifier)
    }
}

