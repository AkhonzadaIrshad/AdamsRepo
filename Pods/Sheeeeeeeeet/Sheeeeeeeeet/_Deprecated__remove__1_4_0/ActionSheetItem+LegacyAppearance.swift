//
//  ActionSheetItem+LegacyAppearance.swift
//  Sheeeeeeeeet
//
//  Created by Daniel Saidi on 2019-01-10.
//  Copyright © 2019 Daniel Saidi. All rights reserved.
//

import UIKit

extension ActionSheetItem {
    
    func applyLegacyAppearance(to cell: UITableViewCell) {
        applyLegacyBackgroundColor(to: cell)
        applyLegacyFont(to: cell)
        applyLegacyLinkItemAppearance(to: cell)
        applyLegacyMultiSelectToggleItemAppearance(to: cell)
        applyLegacySelectItemAppearance(to: cell)
        applyLegacySeparatorInsets(to: cell)
        applyLegacySubtitleFont(to: cell)
        applyLegacySubtitleTextColor(to: cell)
        applyLegacyTextColor(to: cell)
        applyLegacyTintColor(to: cell)
    }
}

private extension ActionSheetItem {
    
    func applyLegacyBackgroundColor(to cell: UITableViewCell) {
        guard let color = appearance.backgroundColor else { return }
        let cell = cell as? ActionSheetItemCell
        cell?.backgroundColor = color
    }
    
    func applyLegacyFont(to cell: UITableViewCell) {
        guard let font = appearance.font else { return }
        let cell = cell as? ActionSheetItemCell
        cell?.titleFont = font
    }
    
    func applyLegacyLinkItemAppearance(to cell: UITableViewCell) {
        guard let cell = cell as? ActionSheetLinkItemCell else { return }
        guard let appearance = appearance as? ActionSheetLinkItemAppearance else { return }
        if let icon = appearance.linkIcon { cell.linkIcon = icon }
    }
    
    func applyLegacyMultiSelectToggleItemAppearance(to cell: UITableViewCell) {
        guard let cell = cell as? ActionSheetMultiSelectToggleItemCell else { return }
        guard let appearance = appearance as? ActionSheetMultiSelectToggleItemAppearance else { return }
        if let color = appearance.deselectAllTextColor { cell.deselectAllSubtitleColor = color }
        if let color = appearance.selectAllTextColor { cell.selectAllSubtitleColor = color }
    }
    
    func applyLegacySelectItemAppearance(to cell: UITableViewCell) {
        guard let cell = cell as? ActionSheetSelectItemCell else { return }
        guard let appearance = appearance as? ActionSheetSelectItemAppearance else { return }
        if let icon = appearance.selectedIcon { cell.selectedIcon = icon }
        if let color = appearance.selectedIconTintColor { cell.selectedIconColor = color }
        if let color = appearance.selectedTextColor { cell.selectedTitleColor = color }
        if let color = appearance.selectedTintColor { cell.selectedTintColor = color }
        if let icon = appearance.unselectedIcon { cell.unselectedIcon = icon }
    }
    
    func applyLegacySeparatorInsets(to cell: UITableViewCell) {
        guard let insets = appearance.separatorInsets else { return }
        cell.separatorInset = insets
    }
    
    func applyLegacySubtitleFont(to cell: UITableViewCell) {
        guard let font = appearance.subtitleFont else { return }
        let cell = cell as? ActionSheetItemCell
        cell?.subtitleFont = font
    }
    
    func applyLegacySubtitleTextColor(to cell: UITableViewCell) {
        guard let color = appearance.subtitleTextColor else { return }
        let cell = cell as? ActionSheetItemCell
        cell?.subtitleColor = color
    }
    
    func applyLegacyTextColor(to cell: UITableViewCell) {
        guard let color = appearance.textColor else { return }
        let cell = cell as? ActionSheetItemCell
        cell?.titleColor = color
    }
    
    func applyLegacyTintColor(to cell: UITableViewCell) {
        guard let color = appearance.tintColor else { return }
        let cell = cell as? ActionSheetItemCell
        cell?.tintColor = color
    }
}
