//
//  PortfolioOO.swift
//  Pareto
//
//  Created by Zachary Coriarty on 4/28/23.
//

import Foundation
import SwiftUI
import Combine
import SwiftUICharts


class PortfolioChartData: ObservableObject {
    @Published var equity = [Double]()
    @Published var timestamp = [String]()
    @Published var pNL = [Double]()
    @Published var lineColor: Color = Color.red
    @Published var totalValue: Double = 0
    
    init() {
        callApiPortFolioGraph(period: "1D", timeframe: "5Min")
        getportValueNoLoader()
    }
    
    @Sendable func refreshData() async {
        callApiPortFolioGraph(period: "1D", timeframe: "5Min")
        getportValueNoLoader()
    }

    
    func getportValueNoLoader() {
        let url = EndPoint.kServerBase + EndPoint.TradingView
        print(url)
        NetworkUtil.request(apiMethod: url, parameters: nil, requestType: .get, onSuccess: { resp -> Void in
            print(resp!)
            if let jsonObject = resp as? [String: Any] {
                let value = Double(jsonObject["portfolio_value"] as? String ?? "0000") ?? 0.0
                self.totalValue = value
            } else {
//                self.view.makeToast("Server Error")
            }
        }) { error in
            print(error)
//            self.view.makeToast(error)
        }
    }



    func callApiPortFolioGraph(period: String, timeframe: String) {
        let url = EndPoint.kServerBase + EndPoint.ordrHistory + "?timeframe="+timeframe + "&period="+period
        let params = ["period": period, "timeframe": timeframe] as [String: Any]
        print(url)
        print(params)

        NetworkUtil.request(apiMethod: url, parameters: nil, requestType: .get, onSuccess: { resp -> Void in
            print(resp!)
            self.equity.removeAll()
            var graphSum = 0.0
            if let object = resp as? [String: Any] {
                if let equity = object["equity"] as? NSArray,
                   let timestamp = object["timestamp"] as? NSArray,
                    let pNL = object["profit_loss_pct"] as? NSArray {
                    for index in 0..<equity.count {
                        let equityValue = Double(exactly: equity[index] as? NSNumber ?? 0_000)
                        graphSum += graphSum + (equityValue ?? 0.0)
                        self.equity.append(equityValue ?? 0.0)
                        
                        let timestampValue = Double(exactly: timestamp[index] as? NSNumber ?? 0_000)
//                        let formattedTimestamp = self.formatTimestamp(timestampValue ?? 0, period: period)
                        self.timestamp.append(String(timestampValue ?? 0.0))

                        
                        let pnlPct = Double(exactly: pNL[index] as? NSNumber ?? 0_0000)
                        self.pNL.append(pnlPct ?? 0.0000)
                        
                    }
                }
            } else {
                if let message = resp as? NSDictionary {
                    let _ = message["message"] as? String
//                    self.view.makeToast(message1)
                }
            }
            print(self.equity.count)
            if graphSum > 0 {
                let change = self.equity.last! - self.equity.first!
                self.lineColor = change > 0 ? Color.green : Color.red
//                self.timeframeStack.backgroundColor = self.lineColor.withAlphaComponent(0.35)

//                SwiftParseUtils.parsePortfolioSecondData(object: self.equity, xObject: self.timestamp, pnlPct: self.pNL, lineColor: self.lineColor, view: self.view, graph: self.piechartView)
            }
    
        }) { error in
            print(error)
        }
    }
    
    func updateChartData(selectedRange: Int) {
        let timeFrame: String
        let period: String
        print("here")
        
        switch selectedRange {
        case 0:
            timeFrame = "5Min"
            period = "1D"
        case 1:
            timeFrame = "1H"
            period = "1W"
        case 2:
            timeFrame = "1D"
            period = "1M"
        case 3:
            timeFrame = "1D"
            period = "3M"
        case 4:
            timeFrame = "1D"
            period = "1A"
        default:
            timeFrame = "10Min"
            period = "1D"
        }
        
        
        callApiPortFolioGraph(period: period, timeframe: timeFrame)
    }
    
