//
//  BaseVC.swift
//  Pareto
//
//

import UIKit
import SwiftUI

class BaseVC: UIViewController, UIGestureRecognizerDelegate {
    @IBOutlet var allTextObject: [UITextField] = []
    // MARK: - Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        navigationController?.interactivePopGestureRecognizer?.delegate = self

        for textField in allTextObject {
            textField.textColor = ._appColorSecondary // effects email textfield (maybe others)
        }
    }
    @objc func popViewController() {
        navigationController?.popViewController(animated: true)
    }

    @objc func popToParentViewController() {
        navigationController?.popToRootViewController(animated: true)
    }

    @IBAction func dismissPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}

struct TabBar: View {
    var body: some View {
        TabView {
            // First tab: NewPortfolioView
            WatchlistView()
                .tabItem {
                    Image(systemName: "house.fill")
                }
                .tag(0)
            

            // Third tab: ExploreView
            ExploreVC()
                .tabItem {
                    Image(systemName: "magnifyingglass")
                }
                .tag(2)
            
            // Fifth tab: NewProfileView
            NewProfileVC()
                .tabItem {
                    Image(systemName: "person.fill")
                }
                .tag(3)
        }
    }
}

