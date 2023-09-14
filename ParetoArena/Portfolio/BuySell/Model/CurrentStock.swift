//
//  CurrentStock.swift
//  Pareto
//
//  Created by Zachary Coriarty on 3/4/23.
//

import Foundation

struct PortfolioResponse: Decodable {
    let accountId: String?
    let assets: [NewCurrentStock]
    let createdAt: String?
    let id: String?
    let name: String?
    let updatedAt: String?

    enum CodingKeys: String, CodingKey {
        case accountId = "account_id"
        case assets
        case createdAt = "created_at"
        case id
        case name
        case updatedAt = "updated_at"
    }
}

struct NewCurrentStock: Decodable, Identifiable {
    let assetClass: String?
    let easyToBorrow: Bool?
    let exchange: String?
    let fractionable: Bool?
    let id: String?
    let changeToday: String?
    var currentPrice: String? = ""
    let maintenanceMarginRequirement: Double?
    let marginable: Bool?
    let name: String?
    var displayName: String? {
        get {
            var modifiedName = name
            modifiedName = modifiedName?.replacingOccurrences(of: "Class A Common Stock", with: "")
            modifiedName = modifiedName?.replacingOccurrences(of: "Common Stock", with: "")
            modifiedName = modifiedName?.replacingOccurrences(of: "Class C Capital Stock", with: "")
            modifiedName = modifiedName?.replacingOccurrences(of: "Depositary Shares", with: "")
            return modifiedName
        }
    }

    let shortable: Bool?
    let status: String?
    let symbol: String?
    let ticker: NewTickerData?
    let tradable: Bool?

    enum CodingKeys: String, CodingKey {
        case assetClass = "class"
        case easyToBorrow = "easy_to_borrow"
        case exchange
        case fractionable
        case id
        case changeToday = "change_today"
        case currentPrice = "current_price"
        case maintenanceMarginRequirement = "maintenance_margin_requirement"
        case marginable
        case name
        case shortable
        case status
        case symbol
        case ticker
        case tradable
    }
}




class NewTickerData: Decodable {
    var dailyBar: NewDailyBarData?
    var latestQuote: NewLatestQuoteData?
    var latestTrade: NewLatestTradeData?
    var minuteBar: NewMinuteBarData?
    var prevDailyBar: NewPrevDailyBarData?
    
    enum CodingKeys: String, CodingKey {
            case dailyBar = "dailyBar"
            case latestQuote = "latestQuote"
            case latestTrade = "latestTrade"
            case minuteBar = "minuteBar"
            case prevDailyBar = "prevDailyBar"
        }
    
}

class NewDailyBarData: NSObject, Codable {
    var c: Double?
    var h: Double?
    var l: Double?
    var n: Double?
    var o: Double?
    var t: String?
    var v: Double?
    var vw: Double?

}

class NewLatestQuoteData: NSObject, Codable {
    var ap: Double?
    var _as: Double?
    var ax: Double?
    var bp: Double?
    var bs: Double?
    var bx: String?
    var c: [String]?
    var t: String?
    var z: String?
    
    enum CodingKeys: String, CodingKey {
        case _as = "as"
    }
}

class NewLatestTradeData: NSObject, Codable {
    var c: [String]?
    var i: Double?
    var p: Double?
    var s: Double?
    var t: String?
    var x: String?
    var z: String?
}

class NewMinuteBarData: NSObject, Codable {
    var c: Double?
    var h: Double?
    var l: Double?
    var n: Double?
    var o: Double?
    var t: String?
    var v: Double?
    var vw: Double?
}

class NewPrevDailyBarData: NSObject, Codable {
    var c: Double?
    var h: Double?
    var l: Double?
    var n: Double?
    var o: Double?
    var t: String?
    var v: Double?
    var vw: Double?
}


class CurrentStock: NSObject {
    var assetClass: String? = ""
    var assetID: String? = ""
    var assetMarginable: String?
    var avgEntryPrice: String? = ""
    var changeToday: String? = ""
    var costBasis: String? = ""
    var currentPrice: String? = ""
    var exchange: String? = ""
    var isWatchlisted: Bool?
    var lastdayPrice: String? = ""
    var marketValue: String? = ""
    var name: String? = ""
    var qty: String? = ""
    var qtyAvailable: String? = ""
    var side: String? = ""
    var symbol: String? = ""
    var ticker: TickerData?
    var unrealizedStringradayPL: String? = ""
    var unrealizedStringradayPLPC: String? = ""
    var unrealizedPL: String? = ""
    var unrealizedPLPC: String? = ""
    
}



class TickerData: NSObject{
    var dailyBar: DailyBarData?
    var latestQuote: LatestQuoteData?
    var latestTrade: LatestTradeData?
    var minuteBar: MinuteBarData?
    var prevDailyBar: PrevDailyBarData?
}

class DailyBarData: NSObject {
    var c: String?
    var h: String?
    var l: String?
    var n: String?
    var o: String?
    var t: String?
    var v: String?
    var vw: String?

}

