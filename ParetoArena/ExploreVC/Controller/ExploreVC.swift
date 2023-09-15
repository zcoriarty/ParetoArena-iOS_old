//
//  NewExploreVC.swift
//  Pareto
//
//  Created by Zachary Coriarty on 4/10/23.
//

import SwiftUI
import Combine

class ExploreViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        let hostingController = UIHostingController(rootView: ExploreVC())
        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        hostingController.view.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }
}


class ExploreViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var gainers: [Ticker] = []
    @Published var losers: [Ticker] = []

    // Inside NewExploreViewModel
    func loadData(completion: @escaping ([Ticker], [Ticker]) -> Void) {
        let url = EndPoint.kServerBase + EndPoint.topMovers
        
        NetworkUtil.request(apiMethod: url, parameters: nil, requestType: .get, showProgress: true, onSuccess: { [weak self] resp in
            self?.isLoading = false
            
            do {

                let decoder = JSONDecoder()
                let backtestData = try JSONSerialization.data(withJSONObject: resp as Any, options: [])
                print("bd:", backtestData)
                let decodedData = try decoder.decode(TopMoversResponse.self, from: backtestData)
                
                self?.gainers = decodedData.gainers
                self?.losers = decodedData.losers
                
                completion(decodedData.gainers, decodedData.losers)
                
            } catch {
                print("here")
                print(error)
            }
            
        }) { [weak self] error in
            self?.isLoading = false
            print(error)
        }
    }

}


struct ExploreVC: View {
    @State private var macroMarketBanner: [MacroMarketBannerData] = []
    @State private var gainers: [Ticker] = []
    @State private var losers: [Ticker] = []
    @State private var showAllGainers = false
    @State private var showAllLosers = false
    @StateObject private var viewModel = ExploreViewModel()
    @State private var showStockerTickerView = false
    @State var showDetailPage: Bool = false
    @StateObject var alertModel = AlertViewModel()
    
    @Namespace private var animation
    
    init() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = .systemBackground
        appearance.shadowColor = .clear

        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
    
    let symbolToNameMap: [String: String] = ["SPY": "S&P 500", "DIA": "Dow Jones", "QQQ": "Nasdaq", "IWM": "Russell 2000"]
       
       var body: some View {
           ZStack {
               NavigationView {
                   ScrollView(showsIndicators: false) {
                       VStack(alignment: .leading, spacing: 20) {
                           ScrollView(.horizontal, showsIndicators: false) {
                               HStack() {
                                   ForEach(macroMarketBanner) { banner in
                                       MacroBannerView(stockSymbol: banner.stockSymbol, stockCompany: banner.stockCompany, stockPer: banner.stockPer, stockPrice: banner.stockPrice)
                                       Divider()
                                   }
                                   
                                   
                               }.padding([.leading, .trailing, .top])
                               
                           }
                           
                           HStack() {
                               Rectangle()
                                   .frame(width: 10, height: 25)
                                   .foregroundColor(Color(.label))
                                   .cornerRadius(3)
                                   .padding(.trailing, 8)
                               
                               
                               Text("Trading Strategies")
                                   .font(.system(size: 25, weight: .bold))
                               
                               
                           }.padding([.leading, .trailing, .top])
                           
                           
                           HStack() {
                               Rectangle()
                                   .frame(width: 10, height: 25)
                                   .foregroundColor(Color(.label))
                                   .cornerRadius(3)
                                   .padding(.trailing, 8)
                               
                               
                               Text("Top Gainers")
                                   .font(.system(size: 25, weight: .bold))
                               
                               
                           }.padding([.leading, .trailing, .top])
                           
                           tickerTable(tickers: gainers, showAll: $showAllGainers)
                               .padding([.leading, .trailing])
                           
                           HStack() {
                               Rectangle()
                                   .frame(width: 10, height: 25)
                                   .foregroundColor(Color(.label))
                                   .cornerRadius(3)
                                   .padding(.trailing, 8)
                               
                               
                               Text("Top Losers")
                                   .font(.system(size: 25, weight: .bold))
                               
                               
                           }.padding([.leading, .trailing, .top])
                           
                           
                           tickerTable(tickers: losers, showAll: $showAllLosers)
                               .padding([.leading, .trailing])
                           
                           NewsListView(stocks: ["TSLA", "META", "AMZN", "AAL", "UBER", "BP", "AAPL"])
                       }
//                       .padding()
                       
                   }
                   .navigationBarTitle("Explore")
                   .navigationBarItems(trailing:
                                        Button(action: {
                       showStockerTickerView.toggle()
                   }) {
                       Image(systemName: "magnifyingglass")
                           .foregroundColor(.primary)
                   }
                   )
                   .sheet(isPresented: $showStockerTickerView) {
                       SearchVC(searchText: "", alertModel: alertModel)
                    }
                   .onAppear {
                       viewModel.loadData { loadedGainers, loadedLosers in
                           gainers = loadedGainers
                           losers = loadedLosers
                       }
                       // Call getMacroBanner with your symbols list
                       getMacroBanner(symbols: ["SPY", "DIA", "QQQ", "IWM"])
                   }
               }
           }
           .toast(isPresenting: $alertModel.show){
               //Return AlertToast from ObservableObject
               alertModel.alertToast
           }

       }
    
