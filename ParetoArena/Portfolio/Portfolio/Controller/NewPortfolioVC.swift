//
//  NewPortfolioVC.swift
//  Pareto
//
//  Created by Zachary Coriarty on 4/28/23.
//

import SwiftUI
import AlertToast

//class PortfolioHostingVC: UIViewController {
//
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        navigationController?.navigationBar.isHidden = true
//
//        let exploreAppViewController = PortfolioViewController()
//        addChild(exploreAppViewController)
//        exploreAppViewController.didMove(toParent: self) // add this line
//
//
//
//        view.addSubview(exploreAppViewController.view)
//        exploreAppViewController.view.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            exploreAppViewController.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
//            exploreAppViewController.view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
//            exploreAppViewController.view.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
//            exploreAppViewController.view.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
//        ])
//
//
//    }
//
//
//}
//
//
//class PortfolioViewController: UIViewController {
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        let hostingController = UIHostingController(rootView: WatchlistView())
//        addChild(hostingController)
//        view.addSubview(hostingController.view)
//        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
//        hostingController.view.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
//        hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
//        hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
//        hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
//
//        var _ = ToggleModel() // used for light/dark mode
//
//        self.tabBarController?.tabBar.updateAppearance()
//
//
//
//    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        setupTab()
//    }
//
//    func setupTab() {
//        self.tabBarController?.tabBar.unselectedItemTintColor = .systemBackground
//        self.tabBarController?.tabBar.backgroundImage = UIImage()
//        self.tabBarController?.tabBar.shadowImage = UIImage()
//        self.tabBarController?.tabBar.backgroundColor = .label
//    }

//}


struct WatchlistView: View {
    @State private var expandedSections: Set<Int> = [0]
    @StateObject private var viewModel = WatchlistViewModel()
    @StateObject var portfolioChartData = PortfolioChartData()
    
    @State private var watchlistAction: Int? = nil
    @State private var isPickerVisible = false
    @State private var isSheetVisible = false
    @State private var palIsPresenting = false
    @State private var watchlistName = ""
    @State private var watchlistDict: [String: String] = [:]
    @StateObject var alertModel = AlertViewModel()
    @State private var isPresentingTransactionsView = false



    
    var body: some View {
        
        NavigationView {
            ScrollView(showsIndicators: false)  {
                HStack {
                    VStack(alignment: .leading){
                        Text("Portfolio Value")
                            .font(.system(size: 30, weight: .light))
                        Text("$" + String(format: "%.2f", portfolioChartData.totalValue))
                            .font(.system(size: 38, weight: .bold))
                    }
                    
                    Spacer()
                    
                    VStack {
                        HStack {
                            Button(action: {
    //                            palIsPresenting.toggle()
                               alertModel.alertToast = AlertToast(displayMode: .hud, type: .systemImage("x.circle", .red), title: "Pal not active for alpha", subTitle: "Temporarily deactivated")
                            }) {
                               Image(systemName: "bubble.left.and.bubble.right.fill")
                                   .foregroundColor(.primary)

                            }
                            
                        }
                        Spacer()
                    }
                }
                
                VStack {
                    PortfolioLineChartView(chartData: portfolioChartData, isProfile: false)
                }
                
                Divider()
                    
                Spacer()
                if viewModel.activeStrategies.count > 0 {
                    VStack(alignment: .leading) {
                        Text("Active Strategies")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.secondary)

                        activeStrategyView()
                    }
                }
                
                VStack(alignment: .leading) {
                    HStack {
                        Text("Lists")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.secondary)
                        Spacer()
                        Button(action: {
                            isPickerVisible = true
                        }) {
                            Image(systemName: "ellipsis")
                                .foregroundColor(.secondary)
                        }
                        .actionSheet(isPresented: $isPickerVisible) {
                            ActionSheet(title: Text("Watchlist Actions"), message: nil, buttons: [
                                .default(Text("Create Watchlist"), action: {
                                    watchlistAction = 1
                                    isSheetVisible = true
                                }),
                                .default(Text("Delete Watchlist"), action: {
                                    watchlistAction = 2
                                    isSheetVisible = true
                                }),
                                .cancel()
                            ])
                        }
                        .sheet(isPresented: $isSheetVisible) {
                            if #available(iOS 16.0, *) {
                                if watchlistAction == 1 {
                                    createWatchlistView(isSheetVisible: $isSheetVisible)
                                        .presentationDetents([.medium])
                                } else if watchlistAction == 2 {
                                    deleteWatchlistView(isSheetVisible: $isSheetVisible)
                                        .presentationDetents([.medium])
                                }
                            } else {
                                if watchlistAction == 1 {
                                    createWatchlistView(isSheetVisible: $isSheetVisible)
                                } else if watchlistAction == 2 {
                                    deleteWatchlistView(isSheetVisible: $isSheetVisible)
                                }

                            }
                        }
                    }

                    ForEach(Array(zip(["Positions"] + viewModel.watchingKeys, 0...)), id: \.0) { (section, sectionIndex) in
                        let isExpanded = expandedSections.contains(sectionIndex)
                        sectionView(section: section, sectionIndex: sectionIndex, isExpanded: isExpanded)
                    }
                }
            }
            .refreshable(action: refreshData)
            .sheet(isPresented: $palIsPresenting) {
                
                PalApp()
             }
            .padding()
            .toast(isPresenting: $alertModel.show){
                // Return AlertToast from ObservableObject
                alertModel.alertToast
            }
        }
        
    }

    private func sectionView(section: String, sectionIndex: Int, isExpanded: Bool) -> some View {
        VStack(spacing: 0) {
            WatchlistSectionHeader(viewModel: viewModel,
                         title: section,
                         cellCount: (section == "Positions" ? viewModel.holdings : viewModel.watching[section])?.count ?? 0,
                         isExpanded: isExpanded,
                         section: sectionIndex,
                         onToggle: toggleSection,
                        alertModel: alertModel)
            if isExpanded {
                ForEach((section == "Positions" ? viewModel.holdings : viewModel.watching[section]) ?? [], id: \.symbol) { row in
                    ListRow(currentStock: row)
                }
                WatchlistSectionFooter()
            }
        }
        .background(Color.secondary.opacity(0.15))
        .cornerRadius(10)
        .padding(.bottom, 10)
    }

    @ViewBuilder
    func createWatchlistView(isSheetVisible: Binding<Bool>) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Create Watchlist") 
                .font(.system(size: 24, weight: .heavy))
                .foregroundColor(.white)
