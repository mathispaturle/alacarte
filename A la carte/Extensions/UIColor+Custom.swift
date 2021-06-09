//
//  UIColor+Custom.swift
//  traveers
//
//  Created by Sopra on 01/12/2020.
//

import Foundation
import UIKit

extension UIColor {

    private enum Constants {
        static let maxValue: CGFloat = 255.0
    }
    /// color components value between 0 to 255
    public convenience init(r: Int, g: Int, b: Int, alpha: CGFloat = 1.0) {
        self.init(red: CGFloat(r) / Constants.maxValue, green: CGFloat(g) / Constants.maxValue, blue: CGFloat(b) / Constants.maxValue, alpha: alpha)
    }
    
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")

        self.init(red: CGFloat(red) / Constants.maxValue, green: CGFloat(green) / Constants.maxValue, blue: CGFloat(blue) / Constants.maxValue, alpha: 1.0)
    }

    convenience init(rgb: Int) {
        self.init(red: (rgb >> 16) & 0xFF, green: (rgb >> 8) & 0xFF, blue: rgb & 0xFF)
    }

//    static let primary: UIColor = UIColor(rgb: 0x5685EF)
    static let primary: UIColor = UIColor(rgb: 0x01D895)
    static let secondary: UIColor = UIColor(rgb: 0x4670D3)
    static let tertiary: UIColor = UIColor(rgb: 0x3555A0)
    static let detail: UIColor = UIColor(rgb: 0xFF6978)
    static let dark: UIColor = UIColor(rgb: 0x323C58)
    static let light: UIColor = UIColor(rgb: 0xC4D0DC)
    static let lightWithAlpha: UIColor = UIColor(r: 170, g: 170, b: 170, alpha: CGFloat(0.5))
    static let lighter: UIColor = UIColor(rgb: 0xF3F4F6)
    static let lightest: UIColor = UIColor(rgb: 0xFFFCF9)
    static let darker: UIColor = UIColor(rgb: 0x333333)
    static let main: UIColor = UIColor(rgb: 0x333333)
    static let secondMain: UIColor = UIColor(rgb: 0x888888)

}
