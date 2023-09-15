//
//  Shares.swift
//  Pareto
//
//

import Foundation
struct Share: Codable {
    let o: Float
    let c: Float
    let t: String
}
struct Bar: Codable {
    let bars: [Share]
}
