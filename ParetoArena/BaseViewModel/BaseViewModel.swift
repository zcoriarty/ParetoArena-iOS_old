//
//  BaseViewModel.swift
//  Pareto
//
//  
//

import SwiftUI

class BaseViewModel: NSObject, NetworkProxyDelegate, ObservableObject {
    @Published var isLoading: Bool = false
    @Published var alertMessage: String? = nil  // For showing an alert
    var bindViewModelToController: (() -> Void) = {}
    var bindErrorViewModelToController: ((String) -> Void) = { _ in }
    var proxy: NetworkProxy!

    func requestDidBegin() {
        if (NetworkState().isInternetAvailable) == false {
            NetworkState.showNetworkErrorView()
            return
        }
        isLoading = true  // Using SwiftUI's native loader
    }
    
    func requestDidFinishedWithData(data: Any, reqType: RequestType) {
        isLoading = false  // Using SwiftUI's native loader
    }
    
    func requestDidFailedWithError(error: String, reqType: RequestType) {
        isLoading = false  // Using SwiftUI's native loader
        alertMessage = error  // Trigger the alert
    }
}

// usage
//struct YourView: View {
//    @ObservedObject var viewModel: BaseViewModel
//
//    var body: some View {
//        ZStack {
//            // Your regular UI code here
//            // ...
//
//            if viewModel.isLoading {
//                ProgressView()
//                    .progressViewStyle(CircularProgressViewStyle(tint: .blue))
//                    .scaleEffect(2, anchor: .center)
//                    .frame(width: 100, height: 100)
//            }
//        }
//        .alert(item: $viewModel.alertMessage) { message in
//            Alert(
//                title: Text("Error"),
//                message: Text(message),
//                dismissButton: .default(Text("OK"))
//            )
//        }
//    }
//}

