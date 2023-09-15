//
//  NewBuySellVC.swift
//  Pareto
//
//  Created by Zachary Coriarty on 4/22/23.
//

import SwiftUI
import Combine

struct BuyView: View {
    let company: NewCurrentStock?
    @State var isBuyMode: Bool
    @Environment(\.presentationMode) var presentationMode
    
    
    @State private var isMarketOrder: Bool = true
    
    @State private var showToast: Bool = false
    @State private var toastMessage: String = ""
    
    @State private var quantity: Double = 1
    @State private var quantityText: String = ""
    @State private var totalCost: String = ""
    @State private var isEditingQuantity: Bool = false
    @State private var isEditingTotalCost: Bool = false
    
    private func dismiss() {
        presentationMode.wrappedValue.dismiss()
    }

    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                stockInfoSection
                
                priceAndQuantitySection
                Spacer()
                Text("*This is a market order. It will execute at the best current price.")
                    .font(.system(size: 12, weight: .light))
                    .foregroundColor(Color(.lightGray))
                buyOrSellButton
            }
            .padding()
            .background(Color.clear) // The color doesn't matter
            .contentShape(Rectangle()) // This makes the whole area tappable
            .onTapGesture {
                UIApplication.shared.endEditing(true)
            }
            .navigationBarItems(
                leading: Text("Market Order").foregroundColor(Color.gray),
                trailing: Button(action: dismiss) {
                    Image(systemName: "xmark")
                        .foregroundColor(Color.primary.opacity(0.6))
                        .padding(10)
                        .background(Color.primary.opacity(0.1))
                        .clipShape(Circle())
                }
            )
        }
    }
}

// MARK: - Subviews

private extension BuyView {
    var stockInfoSection: some View {
        HStack {
            VStack(alignment: .leading) {

                Text(company?.symbol ?? "AAPL")
                    .font(.title3)
                    .bold()
                Text("$\(company?.ticker?.dailyBar?.c ?? 123.0)")
                    .font(.title)
                    .bold()
            }
            Spacer()
            Button(action: { isBuyMode.toggle() }) {
                Text(isBuyMode ? "Buy" : "Sell")
                    .padding(.horizontal)
                    
            }
            .padding()
            .background(isBuyMode ? Color.green : Color.red)
            .cornerRadius(10)
        }
    }
    
    var priceAndQuantitySection: some View {
        VStack {
            HStack {
                Text("Quantity")
                    .font(.system(size: 20, weight: .light))
                Spacer()
                TextField("Quantity", text: $quantityText, onEditingChanged: { editing in
                    isEditingQuantity = editing
                    if !editing {
                        updateQuantity()
                    }
                })
                .accentColor(.primary)
                .font(.system(size: 18, weight: .light))
                .multilineTextAlignment(.trailing)
                .keyboardType(.decimalPad)
                .padding()
                .cornerRadius(8)
                .onChange(of: quantityText, perform: { _ in
                    if !isEditingTotalCost {
                        updateQuantity()
                    }
                })
            }
            HStack {
                Text("Total Cost")
                    .font(.system(size: 20, weight: .light))
                Spacer()
                TextField("Total Cost", text: $totalCost, onEditingChanged: { editing in
                    isEditingTotalCost = editing
                    if !editing {
                        updateTotalCost()
                    }
                })
                .accentColor(.primary)
                .multilineTextAlignment(.trailing)
                .font(.system(size: 18, weight: .light))
                .keyboardType(.decimalPad)
                .padding()
                .cornerRadius(8)
                .onChange(of: totalCost, perform: { _ in
                    if !isEditingQuantity {
                        updateTotalCost()
                    }
                })
            }
        }
    }

    var buyOrSellButton: some View {
        Button(action: buyShare) {
            let title = String(format: "%@ %@", isBuyMode ? "Buy" : "Sell", company?.symbol ?? "")
            Text(title)
                .frame(maxWidth: .infinity)
                .padding()
                .background(isBuyMode ? Color.green : Color.red)
                .foregroundColor(.white)
                .cornerRadius(8)
        }
    }
    
    func buyShare() {
        let side = isBuyMode ? "buy" : "sell"
        callApi(side: side)
    }
}

// MARK: - Functions

private extension BuyView {


    
    func updateQuantity() {
        guard let stockPrice = company?.ticker?.dailyBar?.c else { return }
        if let quantityValue = Double(quantityText) {
            quantity = quantityValue
            let newTotalCost = quantity * stockPrice
            totalCost = String(format: "%.2f", newTotalCost)
        } else {
            quantity = 0
            totalCost = "0"
        }
    }

    func updateTotalCost() {
        guard let stockPrice = company?.ticker?.dailyBar?.c else { return }
        if let totalCostValue = Double(totalCost) {
            quantity = totalCostValue / stockPrice
            quantityText = String(format: "%.2f", quantity)
        } else {
            quantity = 0
            quantityText = "0"
        }
    }


    func callApi(side: String) {
            let url = EndPoint.kServerBase + EndPoint.Order
        let params = ["symbol": company?.symbol! as Any, "notional": totalCost, "side": side, "type": "market", "time_in_force": "day"] as [String: Any]
            print(url)
            print(params)
            
            NetworkUtil.request(apiMethod: url, parameters: params, requestType: .post, showProgress: true, view: nil, onSuccess: { resp -> Void in
                print(resp!)
                if let dict = resp as? [String: Any], let msg = dict["message"] as? String {
                    print("Order message: ", msg)
                } else {
                    // You may need to handle the navigation differently depending on your app structure
                    // self.navigationController?.popToRootViewController(animated: true)
                }
            }, onFailure: { error in
                print("error calling order api")
            })
        }
}

// for dismissing the number pad
extension UIApplication {
    func endEditing(_ force: Bool) {
        self.windows
            .filter{$0.isKeyWindow}
            .first?
            .endEditing(force)
    }
}





