//
//  UITabBar+Ext.swift
//  Pareto
//
//  Created by Zachary Coriarty on 5/1/23.
//

import UIKit

extension UITabBar {
    func updateAppearance() {
        let userInterfaceStyle = self.traitCollection.userInterfaceStyle
        unselectedItemTintColor = userInterfaceStyle == .dark ? .systemBackground : .secondaryLabel
        tintColor = .label
        backgroundImage = UIImage()
        shadowImage = UIImage()
        backgroundColor = userInterfaceStyle == .dark ? .systemBackground : .label
    }
}

