//
//  ResponseStatus.swift
//  ParetoArena
//
//  Created by Zachary Coriarty on 9/15/23.
//

import SwiftUI

enum ResponseStatus {
    case idle
    case loading
    case success
    case failure(Error)
    case noData
}

extension ResponseStatus: Equatable {
    static func == (lhs: ResponseStatus, rhs: ResponseStatus) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle),
             (.loading, .loading),
             (.success, .success),
             (.failure, .failure),
             (.noData, .noData):
            return true
        default:
            return false
        }
    }
}
