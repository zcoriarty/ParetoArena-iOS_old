//
//  ComparisonChartView.swift
//  Pareto
//
//  Created by Zachary Coriarty on 5/6/23.
//

import SwiftUI
import SwiftUICharts

struct CombinedChartView: View {
    let stock: String = "AAPL"
    @ObservedObject var backtestViewModel: BacktestViewModel
    
    var body: some View {
        VStack {
            if let backtestData = backtestViewModel.stockData,
               let listData = backtestViewModel.listData,
               !backtestViewModel.stockData!.isEmpty {

                let backtestChartData = getBacktestChartData(stockData: backtestData, values: listData.fundValue)
                let stockChartData = getStockChartData(data: backtestData)

                // Combine the dataSets
                let combinedDataSets = MultiLineDataSet(dataSets: [backtestChartData.dataSets, stockChartData.dataSets])

                let combinedChartData = MultiLineChartData(dataSets: combinedDataSets,
                                                           chartStyle: backtestChartData.chartStyle)

                MultiLineChart(chartData: combinedChartData)
                    .touchOverlay(chartData: combinedChartData)
                    .infoBox(chartData: combinedChartData)
                    .headerBox(chartData: combinedChartData)
                    .legends(chartData: combinedChartData, columns: [GridItem(.flexible()), GridItem(.flexible())])
                    .id(combinedChartData.id)
                    .frame(minWidth: 150, maxWidth: 900, minHeight: 150, idealHeight: 250, maxHeight: 400, alignment: .center)

            } else if backtestViewModel.isLoading {
                VStack(alignment: .center){
                    TriangleLoader()
                    Text("Running Backtest...")
                        .foregroundColor(Color(.lightGray))
                }
                let _ = print("Backtest is running")

            } else {
                Text("No data")
                if backtestViewModel.stockData == nil {
                    let _ = print("backtestViewModel.stockData is nil")
                }
                if backtestViewModel.listData == nil {
                    let _ = print("backtestViewModel.listData is nil")
                }
                if backtestViewModel.stockData!.isEmpty {
                    let _ = print("backtestViewModel.stockData is empty")
                }
                let _ = print("No data available")
            }
        }

    }


    private func getBacktestChartData(stockData: [StockData], values: [Double]) -> LineChartData {
        guard (stockData.count-100) == values.count else { // subtract 100 for the window on the backtest backend
            fatalError("stockData and values must have the same number of elements")
        }
        
        let startingValue = values[0]
        let adjustedValues = values.map { $0 - startingValue }
        let data = LineDataSet(dataPoints: zip(stockData, adjustedValues).map { stock, value in
            let timestamp = Int(stock.timestamp)
            let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
            let xAxisLabel = DateFormatter.localizedString(from: date, dateStyle: .short, timeStyle: .none)
            return LineChartDataPoint(value: value, xAxisLabel: xAxisLabel, description: "")
        }, legendTitle: "Funds", style: LineStyle(lineColour: ColourStyle(colour: backtestViewModel.summary?.pnl ?? 0.0 >= 0 ? Color.green : Color.red), lineType: .curvedLine))

        let gridStyle = GridStyle(numberOfLines: 7,
                                  lineColour: Color(.lightGray).opacity(0.5),
                                  lineWidth: 1,
                                  dash: [8],
                                  dashPhase: 0)
        
        let chartStyle = LineChartStyle(
//            infoBoxPlacement: .infoBox(isStatic: false),
//            infoBoxBorderColour: Color.primary,
//            infoBoxBorderStyle: StrokeStyle(lineWidth: 1),
            xAxisGridStyle: gridStyle,
            xAxisLabelPosition: .bottom,
            xAxisLabelColour: Color.primary,
            xAxisLabelsFrom: .dataPoint(rotation: .degrees(0)),
            yAxisGridStyle: gridStyle,
            yAxisLabelPosition: .leading,
            yAxisNumberOfLabels: 7,
            globalAnimation: .easeInOut(duration: 1))
        
        return LineChartData(dataSets: data, chartStyle: chartStyle)
    }

    private func getStockChartData(data: [StockData]) -> LineChartData {
        guard !data.isEmpty else {
            fatalError("Stock data cannot be empty")
        }

        let startingValue = data[0].close

        let dataPoints = data.map { stockData -> LineChartDataPoint in
            let adjustedClose = stockData.close - startingValue
            let timestamp = Int(stockData.timestamp)
            let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
            let xAxisLabel = DateFormatter.localizedString(from: date, dateStyle: .short, timeStyle: .none)
            
            return LineChartDataPoint(value: adjustedClose, xAxisLabel: xAxisLabel, description: "")
        }
        
        let dataSet = LineDataSet(dataPoints: dataPoints, legendTitle: "Stock",
                                  pointStyle: PointStyle(), style: LineStyle(lineColour: ColourStyle(colour: .blue), lineType: .curvedLine))

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
    
    private func calculatePercentageChanges(values: [Double]) -> [Double] {
        guard !values.isEmpty else { return [] }
        
        var percentageValues: [Double] = [0]
        
        for i in 1..<values.count {
            let previousValue = values[i - 1]
            let currentValue = values[i]
            let percentageChange = (currentValue - previousValue) / previousValue * 100
            percentageValues.append(percentageChange)
        }
        
        return percentageValues
    }

}

