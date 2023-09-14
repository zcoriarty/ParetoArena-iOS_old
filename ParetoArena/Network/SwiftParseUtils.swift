//
// SwiftParseUtils.swift
// Pareto
//
//
import Charts
import Foundation
import SwiftyRSA
import UIKit

class SwiftParseUtils {
    
    
    // MARK: - Parse forgot password Api

    static func parseForgotPasswordData(object: [String: Any], view: UIView) -> String {
        var message: String = ""
        message = object["message"] as? String ?? ""
        return message
    }

    // MARK: - Parse Watchlist Api

    static func parseWatchListData(object: [String: Any], view: UIView) -> NSMutableArray {
        let stocksArray: NSMutableArray = []
        var ids: String? = ""
        var symbol: String? = ""
        var name: String? = ""
        var status: String? = ""
        var price: String? = ""
        let plp: String? = ""
        var isWatchlisted: Bool? = false
        if let object = object["assets"] as? [[String: Any]] {
            for dict in object {
                name = dict["name"] as? String
                name = name?.replacingOccurrences(of: "Class A Common Stock", with: "")
                name = name?.replacingOccurrences(of: "Common Stock", with: "")
                name = name?.replacingOccurrences(of: "Class C Capital Stock", with: "")
                symbol = dict["symbol"] as? String
                ids = dict["id"] as? String
                status = dict["status"] as? String
                isWatchlisted = dict["is_watchlisted"] as? Bool
                if let ticker = dict["ticker"] as? [String: Any] {
                    if let latestTrade = ticker["latestTrade"] as? [String: Any] {
                        let pri = latestTrade["p"] as? Double
                        price = String(format: "%.2f", pri ?? 100.00)
                    } else {
                        price = "100"
                    }
                } else {
                    price = "100"
                }
                let obj = StockTicker(ids: ids ?? "", symbol: symbol ?? "", name: name ?? "", status: status ?? "", price: price ?? "", plp: plp ?? "", open: "0", high: "0", low: "0", volume: "0", isWatchlisted: isWatchlisted ?? false, prevDailyBar: nil)

                stocksArray.add(obj)
            }
        } else {
            view.makeToast("Server Error")
        }
        return stocksArray
    }
    
    static func parseWatchListDataNoView(object: [String: Any], view: UIView) -> NSMutableArray {
        let stocksArray: NSMutableArray = []
        var ids: String? = ""
        var symbol: String? = ""
        var name: String? = ""
        var status: String? = ""
        var price: String? = ""
        let plp: String? = ""
        var isWatchlisted: Bool? = false
        if let object = object["assets"] as? [[String: Any]] {
            for dict in object {
                name = dict["name"] as? String
                name = name?.replacingOccurrences(of: "Class A Common Stock", with: "")
                name = name?.replacingOccurrences(of: "Common Stock", with: "")
                name = name?.replacingOccurrences(of: "Class C Capital Stock", with: "")
                symbol = dict["symbol"] as? String
                ids = dict["id"] as? String
                status = dict["status"] as? String
                isWatchlisted = dict["is_watchlisted"] as? Bool
                if let ticker = dict["ticker"] as? [String: Any] {
                    if let latestTrade = ticker["latestTrade"] as? [String: Any] {
                        let pri = latestTrade["p"] as? Double
                        price = String(format: "%.2f", pri ?? 100.00)
                    } else {
                        price = "100"
                    }
                } else {
                    price = "100"
                }
                let obj = StockTicker(ids: ids ?? "", symbol: symbol ?? "", name: name ?? "", status: status ?? "", price: price ?? "", plp: plp ?? "", open: "0", high: "0", low: "0", volume: "0", isWatchlisted: isWatchlisted ?? false, prevDailyBar: nil)

                stocksArray.add(obj)
            }
        } else {
            view.makeToast("Server Error")
        }
        return stocksArray
    }

    // MARK: - Parse portfolio Api

    static func parsePortfolioData(object: [String: Any], view: UIView) -> String {
        let doubleValue = Double(object["portfolio_value"] as? String ?? "0000") ?? 0.0
        let stringValue = String(format: "%.2f", doubleValue)
        let finalValue = "$" + stringValue
        return finalValue
    }


    // MARK: - Parse postion Api

