//
//  ContentView.swift
//  ParetoArena
//
//  Created by Zachary Coriarty on 9/13/23.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("log_status") var logStatus: Bool = false
    @Environment(\.managedObjectContext) var managedObjectContext

    var body: some View {
        // MARK: Redirecting User Based on Log Status
        if logStatus{
            MainView()
        }else{
            RegisterView()
        }
    }
}

//class DeepLinkHandler: ObservableObject {
//    @Published var habitGroup: HabitGroup?
//    @Published var user: User?
//}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
