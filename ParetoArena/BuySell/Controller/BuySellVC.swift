//
//  NewBuySellVC.swift
//  Pareto
//
//  Created by Zachary Coriarty on 4/18/23.
//

import Foundation
import Combine
import SwiftUI
import SwiftUICharts

struct NewBuySellVC: View {
    
    let currentStock: NewCurrentStock?
    @Environment(\.presentationMode) var presentationMode
    @State private var showTradeButtons: Bool = false
    let buttonWidth = UIScreen.main.bounds.width * 0.44
    @State private var presentBacktest = false

    // for buy/sell routing
    @State private var sellIsActive = false
    @State private var buyIsActive = false

    var body: some View {
        
        let buySellViewModel = BuySellViweModel()
        let stockGraphViewModel = StockGraphViewModel(symbol: currentStock?.symbol ?? "AAPL", buySellViewModel: buySellViewModel)

        
        NavigationView {
            ZStack {
                VStack {
                    if showTradeButtons {
                        Color.clear
                            .contentShape(Rectangle())
                            .onTapGesture {
                                withAnimation {
                                    showTradeButtons = false
                                }
                            }
                    }

                    ScrollView {
                        VStack(alignment: .leading) {
                            VStack(alignment: .leading) {
                                HStack {
                                    VStack(alignment: .leading){
                                        Text(currentStock?.symbol ?? "AAPL")
                                            .font(.system(size: 24, weight: .bold))
                                        Text(currentStock?.displayName ?? "")
                                            .font(.system(size: 12, weight: .semibold))
                                            .foregroundColor(Color(.lightGray))
                                    }
                                    .padding()

                                    Spacer()

                                    Button(action: {
                                        presentationMode.wrappedValue.dismiss()
                                    }, label: {
                                        HStack {
                                            Image(systemName: "xmark")
                                                .foregroundColor(Color.primary.opacity(0.6))
                                                .padding(10)
                                                .background(Color.primary.opacity(0.1))
                                                .clipShape(Circle())
                                        }
                                    })
                                    .padding()

                                }
                                .padding(.horizontal)
                                Divider()
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text("$\(currentStock?.currentPrice ?? String(currentStock?.ticker?.dailyBar?.c ?? 0.0)) ")
                                            .font(.system(size: 38, weight: .heavy))
                                        Text("\(calculatePercChange(currentStock: currentStock).formattedPercentage)%")
                                            .font(.system(size: 20, weight: .bold))
                                            .foregroundColor(calculatePercChange(currentStock: currentStock).textColor)
                                    }
                                    Spacer()
                                }
                                .padding(.leading, 28)

                            }
                            .padding()
                            VStack {

                                StockChartView(viewModel: stockGraphViewModel)
//
                                Divider()

                                StockView(currentStock: currentStock!)
                                
                                StockTable(currentStock: currentStock!)
                                    .padding(.horizontal)


                                NewsListView(stocks: [currentStock?.symbol ?? "AAPL"])
                                    .padding(.horizontal)
                            }
                                
                            

                        }
                        .background(Color(.systemBackground))

                    }
                    .padding(.bottom, 70)
                    
    //                Spacer()
                }
            }
        }

    }


    
    func calculatePercChange(currentStock: NewCurrentStock?) -> (formattedPercentage: String, textColor: Color) {
        // Calculate today's % change for watchlist items
        var dayDiff: Double = 0.0
        var changeTodayPct = 0.0
        if let ticker = currentStock?.ticker {
            let open = ticker.prevDailyBar?.c ?? 100.0
            let close = ticker.dailyBar?.c ?? 100.0
            dayDiff = close - open
            changeTodayPct = (dayDiff / open) * 100.0
        }
        
        if let ct = currentStock?.changeToday {
            changeTodayPct = (Double(ct) ?? 0.0) * 100
        }

        let percentageValue = Double(changeTodayPct)
        let textColor: Color = percentageValue >= 0 ? .green : .red

        // Format currentStock.changeToday value to have two decimal places
        let formattedChangeToday = String(format: "%.2f", changeTodayPct)

        return (formattedChangeToday, textColor)
    }

}


class StockGraphViewModel: ObservableObject {
    @Published var graphData: [GraphPoint] = []
    @Published var lineColor: Color = .red
    var symbol: String
    var buySellViewModel: BuySellViweModel
    
    private var cancellables = Set<AnyCancellable>()
    