//                .padding(.horizontal, 10)
            TextField("Enter watchlist name", text: $watchlistName)
                .padding(10)
                .background(RoundedRectangle(cornerRadius: 5).stroke(Color.gray.opacity(0.3)))
            Button(action: {
                if !watchlistName.isEmpty {
                    if viewModel.watchlistDict.keys.contains(watchlistName) {
                        alertModel.alertToast = AlertToast(displayMode: .hud, type: .systemImage("x.circle", .red), title: "Name Taken", subTitle: "Please try again.")
                    } else {
                        // Replace with your own API endpoint and request method
                        let url = EndPoint.kServerBase + EndPoint.createWatchList
                        let params = ["name": String(watchlistName)] as [String: String]
                        NetworkUtil.request(apiMethod: url, parameters: params, requestType: .post, showProgress: true, view: nil, onSuccess: { resp -> Void in
                            
                            if let jsonObject = resp as? [String: Any] {
                                if jsonObject["name"] as! String == String(watchlistName) {
                                    isSheetVisible.wrappedValue = false
                                    alertModel.alertToast = AlertToast(displayMode: .hud, type: .systemImage("checkmark", .green), title: "Watchlist Created", subTitle: nil)

                                } else {
                                    isSheetVisible.wrappedValue = false
                                    alertModel.alertToast = AlertToast(displayMode: .hud, type: .systemImage("x.circle", .red), title: "Creation Failed", subTitle: "Please try again.")
                                    
                                }
                            } else {
                                isSheetVisible.wrappedValue = false
                                alertModel.alertToast = AlertToast(displayMode: .hud, type: .systemImage("x.circle", .red), title: "Creation Failed", subTitle: "Please try again.")
                            }
                        }) { error in
                            print(error)
                            alertModel.alertToast = AlertToast(displayMode: .hud, type: .systemImage("x.circle", .red), title: "Creation Failed", subTitle: "Please try again.")
                            isSheetVisible.wrappedValue = false
                        }
                    }
                }
            }, label: {
                Text("Create Watchlist")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(watchlistName == "" ? Color.secondary : Color.blue)
                    .cornerRadius(20)
                
            })
            .padding()
            .background(Color(.systemBackground))
        }
        .padding()
    }

    @ViewBuilder
    func deleteWatchlistView(isSheetVisible: Binding<Bool>) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Delete Watchlist")
                .font(.system(size: 24, weight: .heavy))
                .foregroundColor(.white)
                .padding(.top, 15)
                .padding(.horizontal, 10)

            List {
                ForEach(viewModel.watchlistDict.keys.sorted(), id: \.self) { key in
                    HStack {
                        Text(key)
                        Spacer()
                        if watchlistName == key {
                            Image(systemName: "checkmark")
                                .foregroundColor(.red)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        watchlistName = key
                    }
                }
            }

                Spacer()
                Button(action: {
                    if let watchlistId = viewModel.watchlistDict[watchlistName] {
                        // Replace with your own API endpoint and request method
                        var url = EndPoint.kServerBase + EndPoint.deleteWatchlist
                        url = url.replacingOccurrences(of: "{watchlist_id}", with: watchlistId)
                        print("URLSD", url)
//                        let params = ["watchlist_id": watchlistId] as [String: Any]
                        NetworkUtil.request(apiMethod: url, parameters: nil, requestType: .delete, showProgress: true, view: nil, onSuccess: { resp -> Void in

                            // Remove the deleted watchlist from the watchlistDict dictionary
                            watchlistDict.removeValue(forKey: watchlistName)
                            watchlistName = ""
                            isSheetVisible.wrappedValue = false
                            alertModel.alertToast = AlertToast(displayMode: .hud, type: .systemImage("checkmark", .green), title: "Watchlist Deleted", subTitle: nil)
                            print("Watchlist Deleted")

                        }) { error in
                            print(error)
                            isSheetVisible.wrappedValue = false
                            alertModel.alertToast = AlertToast(displayMode: .hud, type: .systemImage("x.circle", .red), title: "Delete Failed", subTitle: "Please try again.")
                        }
                    }
                }, label: {
                    Text("Delete Watchlist")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(watchlistName == "" ? Color.secondary : Color.red)
                        .cornerRadius(20)

                })
                .padding()
                .background(Color(.systemBackground))

        }
    }


    
    private func activeStrategyView() -> (some View)? {
        
            ScrollView(.horizontal) {
                LazyHStack() {
                    ForEach(viewModel.activeStrategies, id: \.algorithm) { strategy in
                        if #available(iOS 16.0, *) {
                            ActiveStrategyCard(strategy: strategy, alertModel: alertModel)
                        }
                    }
                }
            }
        
        
    }

    func toggleSection(section: Int) {
        if expandedSections.contains(section) {
            expandedSections.remove(section)
        } else {
            expandedSections.insert(section)
        }
    }
    
    @Sendable private func refreshData() async {
        await viewModel.refreshData()
        await portfolioChartData.refreshData()
    }


}

