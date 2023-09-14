//
//  UIColor+Ext.swift
//  Pareto
//
//

import UIKit

extension UIColor {
    static let _5E6F75 = UIColor(named: "5E6F75") ?? #colorLiteral(red: 0.368627451, green: 0.4352941176, blue: 0.4588235294, alpha: 1)

    static let _6F7A89 = UIColor(named: "6F7A89") ?? #colorLiteral(red: 0.4352941176, green: 0.4784313725, blue: 0.537254902, alpha: 1)

    static let _92ACB5_6 = UIColor(named: "92ACB5_6%") ?? #colorLiteral(red: 0.5725490196, green: 0.6745098039, blue: 0.7098039216, alpha: 0.05652421358)

    static let _92ACB5 = UIColor(named: "92ACB5") ?? #colorLiteral(red: 0.5725490196, green: 0.6745098039, blue: 0.7098039216, alpha: 1)

    static let _665BA7 = UIColor(named: "665BA7") ?? #colorLiteral(red: 0.4, green: 0.3568627451, blue: 0.6549019608, alpha: 1)

    static let _appColorDarkBlue_25 = UIColor(named: "appColorDarkBlue_25%") ?? #colorLiteral(red: 0.4431372549, green: 0.6470588235, blue: 1, alpha: 0.2480339404)

    static let _appColorDarkBlue = UIColor(named: "appColorDarkBlue") ?? #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 1)

    static let _161926 = UIColor(named: "161926") ?? #colorLiteral(red: 0.0862745098, green: 0.09803921569, blue: 0.1490196078, alpha: 1)

    static let _242234 = UIColor(named: "242234") ?? #colorLiteral(red: 0.1411764706, green: 0.1333333333, blue: 0.2039215686, alpha: 1)

    static let _D170FF = UIColor(named: "D170FF") ?? #colorLiteral(red: 0.8196078431, green: 0.4392156863, blue: 1, alpha: 1)

    static let _FFE68B = UIColor(named: "FFE68B") ?? #colorLiteral(red: 1, green: 0.9019607843, blue: 0.5450980392, alpha: 1)

    static let _7A5F4B = UIColor(named: "7A5F4B") ?? #colorLiteral(red: 0.4784313725, green: 0.3725490196, blue: 0.2941176471, alpha: 1)

    static let _4098FF = UIColor(named: "4098FF") ?? #colorLiteral(red: 0.2509803922, green: 0.5960784314, blue: 1, alpha: 1)

    static let _357ED4 = UIColor(named: "357ED4") ?? #colorLiteral(red: 0.2078431373, green: 0.4941176471, blue: 0.831372549, alpha: 1)
    static let _B8B7FF = UIColor(named: "B8B7FF") ?? #colorLiteral(red: 0.7215686275, green: 0.7176470588, blue: 1, alpha: 1)
    static let _230B34F = UIColor(named: "230B34") ?? #colorLiteral(red: 0.137254902, green: 0.0431372549, blue: 0.2039215686, alpha: 1)
    static let _854537 = UIColor(named: "854537") ?? #colorLiteral(red: 0.5215686275, green: 0.2705882353, blue: 0.2156862745, alpha: 1)
    static let FF927A = UIColor(named: "FF927A") ?? #colorLiteral(red: 1, green: 0.5725490196, blue: 0.4784313725, alpha: 1)
    static let _717171 = UIColor(named: "717171") ?? #colorLiteral(red: 0.7884889245, green: 0.7884889245, blue: 0.7884889245, alpha: 1)
    
    
    // Pareto main colors
    static let _C3CEDA = UIColor(named: "C3CEDA") ?? #colorLiteral(red: 0.7647058824, green: 0.8078431373, blue: 0.8549019608, alpha: 1)
    static let _145DAO = UIColor(named: "145DAO") ?? #colorLiteral(red: 0.07843137255, green: 0.3647058824, blue: 0.6274509804, alpha: 1)
    static let _OC2D48 = UIColor(named: "OC2D48") ?? #colorLiteral(red: 0.04705882353, green: 0.1764705882, blue: 0.2823529412, alpha: 1)
    static let _F9FBFC = UIColor(named: "F9FBFC") ?? #colorLiteral(red: 0.9764705882, green: 0.9843137255, blue: 0.9882352941, alpha: 1)
    
    static let _appColorSecondary = UIColor(named: "appColorSecondary") ?? #colorLiteral(red: 0.03099999949, green: 0.175999999, blue: 0.3409999907, alpha: 1)
    
    static let _transparent = UIColor(displayP3Red: 0, green: 0, blue: 0, alpha: 0.5)

}
// XCode has bug & return nil for named color assign them colors littersl as optionals


extension UIColor {
    static var systemBackgroundColor: UIColor {
        return UIColor { (traits) -> UIColor in
            return traits.userInterfaceStyle == .dark ? UIColor.black : UIColor.white
        }
    }
}

