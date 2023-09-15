//
//  Signup.swift
//  ParetoArena
//
//  Created by Zachary Coriarty on 9/15/23.
//

import Foundation
// MARK: - Signup
struct Signup: Codable {
    var token, expires, refreshToken: String?
    var user: User?

    enum CodingKeys: String, CodingKey {
        case token, expires
        case refreshToken = "refresh_token"
        case user
    }
}

// MARK: - Role
struct Role: Codable {
    let name: String
}

typealias UserData = Signup
