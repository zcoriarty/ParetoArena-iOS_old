//
//  SearchVC.swift
//  Pareto
//
//  Created by Zachary Coriarty on 4/30/23.
//

import SwiftUI

import SwiftUI
import Combine
import Alamofire
import AlertToast

struct SearchVC: View {
    @State var searchText: String
//    @State private var stocksArray: NSMutableArray = []
    @StateObject private var viewModel = SearchViewModel()
    @State private var showAlert: Bool = false
    @State private var selectedSymbol: String = ""
    @State private var selectedIndex: Int = 0
    @State private var selectedWatchlist: String = ""
    @State private var showPicker: Bool = false
    @ObservedObject var alertModel: AlertViewModel
    
    @Environment(\.presentationMode) var presentationMode

    
    var body: some View {
        NavigationView {
            VStack {
                searchBar
                    .padding(.top, 20)
                stockTickerList
            }
            .navigationBarHidden(true)
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Choose Watchlist"), message: nil, primaryButton: .cancel({
                    removeFromSuperview()
                }), secondaryButton: .default(Text(selectedWatchlist), action: {
                    favStocks(symbol: selectedSymbol, index: selectedIndex)
                }))
            }
            .onAppear(perform: {
                searchText == "" ? viewModel.getStocks(str: searchText) : viewModel.getSingleStock(str: searchText)
            })
        }

    }
    
}

// MARK: - Subviews
extension SearchVC {
    private var searchBar: some View {
        TextField("Search Symbols", text: $searchText, onCommit: {
            viewModel.getSingleStock(str: searchText)
        })
        .padding()
        .background(Color.secondary.opacity(0.3))
        .cornerRadius(10)
        .padding(.horizontal)
    }

    private var stockTickerList: some View {
        List {
            ForEach(Array(viewModel.stocksArray.enumerated()), id: \.offset) { index, element in
                if let stock = element as? StockTicker {
                    stockTickerRow(stock: stock, index: index)
                }
            }
        }
    }

    private func stockTickerRow(stock: StockTicker, index: Int) -> some View {
        HStack {
            VStack(alignment: .leading) {
                Text(stock.symbol ?? "AAPL")
                Text(stock.name ?? "AAPL")
            }
            Spacer()
            Button(action: {
                selectedSymbol = stock.symbol ?? "AAPL"
                selectedIndex = index
                showPicker = true
            }) {
                Image(systemName: "plus.circle")
                    .foregroundColor(.secondary)
            }
            .sheet(isPresented: $showPicker) {
                
                if #available(iOS 16.0, *) {
                    watchlistPicker
                    .presentationDetents([.medium])
                } else {
                    watchlistPicker
                }
            }
        }
        .padding()
        .onAppear {
            if index == viewModel.stocksArray.count - 1 {
                searchText == "" ? viewModel.getStocks(str: searchText) : viewModel.getSingleStock(str: searchText)
            }
        }
    }
    

    private var watchlistPicker: some View {
        
        NavigationView {
            
            VStack {
                Text("Add to Watchlist")
                    .font(.system(size: 24, weight: .heavy))
                    .foregroundColor(.white)
                    .padding(.top, 15)
                
                List {
                    ForEach(viewModel.watchlists.keys.sorted(), id: \.self) { key in
                        if let name = viewModel.watchlists[key] {
                            Button(action: {
                                selectedWatchlist = key
                                favStocks(symbol: selectedSymbol, index: selectedIndex)
                                showPicker = false
                            }) {
                                Text(name)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                }
                
            }
        }
    }

}

// MARK: - Functions
extension SearchVC {
    
    
    
    private func favStocks(symbol: String, index: Int) {
        removeFromSuperview()
        var watchlistOptions: [String: String] = [:]
        for (id, name) in viewModel.watchlists {
            watchlistOptions[id] = name
        }
        
        var httpMethod: HTTPMethod = .post
        var params = ["watchlist_id": selectedWatchlist, "symbol": symbol] as [String: Any]
        var url = ""

        url = EndPoint.kServerBase + EndPoint.FavouriteAsset
        httpMethod = .post
        print(url)
        print(params)
        NetworkUtil.request(apiMethod: url, parameters: params, requestType: httpMethod, showProgress: true, view: nil, onSuccess: { resp -> Void in
            print(resp!)
//            alertModel.alertToast = AlertToast(type: .complete(.green), title: "Added Successfully", subTitle: nil)
            presentationMode.wrappedValue.dismiss() // Add this line
            alertModel.alertToast = AlertToast(displayMode: .hud, type: .systemImage("checkmark", .green), title: "Added Successfully", subTitle: nil)

            
        }) { error in
//            alertModel.alertToast = AlertToast(type: .complete(.red), title: "Add Failed", subTitle: "Please try again.")
            presentationMode.wrappedValue.dismiss() // Add this line
            alertModel.alertToast = AlertToast(displayMode: .hud, type: .systemImage("x.circle", .red), title: "Failed to Add", subTitle: "Please try again.")

        }
        
    }
    
    
    private func removeFromSuperview() {
        showAlert = false
    }
}

class SearchViewModel: ObservableObject {
    @Published var watchlists: [String: String] = [:]
    @Published var ResponseStatus: ResponseStatus = .idle
    @Published var stocksArray: NSMutableArray = []

    
    init() {
        getfavoritedStocks()
    }
    
    func getStocks(str: String) {
        let url = EndPoint.kServerBase + EndPoint.Assests + "/?q=" + str
        print(url)
        NetworkUtil.request(apiMethod: url, parameters: nil, requestType: .get, showProgress: true, view: nil, onSuccess: { resp -> Void in
            self.stocksArray = []
            print(resp!)
            
            if let jsonObject = resp as? [[String: Any]] {
                print("old", jsonObject)
                self.stocksArray = SwiftParseUtils.parseAssestsData(object: jsonObject)
            } else {
                print("Server Error")
            }
            print(self.stocksArray.count)
        }) { error in
            print(error)
        }
    }
    
    func getSingleStock(str: String) {
        let url = EndPoint.kServerBase + EndPoint.searchAsset + "/?tickers=" + str.uppercased()
        print(url)
        NetworkUtil.request(apiMethod: url, parameters: nil, requestType: .get, onSuccess: { resp -> Void in
            self.stocksArray = []
            print(resp!)
            
            if let jsonObject = resp as? [[String: Any]] {
                print("new", jsonObject)
                self.stocksArray = SwiftParseUtils.parseAssestsData(object: jsonObject)
            } else {
                print("Server Error")
            }
            print(self.stocksArray.count)
        }) { error in
            print(error)
        }
    }

    
    func getfavoritedStocks() {
        let url = EndPoint.kServerBase + EndPoint.allWatchlists
        NetworkUtil.request(apiMethod: url, parameters: nil, requestType: .get, onSuccess: { [weak self] resp -> Void in
            guard let self = self, let watchlistData = resp as? [[String: Any]] else { return }
            var watchlists: [String: String] = [:]
            for watchlist in watchlistData {
                if let watchlistId = watchlist["id"] as? String, let watchlistName = watchlist["name"] as? String {
                    watchlists[watchlistId] = watchlistName
                }
            }
            self.watchlists = watchlists
            if self.watchlists.isEmpty {
                self.ResponseStatus = .noData
            } else {
                self.ResponseStatus = .success
            }
        }) { error in
            self.ResponseStatus = .failure("" as! Error)
            print(error)
        }
    }

}