    static func parsePositionListData(object: [[String: Any]], view: UIView) -> NSMutableArray {
        let stocksArray: NSMutableArray = []
        var assetId: String? = ""
        var symbol: String? = ""
        var unrealizedPlpc: String? = ""
        var unrealizedPl: String? = ""
        var marketValue: String? = ""
        var currentPrice: String? = ""
        var qty: String? = ""
        var avgEntryPrice: String? = ""
        var changeToday: String? = ""
        var costBasis: Bool? = false
        var exchange: String? = ""
        var open: String? = "0"
        var high: String? = "0"
        var low: String? = "0"
        var volume: String? = "0"
        for dict in object {
            assetId = dict["asset_id"] as? String
            symbol = dict["symbol"] as? String
            unrealizedPlpc = dict["unrealized_plpc"] as? String
            unrealizedPl = dict["unrealized_pl"] as? String
            marketValue = dict["market_value"] as? String
            currentPrice = dict["current_price"] as? String
            qty = dict["qty"] as? String
            avgEntryPrice = dict["current_price"] as? String
            changeToday = dict["change_today"] as? String
            costBasis = dict["is_watchlisted"] as? Bool
            exchange = dict["name"] as? String
            exchange = exchange?.replacingOccurrences(of: "Class A Common Stock", with: "")
            exchange = exchange?.replacingOccurrences(of: "Common Stock", with: "")
            exchange = exchange?.replacingOccurrences(of: "Class C Capital Stock", with: "")
            if let ticker = dict["ticker"] as? [String: Any] {
                if let dailyBar = ticker["dailyBar"] as? [String: Any] {
                    let ope = dailyBar["o"] as? Double
                    let hig = dailyBar["h"] as? Double
                    let lowwer = dailyBar["l"] as? Double
                    let vol = dailyBar["v"] as? Double
                    open = String(format: "%.2f", ope ?? 100.00)
                    high = String(format: "%.2f", hig ?? 100.00)
                    low = String(format: "%.2f", lowwer ?? 100.00)
                    volume = String(format: "%.2f", vol ?? 100.00)
                } else {
                    open = "100"
                    high = "100"
                    low = "100"
                    volume = "100"
                }
            } else {
                open = "100"
                high = "100"
                low = "100"
                volume = "100"
            }

            let obj = MyStock(assetId: assetId ?? "", symbol: symbol ?? "", unrealizedPlpc: unrealizedPlpc ?? "", unrealizedPl: unrealizedPl ?? "", marketValue: marketValue ?? "", currentPrice: currentPrice ?? "", qty: qty ?? "", avgEntryPrice: avgEntryPrice ?? "", changeToday: changeToday ?? "", costBasis: costBasis ?? false, exchange: exchange ?? "", open: open ?? "", high: high ?? "", low: low ?? "", volume: volume ?? "")

            stocksArray.add(obj)
        }
        return stocksArray
    }

    
    