    init(symbol: String, buySellViewModel: BuySellViweModel) {
        self.symbol = symbol
        self.buySellViewModel = buySellViewModel
        setupBuySellViewModelCallbacks()
    }
    
    func setupBuySellViewModelCallbacks() {
        self.buySellViewModel.bars = { [weak self] bar in
            let newData = self?.parseStockDataResponse(barsResponse: bar) ?? []
            print("ADSFKJ", newData)
            self?.graphData = newData
        }
        
        self.buySellViewModel.result = { error in
            print("Error: \(error)")
        }
    }
    
    func updateChartData(selectedRange: Int) {
        let timeFrame: String
        var startDate: String
        let endDate = Calendar.current.date(byAdding: .hour, value: -1, to: Date())!.RFCFormat
        
        print("here")
        
        switch selectedRange {
        case 0:
            timeFrame = "10Min"
            let today = Calendar.current.startOfDay(for: Date())
            let lastMarketOpen = previousMarketOpenDate(from: today)
            let date = Calendar.current.startOfDay(for: lastMarketOpen)
            startDate = date.RFCFormat
        case 1:
            timeFrame = "1Hour"
            startDate = Calendar.current.date(byAdding: .day, value: -7, to: Date())!.RFCFormat
        case 2:
            timeFrame = "1Day"
            startDate = Calendar.current.date(byAdding: .month, value: -3, to: Date())!.RFCFormat
        case 3:
            timeFrame = "1Day"
            startDate = Calendar.current.date(byAdding: .month, value: -6, to: Date())!.RFCFormat
        case 4:
            timeFrame = "1Day"
            startDate = Calendar.current.date(byAdding: .year, value: -1, to: Date())!.RFCFormat
        case 5:
            timeFrame = "1Day"
            startDate = Calendar.current.date(byAdding: .year, value: -5, to: Date())!.RFCFormat
        default:
            timeFrame = "10Min"
            startDate = Calendar.current.startOfDay(for: Date()).RFCFormat
        }
        
        
        buySellViewModel.getBars(symbol: symbol, timeFrame: timeFrame, start: startDate, end: endDate)
    }
    
    func previousMarketOpenDate(from date: Date) -> Date {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: date)
        let daysToSubtract: Int
        
        if weekday == 1 {
            // If it's Sunday, subtract 2 days to get to Friday
            daysToSubtract = 2
        } else if weekday == 7 {
            // If it's Saturday, subtract 1 day to get to Friday
            daysToSubtract = 1
        } else {
            // If it's a weekday, subtract the appropriate number of days to get to the last market open date
            daysToSubtract = weekday - 2
        }
        
        return calendar.date(byAdding: .day, value: -daysToSubtract, to: date)!
    }
    
    
    private func parseStockDataResponse(barsResponse: Bar) -> [GraphPoint] {
        let closePrices = barsResponse.bars.map { $0.c }
        
        if let firstClose = closePrices.first, let lastClose = closePrices.last, lastClose < firstClose {
            lineColor = Color.red
        } else {
            lineColor = Color.green
        }
        
        return closePrices.enumerated().map { GraphPoint(x: Float($0), y: Float($1)) }
    }
}
struct StockChartView: View {
    @ObservedObject var viewModel: StockGraphViewModel
    @State private var selectedDataPoint: LineChartDataPoint?
    @State private var selectedRange: Int = 0
    
//    let buySellViewModel = BuySellViweModel()
    

    private let ranges = ["1D", "1W", "3M", "6M", "1Y", "5Y"]
    
