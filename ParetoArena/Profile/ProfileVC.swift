//
//  NewProfileVC.swift
//  Pareto
//
//  Created by Zachary Coriarty on 3/18/23.
//

import Foundation
import SwiftUI
import Combine
import SDWebImageSwiftUI
import UIKit
import SwiftUICharts


struct NewProfileVC: View {
    @ObservedObject var viewModel = PortfolioChartData()
    @State private var isProfileViewPresented = false
    @State private var isEditViewPresented = false
    @State private var isPresentingTransactionsView = false

    var body: some View {
        ZStack {
            NavigationView {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        PortfolioGraph(chartData: viewModel)
                            .padding(.bottom)
                        
//                        UserInfo()
                        
                        VStack(alignment: .leading, spacing: 5){
                            Button(action: {
                                isEditViewPresented.toggle()
                            }, label: {
                                Text("Settings")
                                    .foregroundColor(Color(.label))
                                    .font(.system(size: 20, weight: .semibold))
                            })
                            .padding()
                            .sheet(isPresented: $isEditViewPresented) {
                                EditProfileView()
                            }
                                
                            Button(action: {
                                USER.shared.logout()
                            }, label: {
                                Text("Logout")
                                    .foregroundColor(Color(.label))
                                    .font(.system(size: 20, weight: .semibold))
                            })
                            .padding()
                        }
                    }
                }
                .navigationBarTitle("Profile")
//                .navigationBarItems(trailing:
//                    Button(action: {
//                        isPresentingTransactionsView = true
//                    }) {
//                        Image(systemName: "wallet.pass.fill")
//                            .foregroundColor(.primary)
//                    }
//                )
                
            }
        }
        .onAppear{
            viewModel.updateChartData(selectedRange: 4) // TODO: Change to all-time(currently set to year)
        }
    }
}



    

struct TapToDismissView: View {
    @Binding var isPresented: Bool

    var body: some View {
        Color.clear
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isPresented = false
                }
            }
    }
}


class ProfileViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        let hostingController = UIHostingController(rootView: NewProfileVC())
        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        hostingController.view.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        self.tabBarController?.tabBar.updateAppearance()
        
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        setupTabBarAppearance()
//    }
}


struct InvestingSection: View {
    @State private var isExpanded = false
    let profile: Profile

    private let topItems: [(String, (Profile) -> String)] = [
        ("Daytrades Remaining", { String(3 - Int($0.daytradeCount)) }),
        ("Buying Power", { $0.buyingPower }),
        ("Cash", { $0.cash }),
        ("Portfolio Value", { $0.portfolioValue })
    ]

    private func remainingItems() -> [(String, (Profile) -> String)] {
        let allItems: [(String, (Profile) -> String)] = [
            // Add all properties with corresponding closures
            ("Currency", { $0.currency }),
            ("Status", { $0.status }),
            // ...
        ]
        return allItems.filter { item in !topItems.contains { $0.0 == item.0 } }
    }

    private func keyValuePairView(key: String, value: String) -> some View {
        HStack {
            Text(key)
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
            Text(value)
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .trailing)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            VStack(alignment: .leading, spacing: 5) {

                Text("Account Details")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(.primary)
                Divider()

                ForEach(topItems, id: \.0) { item in
                    keyValuePairView(key: item.0, value: item.1(profile))
                }

                if isExpanded {
                    ForEach(remainingItems(), id: \.0) { item in
                        keyValuePairView(key: item.0, value: item.1(profile))
                    }
                }
            }

            Spacer(minLength: 25)

            Button(action: {
                isExpanded.toggle()
            }) {
                HStack {

                    Text("Tap to Expand")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Spacer()

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                }
            }
            .padding(.bottom, 5)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .padding(.horizontal)
    }
}



struct PortfolioGraph: View {
    @ObservedObject var chartData: PortfolioChartData
    @State private var showStatistics = false
    

    private var profitLoss: Double {
        (chartData.equity.last ?? 0.0) - (chartData.equity.first ?? 0.0)
    }
    private var isProfit: Bool {
        profitLoss > 0
    }

