//
//  FundsAddedVC.swift
//  Pareto
//
//

import UIKit

import SwiftUI

struct TransactionStatusView: View {
    @State private var progress: CGFloat = 0.0
    
    let transactionAmount: String
    let time: String
    let status: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Transaction Amount: \(transactionAmount)")
                .font(.headline)
            
            Text("Time: \(time)")
                .font(.subheadline)
            
            HStack {
                Text("Status: \(status)")
                    .font(.subheadline)
                
                Spacer()
                
                if status == "COMPLETE" {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                } else if status == "CANCELED" {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.red)
                }
            }
            
            ProgressView(value: progress)
                .progressViewStyle(CustomProgressViewStyle(color: status == "COMPLETE" ? .green : .red))
                .onAppear {
                    if status == "COMPLETE" {
                        progress = 1.0
                    } else if status == "CANCELED" {
                        progress = 0.5
                    }
                }
            
            HStack {
                Text("Initiated")
                    .font(.caption)
                
                Spacer()
                
                Text("Completed")
                    .font(.caption)
                    .opacity(status == "COMPLETE" ? 1.0 : 0.5)
                
                Spacer()
                
                Text("Cancelled")
                    .font(.caption)
                    .opacity(status == "CANCELED" ? 1.0 : 0.5)
            }
        }
        .padding()
    }
}

struct CustomProgressViewStyle: ProgressViewStyle {
    var color: Color

    func makeBody(configuration: Configuration) -> some View {
        ProgressView(configuration)
            .accentColor(color)
    }
}