    static func parseSnapshot(object: [String: Any], symbol: String, view: UIView?) -> Snapshot {
        let snapshot = Snapshot()
        let tickerData = SnapshotData()
        
        if let dailyBar = object["dailyBar"] as? [String: Any] {
            let dailyBarData = DailyBarSnapshot()
            dailyBarData.o = (dailyBar["o"] as? Double).map { String(format: "%.2f", $0) } ?? "100.00"
            dailyBarData.h = (dailyBar["h"] as? Double).map { String(format: "%.2f", $0) } ?? "100.00"
            dailyBarData.l = (dailyBar["l"] as? Double).map { String(format: "%.2f", $0) } ?? "100.00"
            dailyBarData.c = (dailyBar["c"] as? Double).map { String(format: "%.2f", $0) } ?? "100.00"
            dailyBarData.n = (dailyBar["n"] as? Int).map { String($0) } ?? "100"
            dailyBarData.t = (dailyBar["t"] as? Int).map { String($0) } ?? "100"
            dailyBarData.v = (dailyBar["v"] as? Double).map { String(format: "%.2f", $0) } ?? "100.00"
            dailyBarData.vw = (dailyBar["vw"] as? Double).map { String(format: "%.2f", $0) } ?? "100.00"
            tickerData.dailyBar = dailyBarData
        }
        
        if let latestQuote = object["latestQuote"] as? [String: Any] {
            let latestQuoteData = LatestQuoteSnapshot()
            latestQuoteData.ap = (latestQuote["ap"] as? Double).map { String($0) } ?? ""
            latestQuoteData._as = (latestQuote["as"] as? Int).map { String($0) } ?? "100"
            latestQuoteData.ax = latestQuote["ax"] as? String ?? ""
            latestQuoteData.bp = (latestQuote["bp"] as? Double).map { String($0) } ?? ""
            latestQuoteData.bs = (latestQuote["bs"] as? Int).map { String($0) } ?? "100"
            latestQuoteData.bx = latestQuote["bx"] as? String ?? ""
            latestQuoteData.c = latestQuote["c"] as? [String] ?? []
            latestQuoteData.t = latestQuote["t"] as? String ?? ""
            latestQuoteData.z = latestQuote["z"] as? String ?? ""
            tickerData.latestQuote = latestQuoteData
        }
        
        if let latestTrade = object["latestTrade"] as? [String: Any] {
            let latestTradeData = LatestTradeSnapshot()
            latestTradeData.c = latestTrade["c"] as? [String] ?? []
            latestTradeData.i = (latestTrade["i"] as? Int).map { String($0) } ?? "100"
            latestTradeData.p = (latestTrade["p"] as? Double).map { String($0) } ?? ""
            latestTradeData.s = (latestTrade["s"] as? Int).map { String($0) } ?? "100"
            latestTradeData.t = latestTrade["t"] as? String ?? ""
            latestTradeData.x = latestTrade["x"] as? String ?? ""
            latestTradeData.z = latestTrade["z"] as? String ?? ""
            tickerData.latestTrade = latestTradeData
        }
        
        if let minuteBar = object["minuteBar"] as? [String: Any] {
            let minuteBarData = MinuteBarSnapshot()
            minuteBarData.c = (minuteBar["c"] as? Double).map { String($0) } ?? ""
            minuteBarData.h = (minuteBar["h"] as? Double).map { String($0) } ?? ""
            minuteBarData.l = (minuteBar["l"] as? Double).map { String($0) } ?? ""
            minuteBarData.n = (minuteBar["n"] as? Int).map { String($0) } ?? "100"
            minuteBarData.o = (minuteBar["o"] as? Double).map { String($0) } ?? ""
            minuteBarData.t = minuteBar["t"] as? String ?? ""
            minuteBarData.v = (minuteBar["v"] as? Int).map { String($0) } ?? "100"
            minuteBarData.vw = (minuteBar["vw"] as? Double).map { String($0) } ?? ""
            tickerData.minuteBar = minuteBarData
        }
        if let prevDailyBar = object["prevDailyBar"] as? [String: Any] {
            let prevDailyBarData = PrevDailyBarSnapshot()
            prevDailyBarData.c = (prevDailyBar["c"] as? Double).map { String($0) } ?? ""
            prevDailyBarData.h = (prevDailyBar["h"] as? Double).map { String($0) } ?? ""
            prevDailyBarData.l = (prevDailyBar["l"] as? Double).map { String($0) } ?? ""
            prevDailyBarData.n = (prevDailyBar["n"] as? Int).map { String($0) } ?? "100"
            prevDailyBarData.o = (prevDailyBar["o"] as? Double).map { String($0) } ?? ""
            prevDailyBarData.t = prevDailyBar["t"] as? String ?? ""
            prevDailyBarData.v = (prevDailyBar["v"] as? Double).map { String($0) } ?? ""
            prevDailyBarData.vw = (prevDailyBar["vw"] as? Double).map { String($0) } ?? ""
            tickerData.prevDailyBar = prevDailyBarData
        }
        
        snapshot.symbol = symbol
        snapshot.data = tickerData
        return snapshot
    }

    
    