    var body: some View {
        VStack {
//            HStack {
//                Text("Lifetime PnL: \(profitLoss, specifier: "%.2f")")
//                    .font(.system(size: 22, weight: .semibold))
//                    .foregroundColor(.white)
//                    .padding(.leading)
//                Spacer()
//            }
//            .padding(.top)

            PortfolioLineChartView(chartData: chartData, isProfile: true)
                .frame(height: 200) // Set a specific height for the graph
                .padding(.horizontal)

            if showStatistics {
                let columns = [GridItem(.flexible()), GridItem(.flexible())]
                LazyVGrid(columns: columns, alignment: .center, spacing: 20) {
                    ForEach(1...6, id: \.self) { index in
                        let (title, value) = statisticText(index)
                        VStack {
                            Text("$\(value)")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                            Text(title)
                                .font(.system(size: 14, weight: .light))
                                .foregroundColor(Color.secondary)
                        }
                    }
                }
                .padding(.top)
            }

            Spacer()
            HStack {

                Text("Show Statistics")
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .padding(.leading)
                Spacer()
                Image(systemName: showStatistics ? "chevron.up" : "chevron.down")
                    .font(.system(size: 14))
                    .foregroundColor(Color.primary)
                    .padding([.bottom, .top])
                    .padding(.trailing)
            }
            .onTapGesture {
                withAnimation {
                    showStatistics.toggle()
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(isProfit ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
        .cornerRadius(10)
        .padding(.horizontal)
    }
    
    private func statisticText(_ index: Int) -> (String, String) {
        switch index {
        case 1:
            return ("Initial Equity", String(format: "%.2f", chartData.equity.first ?? 0.0))
        case 2:
            return ("Final Equity", String(format: "%.2f", chartData.equity.last ?? 0.0))
        case 3:
            return ("Total P/L", String(format: "%.2f", profitLoss))
        case 4:
            return ("Highest Equity", String(format: "%.2f", chartData.equity.max() ?? 0.0))
        case 5:
            return ("Lowest Equity", String(format: "%.2f", chartData.equity.min() ?? 0.0))
        case 6:
            return ("Total Value", String(format: "%.2f", chartData.totalValue))
        default:
            return ("", "")
        }
    }


}

struct UserInfo: View {
    @State private var profile: Profile? = nil
    @State private var isExpanded: Bool = false
    
    var body: some View {
        VStack {
            Text("Profile Information")
                .font(.largeTitle)
                .padding()
            
            if let profile = profile {
                VStack {
                    Text("ID: \(profile.id)")
                    Text("Account Number: \(profile.accountNumber)")
                    Text("Status: \(profile.status)")
                    Text("Crypto Status: \(profile.cryptoStatus)")
                    Text("Currency: \(profile.currency)")
                    // Add all other properties here, in the same manner
                    
                    Button(action: {
                        isExpanded.toggle()
                    }) {
                        Text(isExpanded ? "Collapse" : "Expand")
                            .font(.title)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    
                    if isExpanded {
                        // Other fields to display when the card is expanded
                        // Just copying a few as an example
                        Text("Buying Power: \(profile.buyingPower)")
                        Text("Regt Buying Power: \(profile.regtBuyingPower)")
                        // Continue with the rest of the fields
                    }
                }
                .padding()
                .border(Color.black, width: 1)
            } else {
                Text("Loading...")
            }
        }
        .onAppear(perform: loadData)
    }
    
    func loadData() {
        let endpoint = EndPoint.kServerBase + EndPoint.TradingView
        guard let url = URL(string: endpoint) else {
            print("Invalid URL")
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Error fetching data: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            do {
                print("datasa", data)
                let decodedData = try JSONDecoder().decode(Profile.self, from: data)
                DispatchQueue.main.async {
                    self.profile = decodedData
                }
            } catch {
                print("Error decoding data: \(error.localizedDescription)")
            }
        }.resume()
    }
}

struct Profile: Codable {
    let id: String
    let accountNumber: String
    let status: String
    let cryptoStatus: String
    let currency: String
    let buyingPower: String
    let regtBuyingPower: String
    let daytradingBuyingPower: String
    let cash: String
    let cashWithdrawable: String
    let cashTransferable: String
    let accruedFees: String
    let pendingTransferOut: String
    let portfolioValue: String
    let patternDayTrader: Bool
    let tradingBlocked: Bool
    let transfersBlocked: Bool
    let accountBlocked: Bool
    let createdAt: String
    let tradeSuspendedByUser: Bool
    let multiplier: String
    let shortingEnabled: Bool
    let equity: String
    let lastEquity: String
    let longMarketValue: String
    let shortMarketValue: String
    let initialMargin: String
    let maintenanceMargin: String
    let lastMaintenanceMargin: String
    let sma: String
    let daytradeCount: Int
    let previousClose: String
    let lastLongMarketValue: String
    let lastShortMarketValue: String
    let lastCash: String
    let lastInitialMargin: String
    let lastRegtBuyingPower: String
    let lastDaytradingBuyingPower: String
    let lastBuyingPower: String
    let lastDaytradeCount: Int
    let clearingBroker: String


    enum CodingKeys: String, CodingKey {
        case id
        case accountNumber = "account_number"
        case status
        case cryptoStatus = "crypto_status"
        case currency
        case buyingPower = "buying_power"
        case regtBuyingPower = "regt_buying_power"
        case daytradingBuyingPower = "daytrading_buying_power"
        case cash
        case cashWithdrawable = "cash_withdrawable"
        case cashTransferable = "cash_transferable"
        case accruedFees = "accrued_fees"
        case pendingTransferOut = "pending_transfer_out"
        case portfolioValue = "portfolio_value"
        case patternDayTrader = "pattern_day_trader"
        case tradingBlocked = "trading_blocked"
        case transfersBlocked = "transfers_blocked"
        case accountBlocked = "account_blocked"
        case createdAt = "created_at"
        case tradeSuspendedByUser = "trade_suspended_by_user"
        case multiplier
        case shortingEnabled = "shorting_enabled"
        case equity
        case lastEquity = "last_equity"
        case longMarketValue = "long_market_value"
        case shortMarketValue = "short_market_value"
        case initialMargin = "initial_margin"
        case maintenanceMargin = "maintenance_margin"
        case lastMaintenanceMargin = "last_maintenance_margin"
        case sma
        case daytradeCount = "daytrade_count"
        case previousClose = "previous_close"
        case lastLongMarketValue = "last_long_market_value"
        case lastShortMarketValue = "last_short_market_value"
        case lastCash = "last_cash"
        case lastInitialMargin = "last_initial_margin"
        case lastRegtBuyingPower = "last_regt_buying_power"
        case lastDaytradingBuyingPower = "last_daytrading_buying_power"
        case lastBuyingPower = "last_buying_power"
        case lastDaytradeCount = "last_daytrade_count"
        case clearingBroker = "clearing_broker"
    }

}



