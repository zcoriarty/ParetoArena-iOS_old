//
//  UINavigationItem+Ext.swift
//  Pareto
//
//

import UIKit
extension UINavigationItem {
    func setTitle(_ title: String, subtitle: String) {
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont(name: "Neue-Medium", size: 15)
        titleLabel.textColor = ._92ACB5

        let subtitleLabel = UILabel()
        subtitleLabel.text = subtitle
        subtitleLabel.font = UIFont(name: "Neue-Regular", size: 11)
        subtitleLabel.textColor = ._92ACB5

        let stackView = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        stackView.distribution = .equalCentering
        stackView.alignment = .center
        stackView.axis = .vertical

        self.titleView = stackView
    }
}
extension UINavigationController {
    func removeViewController(_ controller: UIViewController.Type) {
        if let viewController = viewControllers.first(where: { $0.isKind(of: controller.self) }) {
            viewController.removeFromParent()
        }
    }
}
