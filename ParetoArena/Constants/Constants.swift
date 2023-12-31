//
//  Constants.swift
//  Pareto
//
//

import Foundation
import UIKit

struct Constants {
    static let ServerError = "Server not responding"
}
enum STEPS: String {
    case referral, name, phone, dob, address, citizenship, verifyidentity, ssn, investingexperience, funding, employed, shareholder, brokerage, complete
}
enum EmploymentStatus: String {
    case employed, unemployed, retired, student
}
extension Notification {
    static let bankConnected = Notification.Name("bankconnected")
    static let bankDisConnected = Notification.Name("bankDisconnected")
}
