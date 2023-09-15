//
//  Snapshot.swift
//  Pareto
//
//  Created by Zachary Coriarty on 3/12/23.
//

import Foundation

class Snapshot: NSObject {
    
    var symbol: String? = ""
    var data: SnapshotData?
    
}

class SnapshotData: NSObject {
    
    var dailyBar: DailyBarSnapshot?
    var latestQuote: LatestQuoteSnapshot?
    var latestTrade: LatestTradeSnapshot?
    var minuteBar: MinuteBarSnapshot?
    var prevDailyBar: PrevDailyBarSnapshot?
}


class DailyBarSnapshot {
    var c: String?
    var h: String?
    var l: String?
    var n: String?
    var o: String?
    var t: String?
    var v: String?
    var vw: String?
}

class LatestQuoteSnapshot {
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

class LatestTradeSnapshot {
    var c: [String]?
    var i: String?
    var p: String?
    var s: String?
    var t: String?
    var x: String?
    var z: String?
}

class MinuteBarSnapshot {
    var c: String?
    var h: String?
    var l: String?
    var n: String?
    var o: String?
    var t: String?
    var v: String?
    var vw: String?
}

class PrevDailyBarSnapshot {
    var c: String?
    var h: String?
    var l: String?
    var n: String?
    var o: String?
    var t: String?
    var v: String?
    var vw: String?
}


