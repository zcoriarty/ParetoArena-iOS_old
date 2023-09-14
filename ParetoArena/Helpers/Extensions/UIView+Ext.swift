//
//  UIView+Ext.swift
//  Pareto
//
//

import UIKit

extension UIView {
    @IBInspectable var cornerRadiusV: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    @IBInspectable var borderWidthV: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    @IBInspectable var borderColorV: UIColor? {
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
    class func fromNib<T: UIView>() -> T {
        return Bundle.main.loadNibNamed(String(describing: T.self), owner: nil, options: nil)! [0] as! T
    }
    func snapshot() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, UIScreen.main.scale)
        drawHierarchy(in: bounds, afterScreenUpdates: true)
        let result = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
        UIGraphicsEndImageContext()
        return result
    }
}
extension UIView {
   func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
    
    var thumbViewSnapshot: UIImage {
            let renderer = UIGraphicsImageRenderer(bounds: bounds)
            let capturedImage = renderer.image { context in
                layer.render(in: context.cgContext)
            }
            return capturedImage
        }

}
func currentController() -> UIViewController? {
    let keyWindow = UIApplication.shared.windows.filter { $0.isKeyWindow }.first

    if var topController = keyWindow?.rootViewController {
        while let presentedViewController = topController.presentedViewController {
            topController = presentedViewController
        }
     return topController
    }
    return nil
}
extension UIButton {
    func setBackground(enable: Bool? = false) {
        backgroundColor = enable! ?  #colorLiteral(red: 0.2509999871, green: 0.5960000157, blue: 1, alpha: 1): ._appColorSecondary
        isUserInteractionEnabled = enable!
    }
}


extension UIView {
    
    func setUp(to superView: UIView) {
        translatesAutoresizingMaskIntoConstraints = false
        topAnchor.constraint(equalTo: superView.topAnchor).isActive = true
        leadingAnchor.constraint(equalTo: superView.leadingAnchor).isActive = true
        bottomAnchor.constraint(equalTo: superView.bottomAnchor).isActive = true
        trailingAnchor.constraint(equalTo: superView.trailingAnchor).isActive = true
    }
    
    func setGradient(withColors colors: [CGColor] , startPoint: CGPoint , endPoint: CGPoint) {
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.colors = colors
        gradient.startPoint = startPoint
        gradient.endPoint = endPoint
        gradient.frame = CGRect(x: 0.0, y: 0.0, width: self.frame.size.width, height: self.frame.size.height)
        self.layer.insertSublayer(gradient, at: 0)
    }
}



struct windowConstant {
    
    private static let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
    
    static var getTopPadding: CGFloat {
        return window?.safeAreaInsets.top ?? 0
    }
    
    static var getBottomPadding: CGFloat {
        return window?.safeAreaInsets.bottom ?? 0
    }
    
}