    func getMacroBanner(symbols: [String]) {
        let symbolsParam = symbols.joined(separator: ",")
        let url = EndPoint.kServerBase + EndPoint.multiStock + "?symbols=\(symbolsParam)"
        print(url)

        NetworkUtil.request(apiMethod: url, parameters: nil, requestType: .get, showProgress: true, onSuccess: { resp -> Void in
            guard let jsonDict = resp as? [String: Any] else {
                print("Invalid JSON format")
                return
            }
            
            for (symbol, jsonObject) in jsonDict {
                let snapshot = SwiftParseUtils.parseSnapshot(object: jsonObject as! [String: Any], symbol: symbol, view: nil)

                let stockCompany = symbolToNameMap[snapshot.symbol!] ?? snapshot.symbol
                let stockPrice = Double(snapshot.data?.latestTrade?.p ?? "0") ?? 0
                let open = Double(snapshot.data?.prevDailyBar?.c ?? "0") ?? 0
                let close = Double(snapshot.data?.dailyBar?.c ?? "0") ?? 0
                let stockPer = (close - open) / open * 100

                self.macroMarketBanner.append(MacroMarketBannerData(stockSymbol: symbol, stockCompany: stockCompany ?? "AAPL", stockPer: stockPer, stockPrice: stockPrice))
            }
        }) { error in
            print(error)
            // Replace `self.view.makeToast(error)` with an appropriate SwiftUI alert if needed
        }
    }

    
    private func tickerTable(tickers: [Ticker], showAll: Binding<Bool>) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(tickers.prefix(showAll.wrappedValue ? tickers.count : 5), id: \.ticker) { ticker in
                TickerRow(ticker: ticker)
            }
            
            Button(action: {
                showAll.wrappedValue.toggle()
            }) {
                Text(showAll.wrappedValue ? "Show Less" : "Show All")
                    .font(.system(size: 14, weight:.bold))
                    .foregroundColor(Color(.label))
            }
        }
        
        .padding(14) // Add padding around the VStack
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(8)
    }

    
}

//struct StockerTickerViewControllerWrapper: UIViewControllerRepresentable {
//    typealias UIViewControllerType = StockerTickerViewController
//
//    func makeUIViewController(context: Context) -> StockerTickerViewController {
//        let storyboard = UIStoryboard(name: "Portfolio", bundle: nil)
//        let controller = storyboard.instantiateViewController(withIdentifier: "StockerTickerViewController") as! StockerTickerViewController
//        return controller
//    }
//
//    func updateUIViewController(_ uiViewController: StockerTickerViewController, context: Context) {
//    }
//}


struct MacroBannerView: View {
    let stockSymbol: String
    let stockCompany: String
    let stockPer: Double
    let stockPrice: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(stockCompany)
                .font(.system(size: 16, weight: .heavy))
//                .foregroundColor(.secondary)
            Text(String(format: "%.2f", stockPer) + "%")
                .padding(.horizontal, 4)
                .padding(.vertical, 2)
                .background(stockPer > 0 ? Color(UIColor(named: "UpColor")!) : Color.red)
                .foregroundColor(.white)
                .font(.system(size: 13, weight: .bold))
                .cornerRadius(5)
            Text("$" + String(format: "%.2f", stockPrice))
                .font(.system(size: 13, weight: .bold))
        }
        .frame(width: 120)
//        .padding(12)
//        .background(Color.secondary)
        .cornerRadius(14)
    }
}

class DummyViewController: UIViewController, ObservableObject {

}




struct TickerRow: View {
    let ticker: Ticker
    @State private var showStats = false
    @State private var showPopover = false
    @State private var showBuySellVC = false
    

    var body: some View {
        Button(action: {
            
            self.showBuySellVC = true
        }) {

            HStack {
                Text(ticker.ticker)
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("$" + String(format: "%.2f", ticker.todaysChange))
                        .font(.system(size: 16, weight: .bold))
                    
                    Text(String(format: "%.2f%%", ticker.todaysChangePerc))
                        .font(.system(size: 16, weight: .regular))
                        .padding(.horizontal, 4)
                        .background(ticker.todaysChangePerc >= 0 ? Color(UIColor(named: "UpColor")!) : Color.red)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                }
            }
        }
        .foregroundColor(.primary)
        .sheet(isPresented: $showBuySellVC) {
//            let _ = convertTickerToCurrentStock(ticker)
            SearchVC(searchText: ticker.ticker, alertModel: AlertViewModel())
        }
    }

        
}

struct MacroMarketBannerData: Identifiable {
    let id = UUID()
    let stockSymbol: String
    let stockCompany: String
    let stockPer: Double
    let stockPrice: Double
}


struct TopMoversResponse: Codable {
    let gainers: [Ticker]
    let losers: [Ticker]
}

struct Ticker: Codable {
    let day: TickerDetails
    let lastQuote: LastQuote
    let lastTrade: LastTrade
    let min: TickerDetails
    let prevDay: TickerDetails
    let todaysChange: Double
    let todaysChangePerc: Double
    let ticker: String
    let updated: Int64
}

struct TickerDetails: Codable {
    let av: Int?
    let c: Double
    let h: Double
    let l: Double
    let o: Double
    let v: Int
    let vw: Double
}

struct LastQuote: Codable {
    let P: Double
    let S: Int
}

struct LastTrade: Codable {
    let c: String?
    let i: String
    let p: Double
    let s: Int
    let t: Int
    let x: Int
}


//struct ExploreVC_Previews: PreviewProvider {
//    static var previews: some View {
//        ExploreVC()
//    }
//}