    var body: some View {
        
            
            VStack {
                
                
                if let data = createChartData() {
                    LineChart(chartData: data)
                        .touchOverlay(chartData: data, specifier: "%.2f")
                        .infoBox(chartData: data)
                        .headerBox(chartData: data)
                        .id(data.id)
//                        .frame(height: graphHeight)
//                        .padding(.all, 30)
                        .frame(height: 200) // Add a fixed frame height
                } else {
                    Text("No data available")
                        .foregroundColor(.primary)
                }
                
                
                HStack(spacing: 15) {
                    ForEach(0..<ranges.count, id: \.self) { index in
                        RangeButton(title: ranges[index], index: index, selectedIndex: $selectedRange, viewModel: viewModel)
//                            .padding(.horizontal, 2)
//                            .padding(.vertical, 4)
                    }
                }
                .background{
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Color.clear)
//                        .stroke(Color.red.opacity(0.2),lineWidth: 1)
//                        .background(Color(.tertiarySystemGroupedBackground))
                }
                .padding(.vertical)
                
                

            }
            .onAppear {
                viewModel.updateChartData(selectedRange: selectedRange)

            }
        
    }
    private func createChartData() -> LineChartData? {
        guard !viewModel.graphData.isEmpty else { return nil }

        let dataPoints = viewModel.graphData.map { LineChartDataPoint(value: Double($0.y), xAxisLabel: String($0.x)) }
        let dataSet = LineDataSet(dataPoints: dataPoints, style: LineStyle(lineColour: ColourStyle(colour: viewModel.lineColor), lineType: .curvedLine))

        // Find the smallest and largest data point values
        let minValue = dataPoints.min(by: { $0.value < $1.value })?.value ?? 0
        let maxValue = dataPoints.max(by: { $0.value < $1.value })?.value ?? 0

        // Add 10% padding to the smallest and largest values
        let padding = (maxValue - minValue) * 0.1
//        let baseLine = minValue - padding
//        let topline = maxValue + padding

        let gridStyle = GridStyle(numberOfLines: 7,
                                  lineColour: Color(.lightGray).opacity(0.5),
                                  lineWidth: 1,
                                  dash: [8],
                                  dashPhase: 0)

        let chartStyle = LineChartStyle(infoBoxPlacement: .infoBox(isStatic: false),
                                        infoBoxBorderColour: Color.primary,
                                        infoBoxBorderStyle: StrokeStyle(lineWidth: 1),
                                        xAxisGridStyle: gridStyle,
                                        xAxisLabelPosition: .bottom,
                                        xAxisLabelColour: Color.primary,
                                        xAxisLabelsFrom: .dataPoint(rotation: .degrees(0)),
                                        yAxisGridStyle: gridStyle,
                                        yAxisLabelPosition: .leading,
                                        yAxisLabelColour: Color.primary,
                                        yAxisNumberOfLabels: 7,
                                        baseline: .minimumValue, // Set baseLine to the minValue with padding
                                        topLine: .maximumValue, // Set topLine to the maxValue with padding
                                        globalAnimation: .easeOut(duration: 1))

        return LineChartData(dataSets: dataSet, chartStyle: chartStyle)
    }
}

struct RangeButton: View {
    var title: String
    var index: Int
    @Binding var selectedIndex: Int
    @Environment(\.isEnabled) private var isEnabled: Bool
    @ObservedObject var viewModel: StockGraphViewModel

    var body: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.3)) {
                selectedIndex = index
            }
            viewModel.updateChartData(selectedRange: selectedIndex)
        }) {
            Text(title)
                .font(.system(size: 14, weight: .light))
                .foregroundColor(selectedIndex == index ? .white : .primary)
                .padding(.vertical,6)
                .padding(.horizontal,10)
                .contentShape(Rectangle())
                .background(
//                    if selectedIndex == index {
                        Rectangle()
                            .fill(selectedIndex == index ? Color(.tertiarySystemGroupedBackground).opacity(isEnabled ? 1.0 : 0.5) : Color.clear)
                            .cornerRadius(9)
//                    }
                )
            
        }
    }
}

struct SlidingEffect: GeometryEffect {
    var offset: CGFloat

    init(offset: CGFloat) {
        self.offset = offset
    }

    func effectValue(size: CGSize) -> ProjectionTransform {
        return ProjectionTransform(CGAffineTransform(translationX: offset, y: 0))
    }
}

class StockViewModel: ObservableObject {
    @Published var currentStock: NewCurrentStock
    
    init(stock: NewCurrentStock) {
        self.currentStock = stock
    }
}

struct StockView: View {
    @State private var sliderValue: Double = 0.0
    @ObservedObject var viewModel: StockViewModel
    let currentStock: NewCurrentStock
    
    init(currentStock: NewCurrentStock) {
        self.currentStock = currentStock
        viewModel = StockViewModel(stock: currentStock)
    }
    
