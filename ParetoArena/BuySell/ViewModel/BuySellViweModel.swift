//
//  BuySellViweModel.swift
//  Pareto
//
//

//import UIKit

class BuySellViweModel: BaseViewModel {
    var bars:((_ items: Bar) -> Void)?
    var result:((_ msg: String) -> Void)?
    var fav:(() -> Void)?
    var unFav:(() -> Void)?

    override init() {
        super.init()
        proxy = NetworkProxy()
        proxy.delegate = self
    }

    func getBars(symbol: String, timeFrame: String, start: String, end: String) {
        proxy.requestForBars(symbol: symbol, timeFrame: timeFrame, start: start, end: end)
    }

    func makeFav(symbol: String) {
        proxy.requestForFav(symbol: symbol)
    }

    func removeFav(symbol: String) {
        proxy.removeFav(symbol: symbol)
    }

    func Buy(symbol: String, notional: String, type: String) {
        proxy.requestForOrder(symbol: symbol, notional: notional, side: "buy", type: type, time: "day")
    }

    func Sell(symbol: String, notional: String, type: String) {
        proxy.requestForOrder(symbol: symbol, notional: notional, side: "sell", type: type, time: "day")
    }

    // MARK: - Delegate
    override func requestDidBegin() {
        super.requestDidBegin()
    }

    override func requestDidFinishedWithData(data: Any, reqType: RequestType) {
        super.requestDidFinishedWithData(data: data, reqType: reqType)

        switch reqType {
        case .markfav :

            if let item = data as? (String, String) {
                if item.0 != "" {
                    fav!()
                } else {
                    result!(item.1)
                }
            }
        case .deleteFav :
            if let item = data as? (String, String) {
                if item.0 != "" {
                    unFav!()
                } else {
                    result!(item.1)
                }
            }
        case .bars :

            if let item = data as? Bar {
                bars!(item)
            }

        default:

            if let msg = data as? String {
                if result == nil {
                    // result("")
                } else {
                    result!(msg)
                }
            }
        }
    }

    override func requestDidFailedWithError(error: String, reqType: RequestType) {
        super.requestDidFailedWithError(error: error, reqType: reqType)
        self.bindErrorViewModelToController(error) // If need error in View Controller
    }
}

//import Foundation
//import Combine
//
//class BuySellViewModel: ObservableObject {
//    @Published var bars: Bar?
//    @Published var result: String?
//    @Published var isFav: Bool = false
//    private var proxy = NetworkProxy()
//
//    init() {
//        proxy.delegate = self
//    }
//
//    func getBars(symbol: String, timeFrame: String, start: String, end: String) {
//        proxy.requestForBars(symbol: symbol, timeFrame: timeFrame, start: start, end: end)
//    }
//
//    func makeFav(symbol: String) {
//        proxy.requestForFav(symbol: symbol)
//    }
//
//    func removeFav(symbol: String) {
//        proxy.removeFav(symbol: symbol)
//    }
//
//    func buy(symbol: String, notional: String, type: String) {
//        proxy.requestForOrder(symbol: symbol, notional: notional, side: "buy", type: type, time: "day")
//    }
//
//    func sell(symbol: String, notional: String, type: String) {
//        proxy.requestForOrder(symbol: symbol, notional: notional, side: "sell", type: type, time: "day")
//    }
//}
//
//extension BuySellViewModel: NetworkProxyDelegate {
//    func requestDidBegin() {
//        // Handle any actions when request begins (e.g., show loading indicator)
//    }
//
//    func requestDidFinishedWithData(data: Any, reqType: RequestType) {
//        switch reqType {
//        case .markfav:
//            if let item = data as? (String, String) {
//                if item.0 != "" {
//                    isFav = true
//                } else {
//                    result = item.1
//                }
//            }
//        case .deleteFav:
//            if let item = data as? (String, String) {
//                if item.0 != "" {
//                    isFav = false
//                } else {
//                    result = item.1
//                }
//            }
//        case .bars:
//            if let item = data as? Bar {
//                bars = item
//            }
//        default:
//            if let msg = data as? String {
//                result = msg
//            }
//        }
//    }
//
//    func requestDidFailedWithError(error: String, reqType: RequestType) {
//        // Handle error in view model (e.g., show error message)
//    }
//}

