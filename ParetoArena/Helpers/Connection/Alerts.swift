//
//  Alerts.swift
//  ParetoArena
//
//  Created by Zachary Coriarty on 9/15/23.
//

import SwiftUI
import AlertToast

class AlertViewModel: ObservableObject{
    
    @Published var show = false
    @Published var alertToast = AlertToast(displayMode: .hud, type: .regular, title: "SOME TITLE"){
        didSet{
            show.toggle()
        }
    }

}