    var body: some View {
            VStack(alignment: .center, spacing: 6) {
                ScrollView(.horizontal, showsIndicators: false){
                    HStack(spacing: 6) {
                        InfoSquare(title: "Open", value: convertToStringWithPostfix(String(currentStock.ticker?.dailyBar?.o ?? 0.0)))
                        InfoSquare(title: "Volume", value: convertToStringWithPostfix(String(currentStock.ticker?.dailyBar?.v ?? 0.0)))
                        InfoSquare(title: "Prev Close", value: convertToStringWithPostfix(String(currentStock.ticker?.prevDailyBar?.c ?? 0.0)))
                        InfoSquare(title: "Prev Open", value: convertToStringWithPostfix(String(currentStock.ticker?.prevDailyBar?.o ?? 0.0)))
                        InfoSquare(title: "Exchange", value: currentStock.exchange ?? "")
                    }
                    .padding(.horizontal, 24)
                }
                

            }
            .padding()
            .background(Color(.systemBackground))
    }
    
    func convertToStringWithPostfix(_ input: String) -> String {
        guard let number = Double(input) else {
            return ""
        }

        let thousand = 1000.0
        let million = thousand * thousand
        let billion = million * thousand

        if number >= billion {
            return String(format: "%.1fB", arguments: [number / billion])
        } else if number >= million {
            return String(format: "%.1fM", arguments: [number / million])
        } else if number >= thousand {
            return String(format: "%.1fK", arguments: [number / thousand])
        } else {
            return String(format: "%.2f", arguments: [number])
        }
    }

}

struct InfoSquare: View {
    var title: String
    var value: String?

    var body: some View {
        VStack {
            Text(value ?? "-")
                .font(.system(size: 25, weight: .heavy))
                .lineLimit(1)
                .minimumScaleFactor(0.5)
            Text(title)
                .font(.system(size: 14, weight: .light))
            
        }
        .frame(minWidth: 0, maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray5).opacity(0.5))
        .cornerRadius(10)
    }
}

struct StockTable: View {
    var currentStock: NewCurrentStock
    let cardWidth = UIScreen.main.bounds.width * 0.9
    @State private var showLatestQuotePage = false
    @State private var showMinuteBarPage = false
    @State private var showPreviousDailyBarPage = false
//    @StateObject private var backtestViewModel = BacktestViewModel()
    @State private var strategies: [String] = []
    @State private var selectedStrategy: String = "Dmac Rsi"
    @State private var isDefaultBacktest: Bool = true
    @State private var showFullBacktest: Bool = false
//    @State private var backtestParams: BacktestParams = BacktestParams(strategy: "", funds: "", symbol: "", startDate: "", endDate: "")