    // for watchlisted items
    static func parseCurrentStock(object: [String: Any]) -> NSMutableArray {
        let stocksArray: NSMutableArray = []
        if let assets = object["assets"] as? [[String: Any]] {
            for asset in assets {
                var name = asset["name"] as? String
                name = name?.replacingOccurrences(of: "Class A Common Stock", with: "")
                name = name?.replacingOccurrences(of: "Common Stock", with: "")
                
                name = name?.replacingOccurrences(of: "Class C Capital Stock", with: "")
                
                let currentStock = CurrentStock()
                currentStock.assetClass = asset["asset_class"] as? String
                currentStock.assetID = asset["asset_id"] as? String
                currentStock.assetMarginable = asset["asset_marginable"] as? String
                currentStock.avgEntryPrice = asset["avg_entry_price"] as? String
                currentStock.changeToday = asset["change_today"] as? String
                currentStock.costBasis = asset["cost_basis"] as? String
                currentStock.currentPrice = asset["current_price"] as? String
                currentStock.exchange = asset["exchange"] as? String
                currentStock.isWatchlisted = asset["is_watchlisted"] as? Bool
                currentStock.lastdayPrice = asset["lastday_price"] as? String
                currentStock.marketValue = asset["market_value"] as? String
                currentStock.name = name
                currentStock.qty = asset["qty"] as? String
                currentStock.qtyAvailable = asset["qty_available"] as? String
                currentStock.side = asset["side"] as? String
                currentStock.symbol = asset["symbol"] as? String
                
                if let ticker = asset["ticker"] as? [String: Any] {
                    let tickerData = TickerData()
                    if let dailyBar = ticker["dailyBar"] as? [String: Any] {
                        let dailyBarData = DailyBarData()
                        dailyBarData.o = (dailyBar["o"] as? Double).map { String(format: "%.2f", $0) } ?? "100.00"
                        dailyBarData.h = (dailyBar["h"] as? Double).map { String(format: "%.2f", $0) } ?? "100.00"
                        dailyBarData.l = (dailyBar["l"] as? Double).map { String(format: "%.2f", $0) } ?? "100.00"
                        dailyBarData.c = (dailyBar["c"] as? Double).map { String(format: "%.2f", $0) } ?? "100.00"
                        dailyBarData.n = (dailyBar["n"] as? Int).map { String($0) } ?? "100"
                        dailyBarData.t = (dailyBar["t"] as? Int).map { String($0) } ?? "100"
                        dailyBarData.v = (dailyBar["v"] as? Double).map { String(format: "%.2f", $0) } ?? "100.00"
                        dailyBarData.vw = (dailyBar["vw"] as? Double).map { String(format: "%.2f", $0) } ?? "100.00"
                        tickerData.dailyBar = dailyBarData
                    }
                    print("CLOSE2", tickerData.dailyBar?.c)
                    
                    if let latestQuote = ticker["latestQuote"] as? [String: Any] {
                        let latestQuoteData = LatestQuoteData()
                        latestQuoteData.ap = (latestQuote["ap"] as? Double).map { String($0) } ?? ""
                        latestQuoteData._as = (latestQuote["as"] as? Int).map { String($0) } ?? "100"
                        latestQuoteData.ax = latestQuote["ax"] as? String ?? ""
                        latestQuoteData.bp = (latestQuote["bp"] as? Double).map { String($0) } ?? ""
                        latestQuoteData.bs = (latestQuote["bs"] as? Int).map { String($0) } ?? "100"
                        latestQuoteData.bx = latestQuote["bx"] as? String ?? ""
                        latestQuoteData.c = latestQuote["c"] as? [String] ?? []
                        latestQuoteData.t = latestQuote["t"] as? String ?? ""
                        latestQuoteData.z = latestQuote["z"] as? String ?? ""
                        tickerData.latestQuote = latestQuoteData
                    }
                    
                    if let latestTrade = ticker["latestTrade"] as? [String: Any] {
                        let latestTradeData = LatestTradeData()
                        latestTradeData.c = latestTrade["c"] as? [String] ?? []
                        latestTradeData.i = (latestTrade["i"] as? Int).map { String($0) } ?? "100"
                        latestTradeData.p = (latestTrade["p"] as? Double).map { String($0) } ?? ""
                        latestTradeData.s = (latestTrade["s"] as? Int).map { String($0) } ?? "100"
                        latestTradeData.t = latestTrade["t"] as? String ?? ""
                        latestTradeData.x = latestTrade["x"] as? String ?? ""
                        latestTradeData.z = latestTrade["z"] as? String ?? ""
                        tickerData.latestTrade = latestTradeData
                    }
                    
                    if let minuteBar = ticker["minuteBar"] as? [String: Any] {
                        let minuteBarData = MinuteBarData()
                        minuteBarData.c = (minuteBar["c"] as? Double).map { String($0) } ?? ""
                        minuteBarData.h = (minuteBar["h"] as? Double).map { String($0) } ?? ""
                        minuteBarData.l = (minuteBar["l"] as? Double).map { String($0) } ?? ""
                        minuteBarData.n = (minuteBar["n"] as? Int).map { String($0) } ?? "100"
                        minuteBarData.o = (minuteBar["o"] as? Double).map { String($0) } ?? ""
                        minuteBarData.t = minuteBar["t"] as? String ?? ""
                        minuteBarData.v = (minuteBar["v"] as? Int).map { String($0) } ?? "100"
                        minuteBarData.vw = (minuteBar["vw"] as? Double).map { String($0) } ?? ""
                        tickerData.minuteBar = minuteBarData
                    }
                    if let prevDailyBar = ticker["prevDailyBar"] as? [String: Any] {
                        let prevDailyBarData = PrevDailyBarData()
                        prevDailyBarData.c = (prevDailyBar["c"] as? Double).map { String($0) } ?? ""
                        prevDailyBarData.h = (prevDailyBar["h"] as? Double).map { String($0) } ?? ""
                        prevDailyBarData.l = (prevDailyBar["l"] as? Double).map { String($0) } ?? ""
                        prevDailyBarData.n = (prevDailyBar["n"] as? Int).map { String($0) } ?? "100"
                        prevDailyBarData.o = (prevDailyBar["o"] as? Double).map { String($0) } ?? ""
                        prevDailyBarData.t = prevDailyBar["t"] as? String ?? ""
                        prevDailyBarData.v = (prevDailyBar["v"] as? Double).map { String($0) } ?? ""
                        prevDailyBarData.vw = (prevDailyBar["vw"] as? Double).map { String($0) } ?? ""
                        tickerData.prevDailyBar = prevDailyBarData
                    }
                    currentStock.ticker = tickerData
                }
            


                currentStock.unrealizedStringradayPL = asset["unrealized_intraday_pl"] as? String
                currentStock.unrealizedStringradayPLPC = asset["unrealized_intraday_plpc"] as? String
                currentStock.unrealizedPL = asset["unrealized_pl"] as? String
                currentStock.unrealizedPLPC = asset["unrealized_plpc"] as? String

                print("BIUBKNBNMUI", currentStock.ticker?.dailyBar?.c)
                stocksArray.add(currentStock)
            }
        } else {
//            view?.makeToast("Server Error")
        }
        return stocksArray
    }
    
    
    // for positions held
    static func parseHoldingsCurrentStock(object: [[String: Any]]) -> NSMutableArray {
        let stocksArray: NSMutableArray = []
        for asset in object {
            var name = asset["name"] as? String
            name = name?.replacingOccurrences(of: "Class A Common Stock", with: "")
            name = name?.replacingOccurrences(of: "Common Stock", with: "")
            name = name?.replacingOccurrences(of: "Class C Capital Stock", with: "")
            
            let currentStock = CurrentStock()
            currentStock.assetClass = asset["asset_class"] as? String
            currentStock.assetID = asset["asset_id"] as? String
            currentStock.assetMarginable = asset["asset_marginable"] as? String
            currentStock.avgEntryPrice = asset["avg_entry_price"] as? String
            currentStock.changeToday = asset["change_today"] as? String
            currentStock.costBasis = asset["cost_basis"] as? String
            currentStock.currentPrice = asset["current_price"] as? String
            currentStock.exchange = asset["exchange"] as? String
            currentStock.isWatchlisted = asset["is_watchlisted"] as? Bool
            currentStock.lastdayPrice = asset["lastday_price"] as? String
            currentStock.marketValue = asset["market_value"] as? String
            currentStock.name = name
            currentStock.qty = asset["qty"] as? String
            currentStock.qtyAvailable = asset["qty_available"] as? String
            currentStock.side = asset["side"] as? String
            currentStock.symbol = asset["symbol"] as? String
            
            if let ticker = asset["ticker"] as? [String: Any] {
                let tickerData = TickerData()
                if let dailyBar = ticker["dailyBar"] as? [String: Any] {
                    let dailyBarData = DailyBarData()
                    dailyBarData.o = (dailyBar["o"] as? Double).map { String(format: "%.2f", $0) } ?? "100.00"
                    dailyBarData.h = (dailyBar["h"] as? Double).map { String(format: "%.2f", $0) } ?? "100.00"
                    dailyBarData.l = (dailyBar["l"] as? Double).map { String(format: "%.2f", $0) } ?? "100.00"
                    dailyBarData.c = (dailyBar["c"] as? Double).map { String(format: "%.2f", $0) } ?? "100.00"
                    dailyBarData.n = (dailyBar["n"] as? Int).map { String($0) } ?? "100"
                    dailyBarData.t = (dailyBar["t"] as? Int).map { String($0) } ?? "100"
                    dailyBarData.v = (dailyBar["v"] as? Double).map { String(format: "%.2f", $0) } ?? "100.00"
                    dailyBarData.vw = (dailyBar["vw"] as? Double).map { String(format: "%.2f", $0) } ?? "100.00"
                    tickerData.dailyBar = dailyBarData
                }
                
                if let latestQuote = ticker["latestQuote"] as? [String: Any] {
                    let latestQuoteData = LatestQuoteData()
                    latestQuoteData.ap = (latestQuote["ap"] as? Double).map { String($0) } ?? ""
                    latestQuoteData._as = (latestQuote["as"] as? Int).map { String($0) } ?? "100"
                    latestQuoteData.ax = latestQuote["ax"] as? String ?? ""
                    latestQuoteData.bp = (latestQuote["bp"] as? Double).map { String($0) } ?? ""
                    latestQuoteData.bs = (latestQuote["bs"] as? Int).map { String($0) } ?? "100"
                    latestQuoteData.bx = latestQuote["bx"] as? String ?? ""
                    latestQuoteData.c = latestQuote["c"] as? [String] ?? []
                    latestQuoteData.t = latestQuote["t"] as? String ?? ""
                    latestQuoteData.z = latestQuote["z"] as? String ?? ""
                    tickerData.latestQuote = latestQuoteData
                }
                
                if let latestTrade = ticker["latestTrade"] as? [String: Any] {
                    let latestTradeData = LatestTradeData()
                    latestTradeData.c = latestTrade["c"] as? [String] ?? []
                    latestTradeData.i = (latestTrade["i"] as? Int).map { String($0) } ?? "100"
                    latestTradeData.p = (latestTrade["p"] as? Double).map { String($0) } ?? ""
                    latestTradeData.s = (latestTrade["s"] as? Int).map { String($0) } ?? "100"
                    latestTradeData.t = latestTrade["t"] as? String ?? ""
                    latestTradeData.x = latestTrade["x"] as? String ?? ""
                    latestTradeData.z = latestTrade["z"] as? String ?? ""
                    tickerData.latestTrade = latestTradeData
                }
                
                if let minuteBar = ticker["minuteBar"] as? [String: Any] {
                    let minuteBarData = MinuteBarData()
                    minuteBarData.c = (minuteBar["c"] as? Double).map { String($0) } ?? ""
                    minuteBarData.h = (minuteBar["h"] as? Double).map { String($0) } ?? ""
                    minuteBarData.l = (minuteBar["l"] as? Double).map { String($0) } ?? ""
                    minuteBarData.n = (minuteBar["n"] as? Int).map { String($0) } ?? "100"
                    minuteBarData.o = (minuteBar["o"] as? Double).map { String($0) } ?? ""
                    minuteBarData.t = minuteBar["t"] as? String ?? ""
                    minuteBarData.v = (minuteBar["v"] as? Int).map { String($0) } ?? "100"
                    minuteBarData.vw = (minuteBar["vw"] as? Double).map { String($0) } ?? ""
                    tickerData.minuteBar = minuteBarData
                }
                if let prevDailyBar = ticker["prevDailyBar"] as? [String: Any] {
                    let prevDailyBarData = PrevDailyBarData()
                    prevDailyBarData.c = (prevDailyBar["c"] as? Double).map { String($0) } ?? ""
                    prevDailyBarData.h = (prevDailyBar["h"] as? Double).map { String($0) } ?? ""
                    prevDailyBarData.l = (prevDailyBar["l"] as? Double).map { String($0) } ?? ""
                    prevDailyBarData.n = (prevDailyBar["n"] as? Int).map { String($0) } ?? "100"
                    prevDailyBarData.o = (prevDailyBar["o"] as? Double).map { String($0) } ?? ""
                    prevDailyBarData.t = prevDailyBar["t"] as? String ?? ""
                    prevDailyBarData.v = (prevDailyBar["v"] as? Double).map { String($0) } ?? ""
                    prevDailyBarData.vw = (prevDailyBar["vw"] as? Double).map { String($0) } ?? ""
                    tickerData.prevDailyBar = prevDailyBarData
                }
                currentStock.ticker = tickerData
            
        


            currentStock.unrealizedStringradayPL = asset["unrealized_intraday_pl"] as? String
            currentStock.unrealizedStringradayPLPC = asset["unrealized_intraday_plpc"] as? String
            currentStock.unrealizedPL = asset["unrealized_pl"] as? String
            currentStock.unrealizedPLPC = asset["unrealized_plpc"] as? String

            stocksArray.add(currentStock)
        }
    }
    return stocksArray
}