struct WatchlistSectionHeader: View {
    let viewModel: WatchlistViewModel
    let title: String
    let cellCount: Int
    let isExpanded: Bool
    let section: Int
    let onToggle: (Int) -> Void
    @ObservedObject var alertModel: AlertViewModel

    
    var body: some View {
        SectionHeader(viewModel: viewModel,
                      title: title,
                      cellCount: cellCount,
                      isExpanded: isExpanded,
                      section: section,
                      onToggle: onToggle,
                      alertModel: alertModel)
            .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
            .padding(.top, 10)
    }
}





@available(iOS 16.0, *)
struct ActiveStrategyCard: View {
    let strategy: ActiveStrategy
    @StateObject var alertModel: AlertViewModel
    
    @State private var isLinkActive = false
    @State private var isSheetPresented = false
    
    var body: some View {
        Button(action: {
            isSheetPresented = true
        }) {
            VStack(alignment: .leading) {
                HStack() {
                    Text(strategy.algorithm)
                        .font(.system(size: 16, weight: .bold))
                        .padding(.top, 5)
                    Spacer()
                }
                Spacer()
                
                HStack {
                    VStack(alignment: .leading){
//                        if strategy.averageDrawdown != 0.0 {
//                            Text("\(strategy.averageDrawdown, specifier: "%.2f")")
//                                .font(.subheadline)
//                        } else {
//                            LoadingIndicator(animation: .threeBalls, color: .secondary, size: .small, speed: .fast)
//                        }
//                        Text("Drawdown")
//                            .font(.system(size: 12, weight: .light))
                        
                        if strategy.totalPosition != 0 {
                            Text("\(strategy.totalPosition)")
                                .font(.subheadline)
                        } else {
                            LoadingIndicator(animation: .threeBalls, color: .secondary, size: .small, speed: .fast)
                                .padding(.vertical, -10)
                        }
                        Text("Total Shares")
                            .font(.system(size: 12, weight: .light))

                    }
                    Spacer()
                    VStack(alignment: .leading) {
                        if strategy.totalProfitLoss != 0 {
                            Text("$\(strategy.totalProfitLoss)")
                                .font(.subheadline)
                        } else {
                            LoadingIndicator(animation: .threeBalls, color: .secondary, size: .small, speed: .fast)
                                .padding(.vertical, -10)
                        }
                        Text("Returns")
                            .font(.system(size: 12, weight: .light))
                    }
                }
                .padding(.bottom, 5)
            }
            .padding(10)
            .frame(width: 180, height: 120)
            .background(Color.secondary.opacity(0.15))
            .cornerRadius(10)
        }
        .buttonStyle(PlainButtonStyle()) // Removes the default button appearance
        .fullScreenCover(isPresented: $isSheetPresented) {
            AlgorithmView(algorithmName: strategy.algorithm, runID: strategy.tradedSymbols.first?.runID ?? "", alertModel: alertModel)
        }
    }
}


