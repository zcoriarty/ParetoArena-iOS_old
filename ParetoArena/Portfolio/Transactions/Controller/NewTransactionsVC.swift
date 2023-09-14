//
//  NewTransactionsVC.swift
//  Pareto
//
//  Created by Zachary Coriarty on 5/17/23.
//

import SwiftUI

struct TransactionsView: View {
    @ObservedObject private var transactionViewModel = TransactionViewModel()
    @State private var showAddFundsView = false
    @State private var showDeleteBankView = false
    @State private var showToast = false
    @State private var toastText = ""
    @State private var isTransactionStatusViewPresented = false
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ScrollView(showsIndicators: false){
            NavigationView {
                VStack {
                    HStack {
                        if let name = USER.shared.accountDetail?.nickname,
                           let number = USER.shared.accountDetail?.bank_account_number,
                           number != "" {
                            let codedNum = "****\(String(number.suffix(4)))"
                            Text(codedNum)
                                .font(.headline)
                            Text(name)
                                .font(.title2)
                                .padding(.bottom)
                        }
                        if let balance = UserDefaults.standard.string(forKey: "balance") {
                            
                            VStack {
                                Text("Funds Available")
                                    .font(.headline)
                                    .foregroundColor(Color(.label))
                                Text("$ \(balance) USD")
                                    .font(.headline)
                                    .foregroundColor(Color(.label))
                            }
                        }
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    VStack {
                        ForEach(transactionViewModel.transactions, id: \.id) { transaction in
                            TransactionRow(transaction: transaction)
                                .onTapGesture {
                                    self.isTransactionStatusViewPresented = true
                                }
                                .sheet(isPresented: $isTransactionStatusViewPresented) {
                                    TransactionStatusView(transactionAmount: transaction.amount, time: transaction.created_at.formattedTime, status: transaction.status)
                                        .presentationDetents([.height(250)])
                                }
                            
                        }
                    }
                    .padding(.horizontal)
                    Spacer()
                    .onAppear {
                        transactionViewModel.getTransactions()
                        transactionViewModel.getTotalBalance()
                        transactionViewModel.balance = { amount in
                            UserDefaults.standard.setValue(amount, forKey: "balance")
                        }
                    }
                    .listStyle(GroupedListStyle())
                    .navigationBarTitle("Transactions")
                    .navigationBarItems(trailing:
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
                        .padding(.horizontal))
                    //                .navigationBarItems(leading: Button(action: {
                    ////                    showDeleteBankView.toggle()
                    //                }) {
                    //                    Image(systemName: "trash")
                    //                        .foregroundColor(.red)
                    //                }.disabled(USER.shared.accountDetail?.bank_account_number == nil || USER.shared.accountDetail?.bank_account_number == ""),
                    //                trailing: Button(action: {
                    //                    if USER.shared.accountAdded {
                    //                        showAddFundsView.toggle()
                    //                    } else {
                    //                        // Navigate to PlaidIntroVC
                    //                    }
                    //                }) {
                    //                    Image(systemName: "plus")
                    //                        .foregroundColor(.green)
                    //                })
                    //            }
                    //            .sheet(isPresented: $showAddFundsView) {
                    //                // AddFundView()
                    //            }
                    //            .fullScreenCover(isPresented: $showDeleteBankView) {
                    //                // DeleteBankView(removed: {
                    //                //     showToast.toggle()
                    //                //     toastText = "Account has been removed successfully!"
                    //                // })
                    //            }
                    
                }
            }
        }
    }
}


struct TransactionRow: View {
    let transaction: Transaction
    
    var body: some View {
            HStack {
                VStack(alignment: .leading) {
                    Text(convertDateFormater(transaction.created_at))
                        .font(.headline)
                    Text(transaction.subTitle)
                        .font(.subheadline)
                        .foregroundColor(transaction.status == "CANCELED" ? .red : Color(red: 208 / 255, green: 210 / 255, blue: 211 / 255))
                }
                .padding()
                
                Spacer()
                
                Text(transaction.amountStr)
                    .font(.headline)
                    .padding(.trailing)
            }
            .background(Color.secondary.opacity(0.15))
            .cornerRadius(6)

        
    }
    
    func convertDateFormater(_ date: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let date = dateFormatter.date(from: date)
        dateFormatter.dateFormat = "MM/dd/yyyy"
        return dateFormatter.string(from: date!)
    }
}

