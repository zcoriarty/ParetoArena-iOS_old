//
//  Connection.swift
//  ParetoArena
//
//  Created by Zachary Coriarty on 9/15/23.
//

import SwiftUI

import Alamofire
//import BRYXBanner
import Foundation
import SystemConfiguration
import UIKit
struct NetworkState {
    var isInternetAvailable: Bool {
        return NetworkReachabilityManager()!.isReachable
    }
    static func showNetworkErrorView() {
        // show banner
//        var connectionBanner = Banner()
//        connectionBanner = Banner(title: "No Internet connection", subtitle: "Check your internet setting and try again.", image: UIImage(named: "noconnection"), backgroundColor: UIColor(red: 255 / 255, green: 0 / 255, blue: 0 / 255, alpha: 1))
//        connectionBanner.dismissesOnTap = true
//        connectionBanner.dismissesOnSwipe = true
//        connectionBanner.textColor = UIColor.white
//        connectionBanner.show(duration: 5.0)
    }
}
