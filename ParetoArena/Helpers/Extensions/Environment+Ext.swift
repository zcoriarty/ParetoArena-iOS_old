//
//  Environment+Ext.swift
//  Pareto
//
//  Created by Zachary Coriarty on 5/1/23.
//

import SwiftUI

struct IsSheetVisibleKey: EnvironmentKey {
    static let defaultValue: Binding<Bool>? = nil
}

extension EnvironmentValues {
    var isSheetVisible: Binding<Bool>? {
        get { self[IsSheetVisibleKey.self] }
        set { self[IsSheetVisibleKey.self] = newValue }
    }
}