    // MARK: - Parse search stocks Api

    static func parseSearchStockData(object: [[String: Any]], view: UIView) -> NSMutableArray {
        var ids: String? = ""
        var symbol: String? = ""
        var name: String? = ""
        var status: String? = ""
        let price: String? = ""
        let plp: String? = ""
        var isWatchlisted: Bool? = false
        let stocksArray: NSMutableArray = []
        for dict in object {
            name = dict["name"] as? String
            symbol = dict["symbol"] as? String
            ids = dict["id"] as? String
            status = dict["status"] as? String
            isWatchlisted = dict["is_watchlisted"] as? Bool
            let obj = StockTicker(ids: ids ?? "", symbol: symbol ?? "", name: name ?? "", status: status ?? "", price: price ?? "", plp: plp ?? "", open: "0", high: "0", low: "0", volume: "0", isWatchlisted: isWatchlisted ?? false, prevDailyBar: nil)

            stocksArray.add(obj)
        }

        return stocksArray
    }

    // MARK: - Parse search assests Api

    static func parseAssestsData(object: [[String: Any]]) -> NSMutableArray {
        var ids: String? = ""
        var symbol: String? = ""
        var name: String? = ""
        var status: String? = ""
        var price: String? = ""
        let plp: String? = ""
        var open: String? = "0"
        var high: String? = "0"
        var low: String? = "0"
        var volume: String? = "0"
        var isWatchlisted: Bool? = false
        let stocksArray: NSMutableArray = []
        for dict in object {
            name = dict["name"] as? String
            name = name?.replacingOccurrences(of: "Class A Common Stock", with: "")
            name = name?.replacingOccurrences(of: "Common Stock", with: "")
            name = name?.replacingOccurrences(of: "Class C Capital Stock", with: "")
            symbol = dict["symbol"] as? String
            ids = dict["id"] as? String
            status = dict["status"] as? String
//            isWatchlisted = dict["is_watchlisted"] as? Bool
            if let ticker = dict["ticker"] as? [String: Any] {
                if let dailyBar = ticker["dailyBar"] as? [String: Any] {
                    let ope = dailyBar["o"] as? Double
                    let hig = dailyBar["h"] as? Double
                    let lowwer = dailyBar["l"] as? Double
                    let vol = dailyBar["v"] as? Double
                    open = String(format: "%.2f", ope ?? 100.00)
                    high = String(format: "%.2f", hig ?? 100.00)
                    low = String(format: "%.2f", lowwer ?? 100.00)
                    volume = String(format: "%.2f", vol ?? 100.00)
                } else {
                    open = "100"
                    high = "100"
                    low = "100"
                    volume = "100"
                }
                if let latestTrade = ticker["latestTrade"] as? [String: Any] {
                    let pri = latestTrade["p"] as? Double
                    price = String(format: "%.2f", pri ?? 100.00)
                } else {
                    price = "100"
                }
            } else {
                price = "100"
                open = "100"
                high = "100"
                low = "100"
                volume = "100"
            }
            let obj = StockTicker(ids: ids ?? "", symbol: symbol ?? "", name: name ?? "", status: status ?? "", price: price ?? "", plp: plp ?? "", open: open ?? "", high: high ?? "", low: low ?? "", volume: volume ?? "", isWatchlisted: isWatchlisted ?? false, prevDailyBar: nil)
            stocksArray.add(obj)
        }

        return stocksArray
    }
}