struct WatchlistSectionFooter: View {
    var body: some View {
        Rectangle()
            .fill(Color.clear)
            .frame(height: 10)
            
    }
}

struct ListRow: View {
    let currentStock: NewCurrentStock
    @State private var presentStockVC = false
    
    var body: some View {
        Button(action: {
            presentStockVC.toggle()
        }) {
            HStack {
                VStack(alignment: .leading) {
                    Text(currentStock.symbol ?? "")
                        .font(.system(size: 16, weight: .semibold))
                    Text(currentStock.displayName ?? "")
                        .font(.system(size: 12, weight: .light))
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Text("$\(getPrice(obj: currentStock))")
                        .font(.system(size: 16, weight: .regular))
                    
                    let todaysChange = getChangeToday(obj: currentStock)
                    Text("\(todaysChange)%")
                        .font(.system(size: 15, weight: .bold))
                        .padding(.vertical, 4)
                        .padding(.horizontal, 6)
                        .background(Double(todaysChange) ?? 0.0 >= 0.0 ? .green : .red)
                        .cornerRadius(5)
                        .foregroundColor(.white)
                }
            }
            .frame(height: 70)
            .padding(.leading, 10)
            .padding(.trailing, 15)
        }
        .foregroundColor(Color(.label))
        .sheet(isPresented: $presentStockVC) {
            NewBuySellVC(currentStock: currentStock)
    }
}

    
    private func getChangeToday(obj: NewCurrentStock) -> String {
        var dayDiff: Double = 0.0
        var changeTodayPct: String = ""
        if let ticker = obj.ticker {
            let open = ticker.prevDailyBar?.c ?? 100
            let close = ticker.dailyBar?.c ?? 100
            dayDiff = close - open
            changeTodayPct = String(format: "%.2f", ((dayDiff / open) * 100.0))
            
        }
        
        _ = Double(obj.changeToday ?? "0.0") ?? dayDiff
        return changeTodayPct
    }
        
    private func getPrice(obj: NewCurrentStock) -> String {
        if let ticker = obj.ticker {
            _ = ticker.prevDailyBar?.c ?? 100
            _ = ticker.dailyBar?.c ?? 100
            
        }
        var price: Double = 0.0
        if let cp = obj.currentPrice {
            price = Double(cp) ?? 0.1
        } else {
            price = obj.ticker?.dailyBar?.c ?? 0.0
        }
//        let price = obj.ticker?.dailyBar?.c ?? Double(obj.currentPrice ?? "0.123456")
        let doublePrice = String(format: "%.2f", price)
        
        return doublePrice

    }
}

struct SectionHeader: View {
    let viewModel: WatchlistViewModel
    let title: String
    let cellCount: Int
    let isExpanded: Bool
    let section: Int
    let onToggle: (Int) -> Void
    @State private var presentDeleteSheet = false
    @ObservedObject var alertModel: AlertViewModel

    
    var body: some View {
        Button(action: { onToggle(section) }) { // Wrap VStack with Button
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    VStack(alignment: .leading){
                        Text(title)
                            .font(.system(size: 18, weight: .bold))
                        Text("\(viewModel.watching[title]?.count ?? viewModel.holdings.count) Symbols")
                            .font(.system(size: 12, weight: .semibold))
                    }
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.secondary)
                        .font(.system(size: 14))
                }
                if isExpanded && section != 0 {
                    Button(action: { presentDeleteSheet.toggle() },
                           label: {
                        HStack(spacing: 4) {
                            Image(systemName: "trash.circle")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                            Text("Edit List")
                                .foregroundColor(.secondary)
                                .font(.system(size: 14))
                        }
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(Color.secondary.opacity(0.15))
                        .cornerRadius(12.5)

                    })
                    .sheet(isPresented: $presentDeleteSheet) {
                        EditWatchlistView(viewModel: viewModel, watchlistName: title, alertModel: alertModel)
                    }
                }
            }
            .padding(.leading, 10)
            .padding(.trailing, 15)
            .padding(.top, 10)
            .padding(.bottom, isExpanded && section != 0 ? 10 : 20)
        }
        .buttonStyle(PlainButtonStyle()) // Use plain button style to remove default styling
    }
}




struct WatchlistView_Previews: PreviewProvider {
    static var previews: some View {
        WatchlistView()
    }
}