    func formatTimestamp(_ timestamp: Double, period: String) -> String {
        let date = Date(timeIntervalSince1970: timestamp)
        let dateFormatter = DateFormatter()

        switch period {
        case "1D":
            dateFormatter.dateFormat = "h:mm a"
        case "1W":
            dateFormatter.dateFormat = "MM-dd'T' h:mm a"
        case "1M", "3M", "1A":
            dateFormatter.dateFormat = "yyyy-MM-dd"
        default:
            dateFormatter.dateFormat = "yyyy-MM-dd"
        }

        return dateFormatter.string(from: date)
    }


}



class WatchlistViewModel: ObservableObject {
    @Published var holdings: [NewCurrentStock] = []
    @Published var watching: [String: [NewCurrentStock]] = [:]
    @Published var holdingsKeys: [String] = []
    @Published var watchingKeys: [String] = []
    @Published var watchlistDict: [String: String] = [:]
    
    init() {
        getfavoritedStocks()
        getPositions()
    }
    
    @Sendable func refreshData() async {
        getfavoritedStocks()
        getPositions()
    }

    

    func getPositions() {
        var positions = [NewCurrentStock]()
        let dispatchGroup = DispatchGroup()
        
        let url = EndPoint.kServerBase + EndPoint.positions
        
        dispatchGroup.enter()
        NetworkUtil.request(apiMethod: url, parameters: nil, requestType: .get, onSuccess: { [weak self] resp -> Void in
            guard self != nil else { return }
            if let jsonArray = resp as? [[String: Any]] {
                do {
                    let decoder = JSONDecoder()
                    let portfolioResponseData = try JSONSerialization.data(withJSONObject: jsonArray, options: [])
                    let newCurrentStockArray = try decoder.decode([NewCurrentStock].self, from: portfolioResponseData)
                    positions = newCurrentStockArray
                } catch {
                    print("Error decoding JSON: \(error)")
                }
            } else {
            }
            dispatchGroup.leave()
        }
) { error in
            dispatchGroup.leave()
        }
        dispatchGroup.notify(queue: .main) {
            self.holdings = positions
        }
    }
    
    
    func getfavoritedStocks() {
        let url = EndPoint.kServerBase + EndPoint.allWatchlists
        NetworkUtil.request(apiMethod: url, parameters: nil, requestType: .get, onSuccess: { [weak self] resp -> Void in
            guard let self = self, let watchlistData = resp as? [[String: Any]] else { return }
            for watchlist in watchlistData {
                if let watchlistId = watchlist["id"] as? String, let watchlistName = watchlist["name"] as? String {
                    self.watchlistDict[watchlistName] = watchlistId
                }
            }
            let watchlistIds = self.watchlistDict.map { $0.value }
            self.populateWatching(with: watchlistIds)
        }) { error in
            print(error)
        }
    }

    func populateWatching(with watchlistIds: [String]) {
        var watchingDict = [String: [NewCurrentStock]]()
        let dispatchGroup = DispatchGroup()

        for watchlistId in watchlistIds {
            let url = EndPoint.kServerBase + EndPoint.watchlist.replacingOccurrences(of: "{watchlist_id}", with: watchlistId)

            dispatchGroup.enter()
            NetworkUtil.request(apiMethod: url, parameters: nil, requestType: .get, onSuccess: { [weak self] resp -> Void in
                if let jsonObject = resp as? [String: Any] {
                    do {
                        let decoder = JSONDecoder()
                        let portfolioResponseData = try JSONSerialization.data(withJSONObject: jsonObject, options: [])
                        let portfolioResponse = try decoder.decode(PortfolioResponse.self, from: portfolioResponseData)
                        watchingDict[portfolioResponse.name ?? "error"] = portfolioResponse.assets.compactMap { $0 }
                    } catch {
                        print("Error decoding JSON: \(error)")
                    }
                }
                dispatchGroup.leave()
            }) { error in
                print(error)
                dispatchGroup.leave()
            }
        }

        dispatchGroup.notify(queue: .main) {
            self.watching = watchingDict
            self.watchingKeys = Array(watchingDict.keys)
            
        }
    }


    
    
}

