//
//  NSObject+Ext.swift
//  Pareto
//
//

import Foundation

extension NSObject {
    static var identifier: String {
        return NSStringFromClass(self).components(separatedBy: ".").last ?? ""
    }

    var stringFromInstance: String {
        return NSStringFromClass(type(of: self)).components(separatedBy: ".").last ?? ""
    }
}
