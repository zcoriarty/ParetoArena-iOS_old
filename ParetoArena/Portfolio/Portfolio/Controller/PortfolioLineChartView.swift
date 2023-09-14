//
//  PortfolioLineChartView.swift
//  Pareto
//
//  Created by Zachary Coriarty on 4/29/23.
//

import SwiftUI
import SwiftUICharts
import Charts

struct PortfolioLineChartView: View {
    
    @ObservedObject var chartData: PortfolioChartData
    @State private var selectedRange: Int = 0
    let isProfile: Bool
    
    private let ranges = ["1D", "1W", "1M", "3M", "1Y"]
    var body: some View {
        VStack {
            
            if let data = lineChartData() {
                LineChart(chartData: data)
                    .touchOverlay(chartData: data, specifier: "%.2f")
                    .infoBox(chartData: data)
                    .headerBox(chartData: data)
                    .id(data.id)
                    .frame(height: 200)
            } else {
                Text("No data available")
                    .foregroundColor(.primary)
            }
            
            if !isProfile {
                HStack(spacing: 15) {
                    ForEach(0..<ranges.count, id: \.self) { index in
                        DateRangeButton(title: ranges[index], index: index, selectedIndex: $selectedRange, viewModel: chartData)
    //                            .padding(.horizontal, 2)
    //                            .padding(.vertical, 4)
                    }
                }
                .padding(.top, 10)
            }

        }
    }
    
    func lineChartData() -> LineChartData? {
        let dateFormatter = DateFormatter()
//        intraDayFormatter.dateFormat = "h:mm a"
//
//        let intraWeekAndMonthFormatter = DateFormatter()
//        intraWeekAndMonthFormatter.dateFormat = "h:mm a, MMM d"
//
//        let intra3MonthsAndYearFormatter = DateFormatter()
//        intra3MonthsAndYearFormatter.dateFormat = "MMM d, yyyy"

        let dataPoints: [LineChartDataPoint]

        switch selectedRange {
        case 0: // "1D"
            // Format it as hours:minutes AM/PM
            dataPoints = zip(chartData.timestamp, chartData.equity).compactMap { timestampString, equity in
                let timestamp = Date(timeIntervalSince1970: Double(timestampString) ?? 0.0)
                dateFormatter.dateFormat = "h:mm a"
                let label = dateFormatter.string(from: timestamp)
                return LineChartDataPoint(value: equity, xAxisLabel: label, description: label)
            }
        case 1, 2: // "1W", "1M"
            // Format as hours:minutes AM/PM, Month day
            dataPoints = zip(chartData.timestamp, chartData.equity).compactMap { timestampString, equity in
                let timestamp = Date(timeIntervalSince1970: Double(timestampString) ?? 0.0)
//                dateFormatter.dateFormat = "h:mm a, MMM d"
                dateFormatter.dateFormat = "h:mm a, MMM d"
                let label = dateFormatter.string(from: timestamp)
                return LineChartDataPoint(value: equity, xAxisLabel: label, description: label)
            }
        default: // "3M", "1Y"
            // Format as Month day, year
            dataPoints = zip(chartData.timestamp, chartData.equity).compactMap { timestampString, equity in
                let timestamp = Date(timeIntervalSince1970: Double(timestampString) ?? 0.0)
                dateFormatter.dateFormat = "MMM d, yyyy"
                let label = dateFormatter.string(from: timestamp)
                return LineChartDataPoint(value: equity, xAxisLabel: label, description: label)
            }
        }

        let data = LineDataSet(dataPoints: dataPoints,
//                               legendTitle: "Equity",
                               pointStyle: PointStyle(pointSize: 0.8, borderColour: Color(.label), fillColour: Color(.label)),
                               style: LineStyle(lineColour: ColourStyle(colour: chartData.lineColor), lineType: .curvedLine))

//        let metadata = ChartMetadata(title: "Portfolio Chart", subtitle: "")
        
        let gridStyle  = GridStyle(numberOfLines: 7,
                                   lineColour   : Color(.lightGray).opacity(0.5),
                                   lineWidth    : 1,
                                   dash         : [8],
                                   dashPhase    : 0)
        
        let chartStyle = LineChartStyle(infoBoxPlacement    : .infoBox(isStatic: false),
                                        infoBoxBorderColour : Color.primary,
                                        infoBoxBorderStyle  : StrokeStyle(lineWidth: 1),
                                        
//                                        markerType          : .vertical(attachment: .line(dot: .style(DotStyle()))),
                                        
                                        xAxisGridStyle      : gridStyle,
                                        xAxisLabelPosition  : .bottom,
                                        xAxisLabelColour    : Color.primary,
                                        xAxisLabelsFrom     : .dataPoint(rotation: .degrees(0)),
                                        
                                        yAxisGridStyle      : gridStyle,
                                        yAxisLabelPosition  : .leading,
                                        yAxisLabelColour    : Color.primary,
                                        yAxisNumberOfLabels : 7,
                                        
//                                        baseline            : .minimumWithMaximum(of: 5000),
//                                        topLine             : .maximum(of: 20000),
                                        
                                        globalAnimation     : .easeOut(duration: 1))
        
        return LineChartData(dataSets       : data,
//                             metadata       : metadata,
                             chartStyle     : chartStyle)
    }
    
    func isRangeIntraday() -> Bool {
        return selectedRange == 0 // change this condition according to your range ordering
    }

}


struct DateRangeButton: View {
    var title: String
    var index: Int
    @Binding var selectedIndex: Int
    @Environment(\.isEnabled) private var isEnabled: Bool
    @ObservedObject var viewModel: PortfolioChartData

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
                            .fill(selectedIndex == index ? Color.secondary.opacity(0.35).opacity(isEnabled ? 1.0 : 0.5) : Color.clear)
                            .cornerRadius(9)
//                    }
                )
            
        }
    }
}