    var body: some View {
        let dailyDataStatistics = dailyDataStatistics(dailyBar: currentStock.ticker?.dailyBar)
        
        VStack(alignment: .leading, spacing: 2) {
            Text("Statistics")
                .font(.title)
                .bold()
                .padding(.bottom, 5)
                .padding(.horizontal, 15)
            
            VStack {
                ForEach(dailyDataStatistics, id: \.key) { item in
                    ExpandableCard(item: item)
                }
                
            }
            
//            VStack(alignment: .leading, spacing: 2){
//
//                Text("Backtest Preview")
//                    .font(.title2)
//                    .bold()
//                    .padding(.bottom, 5)
//
//                VStack(spacing: 10) {
//
//                    HStack {
//
//                        createPicker(title: "", selection: $selectedStrategy.onChange { _ in isDefaultBacktest = false }, options: strategies)
//
//                        Spacer()
//
//                    }
//
////                    CombinedChartView(backtestViewModel: backtestViewModel)
////                        .padding()
//
//                    Divider()
//
////                    HStack {
////                        Button(action: {
////                            backtestParams = getBacktestParams()
////                            showFullBacktest = true
////                        }) {
////                            HStack {
////                                Text("Full Backtest")
////                                    .foregroundColor(.secondary)
////                                    .fontWeight(.bold)
////
////                                Image(systemName: "chevron.right")
////                                    .foregroundColor(.secondary)
////
////                            }
////                        }
////                        .fullScreenCover(isPresented: $showFullBacktest) {
////
////                            BacktestBaseView(backtestObject: $backtestParams)
////                        }
////                        Spacer()
////                    }
////                    .padding()
//                }
//                .background(Color(.systemGray5).opacity(0.5))
//                .cornerRadius(10)
//
//            }
//            .padding()

            
            VStack(alignment: .leading, spacing: 2) {
                
                Text("More Statistics")
                    .font(.title2)
                    .bold()
                    .padding(.bottom, 5)

                
                VStack {
                    
                    
                    Button(action: {
                        showLatestQuotePage = true
                    }){
                        HStack {
                            VStack(alignment: .leading){
                            
                                Text("Latest Quote")
                                Text("See the Most Recent Quote")
                                    .font(.system(size: 12, weight: .light))
                                    .foregroundColor(.secondary)
                                
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 10)
                        .padding(.horizontal, 9)

                    }
    //                .cornerRadius(10, corners: [.topLeft, .topRight])
                    .fullScreenCover(isPresented: $showLatestQuotePage) {
                        LatestQuoteView(latestQuote: currentStock.ticker?.latestQuote)
                    }
                    
                    Divider()

                    Button(action: {
                        showMinuteBarPage = true
                    }){
                        HStack {
                            VStack(alignment: .leading){
                                Text("Minute Bar")
                                Text("Last Minute Statistics")
                                    .font(.system(size: 12, weight: .light))
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)

                        }
                        .padding(.vertical, 6)
                        .padding(.horizontal, 9)

                    }.fullScreenCover(isPresented: $showMinuteBarPage) {
                        MinuteBarView(minuteBar: currentStock.ticker?.minuteBar)
                    }
                    
                    Divider()

                    Button(action: {
                        showPreviousDailyBarPage = true
                    }){
                        HStack {
                            VStack(alignment: .leading){
                                Text("Previous Daily Bar")
                                Text("Pervious Day's Performance")
                                    .font(.system(size: 12, weight: .light))
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)

                        }
                        .padding(.vertical, 10)
                        .padding(.horizontal, 9)

                    }
    //                .cornerRadius(10, corners: [.bottomLeft, .bottomRight])
                    .fullScreenCover(isPresented: $showPreviousDailyBarPage) {
                        PreviousDailyBarView(prevDailyBar: currentStock.ticker?.prevDailyBar)
                    }
                }
                .background(Color(.systemGray5).opacity(0.5))
                .cornerRadius(10)
            }
            .padding()

        }
        .padding()
    }
        
    func dailyDataStatistics(dailyBar: NewDailyBarData?) -> [(key: String, value: [(key: String, value: String)])] {
        // filter the statistics for "Daily Data"
        
        var dailyBarProperties: [(key: String, value: String)] = []
        
        dailyBarProperties.appendIfNotNil(("Close", String(dailyBar?.c ?? 0.0)))
        dailyBarProperties.appendIfNotNil(("High", String(dailyBar?.h ?? 0.0)))
        dailyBarProperties.appendIfNotNil(("Low", String(dailyBar?.l ?? 0.0)))
//        dailyBarProperties.appendIfNotNil(("N", String(dailyBar?.n ?? 0.0)))
        dailyBarProperties.appendIfNotNil(("Open", String(dailyBar?.o ?? 0.0)))
        dailyBarProperties.appendIfNotNil(("Volume", String(dailyBar?.v ?? 0.0)))
        dailyBarProperties.appendIfNotNil(("Vol, Weighted", String(dailyBar?.vw ?? 0.0)))
        
        return [(key: "", dailyBarProperties)]
        
    }
        
    
}

struct LatestQuoteView: View {
    var latestQuote: NewLatestQuoteData?
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        let statistics = latestQuoteStatistics()

        return VStack(alignment: .leading, spacing: 15) {
            
            HStack {
                Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                }
                Spacer()
            }
            .padding()

            
            ForEach(statistics, id: \.key) { item in
                ExpandableCard(item: item)
            }
            Spacer()
        }
    }

    private func latestQuoteStatistics() -> [(key: String, value: [(key: String, value: String)])] {
        var latestQuoteProperties: [(key: String, value: String)] = []

        latestQuoteProperties.appendIfNotNil(("Ask Price", String(latestQuote?.ap ?? 0.0)))
        latestQuoteProperties.appendIfNotNil(("Ask Size", String(latestQuote?._as ?? 0.0)))
        latestQuoteProperties.appendIfNotNil(("AX", String(latestQuote?.ax ?? 0.0)))
        latestQuoteProperties.appendIfNotNil(("Bid Price", String(latestQuote?.bp ?? 0.0)))
        latestQuoteProperties.appendIfNotNil(("Bid Size", String(latestQuote?.bs ?? 0.0)))
        latestQuoteProperties.appendIfNotNil(("BX", latestQuote?.bx))
        latestQuoteProperties.appendIfNotNil(("C", latestQuote?.c?.joined(separator: ", ")))
        latestQuoteProperties.appendIfNotNil(("Z", latestQuote?.z))
        
        return [(key: "Latest Quote", latestQuoteProperties)]

    }
}

