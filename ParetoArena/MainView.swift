//
//  MainView.swift
//  ParetoArena
//
//  Created by Zachary Coriarty on 9/13/23.
//

import SwiftUI
import CoreData

struct MainView: View {


    var body: some View {
        TabView {
            WatchlistView()
                .tabItem {
                    Image(systemName: "house.fill")
                }
            

//            PostsView(managedObjectContext: self.ctx)
//                .tabItem {
//                    Image(systemName: "person.3.fill")
//                }

//            ProfileView(ctx: self.ctx)
//                .tabItem {
//                    Image(systemName: "person.crop.circle.fill")
//                }
            }
            .tint(Color("Secondary1"))

    }
}
