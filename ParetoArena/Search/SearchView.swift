//
//  SearchView.swift
//  Pareto
//
//  Created by Zachary Coriarty on 1/7/23.
//

import SwiftUI

struct SearchView: View {
    
    @State private var searchTerm: String = ""
    @State private var showAlgorithmDetail = false
    @State private var selectedAlgorithm: Algorithm? = nil
    
    var body: some View {
        
        NavigationView {
            VStack(alignment: .leading) {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                        .scaleEffect(0.8)
                    
                    TextField("Search Pareto", text: $searchTerm, onEditingChanged: { changed in
                        if !changed {
                            // Perform search with searchTerm
                            print($searchTerm)
                        }
                    })
                }
                .padding(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .padding([.horizontal, .vertical])
                
                
                
                
                ScrollView(.vertical, showsIndicators: false) {
                    ForEach(algorithmCategories, id: \.self) { category in
                        VStack(alignment: .leading) {
                            Text(category)
                                .font(
                                    .system(size: 20)
                                    .weight(.heavy)
                                )
                                .padding(.leading)
                                .foregroundColor(.white)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    ForEach(algorithmsForCategory(category), id: \.id) { algorithm in
                                        Button(action: {
                                            self.selectedAlgorithm = algorithm
                                            self.showAlgorithmDetail = true
                                        }) {
                                            AlgorithmCard(algorithm: algorithm)
                                                .padding(.horizontal)
                                                .cornerRadius(12)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                }
            }
            .background(Color(red: 0.051, green: 0.098, blue: 0.176).edgesIgnoringSafeArea(.all))
            
            .sheet(isPresented: $showAlgorithmDetail) {
                if let algorithm = self.selectedAlgorithm {
                    AlgorithmDetailView(algorithm: algorithm)
                }
            }.navigationBarTitle("Explore").foregroundColor(.white)

        }
    }
}

struct AlgorithmCard: View {
    let algorithm: Algorithm
    @State private var showRiskScore = false
    @State private var showCurrentProfitRank = false
    @State private var showRecentReturns = false
    
    let customDarkGray = Color(red: 0.25, green: 0.25, blue: 0.25)

    var body: some View {
        VStack {
            HStack {
                Text(algorithm.name)
                    .font(.headline)
                    .padding(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                Spacer()
            }
            .padding(.top)

//            LineGraph(data: algorithm.recentReturns)
//                .frame(height: 30)
//                .padding(.horizontal)

            HStack {
                HStack {
                    Button(action: {
                        self.showRiskScore.toggle()
                    }) {
                        Image(systemName: "exclamationmark.triangle.fill")
//                            .foregroundColor(.yellow)
                        
                        Text(self.algorithm.riskScore)
                            .font(.caption)
//                            .frame(width: 100, height: 50)
                    }
                    .font(.caption)
                    .padding(.leading)
                    .fixedSize(horizontal: true, vertical: false)
                    .foregroundColor(customDarkGray)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .padding(.vertical)
                .sheet(isPresented: $showRiskScore, onDismiss: {
                    self.showRiskScore = false
                }, content: {
                    VStack {
                        Text("Risk Score")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                        Text("A risk score is a numerical representation of the risk associated with a particular algorithm or investment. It is typically calculated based on factors such as historical performance, volatility, and market conditions. A higher risk score indicates that the algorithm or investment carries a higher level of risk, while a lower risk score indicates a lower level of risk.For example, an algorithm that has a high risk score may have a track record of volatile returns and may be more susceptible to market fluctuations. On the other hand, an algorithm with a low risk score may have a more stable track record and may be less affected by market conditions.It is important to consider risk scores when making investment decisions, as they can help you understand the level of risk you are taking on and make more informed decisions about your portfolio.")
                            .font(.system(size: 15))
                            .fontWeight(.light)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(red: 0.051, green: 0.098, blue: 0.176).edgesIgnoringSafeArea(.all))
                    .cornerRadius(8)

                })

                
                
                    HStack {
                        Button(action: {
                            self.showCurrentProfitRank.toggle()
                        }) {
                            Image(systemName: "chart.bar.fill")
                            
                            Text(self.algorithm.currentProfitRank)
                                .font(.caption)
                        }
                        .font(.caption)
                        .foregroundColor(customDarkGray)
                        .fixedSize(horizontal: true, vertical: false)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .padding(.vertical)
                    .sheet(isPresented: $showCurrentProfitRank, onDismiss: {
                        self.showCurrentProfitRank = false
                        
                    }, content: {
                        VStack {
                            Text("Current Profit Rank")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()
                            Text("The current profit rank is a measure of how profitable a particular algorithm is relative to other algorithms in its category. A higher current profit rank indicates that the algorithm has generated higher returns compared to other algorithms in the same category.For example, if an algorithm has a current profit rank of 1, it means that it is the most profitable algorithm in its category based on recent returns. On the other hand, if the current profit rank is lower, it means that the algorithm has generated lower returns compared to other algorithms in the same category. It is important to consider current profit rank when evaluating algorithms, as it can help you understand the relative performance of different algorithms and make more informed investment decisions.")
                                .font(.system(size: 15))
                                .fontWeight(.light)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color(red: 0.051, green: 0.098, blue: 0.176).edgesIgnoringSafeArea(.all))
                        .cornerRadius(8)
                    })
                
                

                HStack {
                    Button(action: {
                        self.showRecentReturns.toggle()
                    }) {
                        Image(systemName: "arrow.up.right.diamond.fill")
//                            .foregroundColor(.yellow)
                        
                        Text(self.algorithm.id) // TODO: add recent returns
                            .font(.caption)
//                            .frame(width: 100, height: 50)
                    }
                    .font(.caption)
                    .foregroundColor(customDarkGray)
                    .fixedSize(horizontal: true, vertical: false)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                }
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .padding(.vertical)
                .sheet(isPresented: $showRecentReturns, onDismiss: {
                    self.showRecentReturns = false
                }, content: {
                    VStack {
                        Text("Recent Returns")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                        Text("Recent returns refer to the performance of an algorithm or investment over a recent time period, typically measured in weeks or months. They can be used to evaluate the short-term performance of an algorithm and identify trends in its returns. For example, if an algorithm has consistently high recent returns, it may be a good investment opportunity. On the other hand, if the recent returns are consistently low, it may be a less attractive investment. It is important to consider recent returns when evaluating algorithms, as they can provide insight into the short-term performance of an algorithm and help you make more informed investment decisions.")
                            .font(.system(size: 15))
                            .fontWeight(.light)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(red: 0.051, green: 0.098, blue: 0.176).edgesIgnoringSafeArea(.all))
                    .cornerRadius(8)
                })
                

                Spacer()

            }
            .padding([.trailing])
        }
        .background(Color(.secondaryLabel))
        .cornerRadius(8)
        .padding(.vertical)
    }
}



struct AlgorithmDetailView: View {
    let algorithm: Algorithm

    var body: some View {
        VStack(alignment: .leading) {
            Text(algorithm.name)
                .font(.largeTitle)
                .padding()


            Text("Risk Score: \(algorithm.riskScore)")
                .font(.headline)
                .padding(.leading)

            Text("Current Profit Rank: \(algorithm.currentProfitRank)")
                .font(.headline)
                .padding(.leading)

            Text("Recent Returns: \(algorithm.recentReturns.map { String($0) }.joined(separator: ", "))")
                .font(.headline)
                .padding(.leading)
        }
        .background(Color(red: 0.25, green: 0.25, blue: 0.25))
    }
}



struct Algorithm {
    let id: String
    let name: String
    let riskScore: String
    let currentProfitRank: String
    let recentReturns: [Double]
}

let algorithmCategories = ["Arbitrage", "Trend Following", "Mean Reversion", "Sentiment Analysis", "Fundamental Analysis"]


func algorithmsForCategory(_ category: String) -> [Algorithm] {
    switch category {
            case "Arbitrage":
                return [
                    Algorithm(id: "1", name: "Spatial", riskScore: "Low", currentProfitRank: "10", recentReturns: [1.0, 8.0, 3.0, 4.0, -50.0]),
                    Algorithm(id: "2", name: "Temporal", riskScore: "High", currentProfitRank: "2", recentReturns: [3, 4, 5, 6, 7])]
            case "Trend Following":
                return [
                    Algorithm(id: "3", name: "Moving Average", riskScore: "Medium", currentProfitRank: "9", recentReturns: [5, 6, 7, 8, 9]),
                    Algorithm(id: "4", name: "Relative Strength Index", riskScore: "Low", currentProfitRank: "1", recentReturns: [2, 3, 4, 5, 6])]
            case "Mean Reversion":
                return [
                    Algorithm(id: "5", name: "Bollinger Bands", riskScore: "Medium", currentProfitRank: "50", recentReturns: [4, 5, 6, 7, 8]),
                    Algorithm(id: "6", name: "Z-Score", riskScore: "High", currentProfitRank: "6", recentReturns: [6, 7, 8, 9, 10])]
            case "Sentiment Analysis":
                return [
                    Algorithm(id: "7", name: "Natural Language Processing", riskScore: "High", currentProfitRank: "3", recentReturns: [3, 4, 5, 6, 7]),
                    Algorithm(id: "8", name: "Machine Learning", riskScore: "Low", currentProfitRank: "8", recentReturns: [5, 6, 7, 8, 9])]
            case "Fundamental Analysis":
                return [
                    Algorithm(id: "9", name: "Financial Statement Analysis", riskScore: "Extremely High", currentProfitRank: "9", recentReturns: [7, 8, 9, 10, 11]),
                    Algorithm(id: "10", name: "Discounted Cash Flow", riskScore: "Low", currentProfitRank: "4", recentReturns: [1, 2, 3, 4, 5])]
            default:
                return []
        }

}


struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
    }
}