struct MinuteBarView: View {
    var minuteBar: NewMinuteBarData?
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        let statistics = minuteBarStatistics()

        return VStack(alignment: .leading, spacing: 15) {
            
            HStack {
                Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                }
                Spacer()
            }
            .padding()

            
            ForEach(statistics, id: \.key) { item in
                ExpandableCard(item: item)
            }
            Spacer()
        }
        
    }

    private func minuteBarStatistics() -> [(key: String, value: [(key: String, value: String)])] {
        var minuteBarProperties: [(key: String, value: String)] = []

        minuteBarProperties.appendIfNotNil(("Close", String(minuteBar?.c ?? 0.0)))
        minuteBarProperties.appendIfNotNil(("Hight", String(minuteBar?.h ?? 0.0)))
        minuteBarProperties.appendIfNotNil(("Low", String(minuteBar?.l ?? 0.0)))
        minuteBarProperties.appendIfNotNil(("Transactions", String(minuteBar?.n ?? 0.0)))
        minuteBarProperties.appendIfNotNil(("Open", String(minuteBar?.o ?? 0.0)))
        minuteBarProperties.appendIfNotNil(("Volume", String(minuteBar?.v ?? 0.0)))
        minuteBarProperties.appendIfNotNil(("Vol, Weighted", String(minuteBar?.vw ?? 0.0)))
        
        return [(key: "Minute Bar", minuteBarProperties)]

    }
}


struct PreviousDailyBarView: View {
    var prevDailyBar: NewPrevDailyBarData?
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        let statistics = previousDailyBarStatistics()
        
        return VStack(alignment: .leading, spacing: 15) {
            
            HStack {
                Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                }
                Spacer()
            }
            .padding()

            
            ForEach(statistics, id: \.key) { item in
                ExpandableCard(item: item)
            }
            Spacer()
        }
    }
    private func previousDailyBarStatistics() -> [(key: String, value: [(key: String, value: String)])] {
        
        var prevDailyBarProperties: [(key: String, value: String)] = []
        
        prevDailyBarProperties.appendIfNotNil(("Close", String(prevDailyBar?.c ?? 0.0)))
        prevDailyBarProperties.appendIfNotNil(("High", String(prevDailyBar?.h ?? 0.0)))
        prevDailyBarProperties.appendIfNotNil(("Low", String(prevDailyBar?.l ?? 0.0)))
        prevDailyBarProperties.appendIfNotNil(("Open", String(prevDailyBar?.o ?? 0.0)))
        prevDailyBarProperties.appendIfNotNil(("Volume", String(prevDailyBar?.v ?? 0.0)))
        prevDailyBarProperties.appendIfNotNil(("Vol, Weighted", String(prevDailyBar?.vw ?? 0.0)))
        
        
        return [(key: "Previous Daily Bar", prevDailyBarProperties)]
    }
    
}






    
struct ExpandableCard: View {
    var item: (key: String, value: [(key: String, value: String)])
    @State private var expanded: Bool = false
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(item.key)
                .font(.title2)
                .bold()
                .padding(.bottom, 2)

            VStack(alignment: .leading, spacing: 5) {
                ForEach(item.value.indices) { index in
                    if index == 0 || expanded {
                        HStack {
                            Text(item.value[index].key)
                                .font(.callout)
                            Spacer()
                            Text(item.value[index].value)
                                .font(.callout)
                                .bold()
                                .foregroundColor(Color(.secondaryLabel))
                        }
                    }
                }
                Button(action: {
                    withAnimation {
                        expanded.toggle()
                    }
                }) {
                    Text(expanded ? "Show less" : "Show more")
                        .font(.callout)
                        .bold()
                        .foregroundColor(Color(.secondaryLabel))
                        .padding(.top, 5)
                }
            }
            .padding()
            .background(Color(.systemGray5).opacity(0.5))
            .cornerRadius(10)
        }
        .padding(.horizontal)
        .onAppear {
            if item.value.indices.first == 0 {
                expanded = true
            }
        }
    }
}




struct GraphPoint: Identifiable, Hashable {
    let id = UUID()
    let x: Float
    let y: Float
}

extension Array {
    mutating func appendIfNotNil<T>(_ tuple: (key: String, value: T?)) where Element == (key: String, value: T) {
        if let value = tuple.value {
            self.append((tuple.key, value))
        }
    }
}

//struct NewBuySellVC_Previews: PreviewProvider {
//    static var previews: some View {
//        NewBuySellVC()
//    }
//}
