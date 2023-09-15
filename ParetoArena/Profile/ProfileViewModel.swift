//
// ProfileViewModel.swift
// Pareto
//
//

import UIKit

class ProfileViewModel: BaseViewModel {
    var stocks: ((_ items: [Asset]) -> Void)?

    override init() {
        super.init()
        proxy = NetworkProxy()
        proxy.delegate = self
    }

    func watchList() {
        proxy.requestForWatchList()
    }

    func myStocks() {
        proxy.requestForPositions()
    }

    override func requestDidBegin() {
        super.requestDidBegin()
    }
    override func requestDidFinishedWithData(data: Any, reqType: RequestType) {
        super.requestDidFinishedWithData(data: data, reqType: reqType)
        if let items = data as? Stocks, let list = items.assets {
            stocks!(list)
        }
//        if let res = data as? [PlaidAccount], let item = res.first {
//            USER.shared.accountDetail = item
//            bindViewModelToController()
//        }
    }
    override func requestDidFailedWithError(error: String, reqType: RequestType) {
        super.requestDidFailedWithError(error: error, reqType: reqType)
        self.bindErrorViewModelToController(error) // If need error in View Controller
    }
}
