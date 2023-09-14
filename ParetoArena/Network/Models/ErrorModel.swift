//
//  ErrorModel.swift
//  Pareto
//
//

import Foundation
// MARK: - ErrorModel
struct ErrorModel: Codable {
    let message: String?
    let errors: Errors?
}

// MARK: - Errors
struct Errors: Codable {
}
