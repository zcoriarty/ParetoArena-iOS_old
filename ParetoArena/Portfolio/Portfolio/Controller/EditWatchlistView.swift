//
//  EditWatchlistView.swift
//  Pareto
//
//  Created by Zachary Coriarty on 4/29/23.
//

import SwiftUI
import AlertToast

struct EditWatchlistView: View {
    let viewModel: WatchlistViewModel
    let watchlistName: String
    @ObservedObject var alertModel: AlertViewModel
    @Environment(\.presentationMode) var presentationMode
//    let onRemove: ([String], String) -> Void

    @State private var selectedAssets: Set<String> = []

    var body: some View {
        VStack(alignment: .leading) {
            titleLabel
            Spacer()
            assetsList
            removeButton
        }
        .padding()
        .background(Color(.systemBackground))
        .navigationBarTitle(Text("Edit (\(watchlistName))"), displayMode: .inline)
        .edgesIgnoringSafeArea(.bottom)
    }

    private var titleLabel: some View {
        Text("Select to Delete")
            .font(.system(size: 30, weight: .bold))
            .foregroundColor(.white)
            .padding(.top, 20)
    }

    private var removeButton: some View {
        Button(action: deleteButtonTapped) {
            Text("Remove")
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.tertiaryLabel))
                .cornerRadius(20)
                .foregroundColor(.white)
        }
        .padding(.bottom)
        .disabled(selectedAssets.isEmpty)
    }

    private var assetsList: some View {
        List {
            ForEach(viewModel.watching[watchlistName]!) { asset in
                assetRow(asset: asset)
            }
            .onDelete(perform: deleteAssets)
        }
        .listStyle(PlainListStyle())
    }

    private func deleteAssets(at offsets: IndexSet) {
        let assetIdsToRemove = offsets.map { viewModel.watching[watchlistName]![$0].id! }
        viewModel.watching[watchlistName]!.removeAll { asset in
            assetIdsToRemove.contains(asset.id!)
        }
    }

    private func assetRow(asset: NewCurrentStock) -> some View {
        HStack {
            Text("\(asset.symbol!) (\(asset.name!))")
            Spacer()
            if selectedAssets.contains(asset.id!) {
                Image(systemName: "checkmark")
                    .foregroundColor(.red)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            toggleSelection(of: asset)
        }
    }

    private func toggleSelection(of asset: NewCurrentStock) {
        if let assetID = asset.id, selectedAssets.contains(assetID) {
            selectedAssets.remove(assetID)
        } else if let assetID = asset.id {
            selectedAssets.insert(assetID)
        }
    }

    private func deleteButtonTapped() {
        let assetsToRemove = viewModel.watching[watchlistName]!.filter { selectedAssets.contains($0.id!) }
        let symbolsToRemove = assetsToRemove.map { $0.symbol! }
        removeAssetsFromWatchlist(symbols: symbolsToRemove, watchlistName: watchlistName)

        let indicesToRemove = IndexSet(viewModel.watching[watchlistName]!.indices.filter { selectedAssets.contains(viewModel.watching[watchlistName]![$0].id!) })
        deleteAssets(at: indicesToRemove)

        selectedAssets.removeAll()
    }

    func removeAssetsFromWatchlist(symbols: [String], watchlistName: String) {
        guard let watchlistId = self.viewModel.watchlistDict[watchlistName] else {
            print("not a good name")
            return
        }
        for symbol in symbols {
            removeAssetFromWatchlist(symbol: symbol, watchlistId: watchlistId, at: IndexPath(), completion: { success in
                if success {
                    print("Successfully removed asset \(symbol) from watchlist \(watchlistName)")
                } else {
                    print("Failed to remove asset \(symbol) from watchlist \(watchlistName)")
                }
            })
        }
    }

    
    func removeAssetFromWatchlist(symbol: String, watchlistId: String, at indexPath: IndexPath, completion: @escaping (Bool) -> Void) {
        var url = EndPoint.kServerBase + EndPoint.unFavoutite
        url = url.replacingOccurrences(of: "{symbol}", with: symbol)
        url = url.replacingOccurrences(of: "{watchlist_id}", with: watchlistId)

        print(url)
        NetworkUtil.request(apiMethod: url, parameters: nil, requestType: .delete, onSuccess: { resp -> Void in
            print(resp!)
            presentationMode.wrappedValue.dismiss()
            alertModel.alertToast = AlertToast(displayMode: .hud, type: .systemImage("checkmark", .green), title: "Deleted Successfully", subTitle: nil)
            
            completion(true)
        }) { error in
            print(error)
            presentationMode.wrappedValue.dismiss()
            alertModel.alertToast = AlertToast(displayMode: .hud, type: .systemImage("x.circle", .red), title: "Failed to Delete", subTitle: "Please try again.")
            completion(false)
        }
    }



}