class LatestQuoteData {
    var ap: String?
    var _as: String?
    var ax: String?
    var bp: String?
    var bs: String?
    var bx: String?
    var c: [String]?
    var t: String?
    var z: String?
}

class LatestTradeData {
    var c: [String]?
    var i: String?
    var p: String?
    var s: String?
    var t: String?
    var x: String?
    var z: String?
}

class MinuteBarData {
    var c: String?
    var h: String?
    var l: String?
    var n: String?
    var o: String?
    var t: String?
    var v: String?
    var vw: String?
}

class PrevDailyBarData {
    var c: String?
    var h: String?
    var l: String?
    var n: String?
    var o: String?
    var t: String?
    var v: String?
    var vw: String?
}


func convertTickerToCurrentStock(_ ticker: Ticker) -> CurrentStock {
    let currentStock = CurrentStock()
    currentStock.assetID = nil
    currentStock.assetMarginable = nil
    currentStock.avgEntryPrice = nil
    currentStock.changeToday = String(format: "%.2f", ticker.todaysChange)
    currentStock.costBasis = nil
    currentStock.currentPrice = String(format: "%.2f", ticker.lastTrade.p)
    currentStock.exchange = String(ticker.lastTrade.x)
    currentStock.isWatchlisted = nil
    currentStock.lastdayPrice = String(format: "%.2f", ticker.prevDay.c)
    currentStock.marketValue = nil
    currentStock.name = nil
    currentStock.qty = nil
    currentStock.qtyAvailable = nil
    currentStock.side = nil
    currentStock.symbol = ticker.ticker
    currentStock.ticker = TickerData()
    
    let dailyBar = DailyBarData()
    dailyBar.c = String(format: "%.2f", ticker.day.c)
    dailyBar.h = String(format: "%.2f", ticker.day.h)
    dailyBar.l = String(format: "%.2f", ticker.day.l)
    dailyBar.n = nil
    dailyBar.o = String(format: "%.2f", ticker.day.o)
    dailyBar.t = String(ticker.updated)
    dailyBar.v = String(ticker.day.v)
    dailyBar.vw = String(format: "%.2f", ticker.day.vw)
    
    currentStock.ticker?.dailyBar = dailyBar
    
    let latestQuote = LatestQuoteData()
    latestQuote.ap = String(format: "%.2f", ticker.lastQuote.P)
    latestQuote._as = String(ticker.lastQuote.S)
    latestQuote.ax = nil
    latestQuote.bp = nil
    latestQuote.bs = nil
    latestQuote.bx = nil
    latestQuote.c = nil
    latestQuote.t = String(ticker.lastTrade.t)
    latestQuote.z = nil
    
    currentStock.ticker?.latestQuote = latestQuote
    
    let latestTrade = LatestTradeData()
//    latestTrade.c = ticker.lastTrade.c
    latestTrade.c = nil
    latestTrade.i = ticker.lastTrade.i
    latestTrade.p = String(format: "%.2f", ticker.lastTrade.p)
    latestTrade.s = String(ticker.lastTrade.s)
    latestTrade.t = String(ticker.lastTrade.t)
    latestTrade.x = String(ticker.lastTrade.x)
    latestTrade.z = nil
    
    currentStock.ticker?.latestTrade = latestTrade
    
    let minuteBar = MinuteBarData()
    minuteBar.c = String(format: "%.2f", ticker.min.c)
    minuteBar.h = String(format: "%.2f", ticker.min.h)
    minuteBar.l = String(format: "%.2f", ticker.min.l)
    minuteBar.n = nil
    minuteBar.o = String(format: "%.2f", ticker.min.o)
    minuteBar.t = String(ticker.updated)
    minuteBar.v = String(ticker.min.v)
    minuteBar.vw = String(format: "%.2f", ticker.min.vw)
    
    currentStock.ticker?.minuteBar = minuteBar
    
    let prevDailyBar = PrevDailyBarData()
    prevDailyBar.c = String(format: "%.2f", ticker.prevDay.c)
    prevDailyBar.h = String(format: "%.2f", ticker.prevDay.h)
    prevDailyBar.l = String(format: "%.2f", ticker.prevDay.l)
    prevDailyBar.n = nil
    prevDailyBar.o = String(format: "%.2f",ticker.prevDay.o)
    prevDailyBar.t = String(ticker.updated)
    prevDailyBar.v = String(ticker.prevDay.v)
    prevDailyBar.vw = String(format: "%.2f", ticker.prevDay.vw)
    
    currentStock.ticker?.prevDailyBar = prevDailyBar
    
    currentStock.unrealizedStringradayPL = String(format: "%.2f", ticker.todaysChange)
    currentStock.unrealizedStringradayPLPC = String(format: "%.2f", ticker.todaysChangePerc)
    currentStock.unrealizedPL = nil
    currentStock.unrealizedPLPC = nil
    
    return currentStock
}
