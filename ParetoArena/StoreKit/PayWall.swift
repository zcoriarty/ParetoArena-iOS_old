//
//  PayWall.swift
//  TwentyOne
//
//  Created by Zachary Coriarty on 8/19/23.
//

import SwiftUI
import StoreKit

struct PayWall: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var storeVM: StoreVM
    @State var isPurchased = false
    @State private var selectedProductIndex = 1  // keep track of selected product
    
    var body: some View {
        let selectedProduct = storeVM.subscriptions[selectedProductIndex]
        
        ZStack {
            VStack {
                Image("Launch")
                    .resizable()
                    .padding()
                
                Text("TwentyOne Pro")
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .padding()
                    .foregroundColor(Color("Secondary1"))
                
                Text("Unlimited groups, unlimited people, unlimited habits to build!")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .foregroundColor(Color(.gray))
                
                Spacer()
                
                SubscriptionOptions(selectedProductIndex: $selectedProductIndex)
                
                Spacer()
                Text("7-day free trial! Cancel anytime.")
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .foregroundColor(Color(.gray))

                
                Button(action: {
                    // Action for purchasing the selected subscription
                    Task {
                        await buy(product: selectedProduct)
                        self.presentationMode.wrappedValue.dismiss()
                    }
                }) {
                    Text("Continue")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color("Primary1"))
                        .clipShape(Capsule())
                        .foregroundColor(Color("Secondary1"))
                        .shadow(color: Color("Secondary1").opacity(0.15), radius: 4)

                }
                .padding([.horizontal, .bottom])
            }
            .background(Color("Task"))
            
            // Close Button
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        self.presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.gray)
                            .font(.headline) // Adjust the size using font
                            .padding(8)
                            .background(
                                Circle()
                                    .fill(Color.gray.opacity(0.25))
                            )
                    }
                    .padding(.trailing, 16)
                }
                Spacer()
            }
            .padding(.top, 8)
        }
    }

    func buy(product: Product) async {
        do {
            if try await storeVM.purchase(product) != nil {
                isPurchased = true
            }
        } catch {
            print("purchase failed")
        }
    }
}

struct SubscriptionOptions: View {
    @EnvironmentObject var storeVM: StoreVM
    @Binding var selectedProductIndex: Int
    
    var body: some View {
        Group {
            Section(header: Text("")){
                HStack(spacing: 15) {
                    ForEach(Array(storeVM.subscriptions.enumerated()), id: \.offset) { index, product in
                        SubscriptionButton(index: index, isSelected: selectedProductIndex == index, action: {
                            selectedProductIndex = index
                        })
                    }
                }
                .padding(.vertical)
            }
        }
    }
}

struct SubscriptionButton: View {
    var index: Int
    var isSelected: Bool
    var action: () -> Void

    let gradient = LinearGradient(gradient: Gradient(colors: [Color.blue, Color("gradient1"), Color("gradient2")]), startPoint: .topLeading, endPoint: .bottomTrailing)
    let gradientClear = LinearGradient(gradient: Gradient(colors: [Color.clear]), startPoint: .topLeading, endPoint: .bottomTrailing)

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading) {
                HStack(alignment: .top) {
                    Text("Free Trial")
                        .font(.system(size: 15, weight: .semibold))
                        .fontWeight(.bold)
                        .padding(.bottom, 5)
                    
                    Spacer()
                    
                    if index == 1 {
                        Text("38% Off")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(Color.blue)
                    }
                }
                
                Text(priceText)
                    .font(.callout)
                    .fontWeight(.bold)
                    .foregroundColor(Color(.darkGray))

                Text(perDayText)
                    .font(.caption)
                    .foregroundColor(.gray)
                Spacer()
                Text("Unlimited Access")
                    .font(.footnote)
                    .fontWeight(.bold)
                    .foregroundGradient(colors: isSelected ? [Color.blue, Color("gradient1"), Color("gradient2")] : [Color.clear])
            }
            .frame(width: 130, height: 120)
            .padding([.vertical, .trailing])
            .padding(.leading)
            .foregroundColor(Color("Secondary1"))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isSelected ? gradient : gradientClear, lineWidth: 3)
            )
            .background {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color("Primary1"))
                    .shadow(color: Color("Secondary1").opacity(0.15), radius: 4)
            }
        }

    }
    private var priceText: String {
        index == 0 ? "$3.99/Month" : "$29.99/Year"
    }

    private var perDayText: String {
        index == 0 ? "$0.14/Day" : "$0.08/Day"
    }
}

    




//struct PayWall_Previews: PreviewProvider {
//    static var previews: some View {
//        PayWall().environmentObject(StoreVM())
//    }
//}
