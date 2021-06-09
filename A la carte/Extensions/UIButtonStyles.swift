//
//  UIButtonStyles.swift
//  A la carte
//
//  Created by Sopra on 24/02/2021.
//

import Foundation
import UIKit

public struct UIButtonStyles {
    
    public static let defaultStyle = Style<UIButton> { _ in
        //Default case, it won't be used
    }

    public static let saveButton = Style<UIButton> {
        $0.setTitleColor(.primary, for: .normal)
        $0.titleLabel?.font = .robotoBold16
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.primary.cgColor;
        $0.layer.cornerRadius = 25.0
    }

    public static let boldButton = Style<UIButton> {
        $0.setTitleColor(.primary, for: .normal)
        $0.titleLabel?.font = .robotoBold16
    }

    public static let regularButton = Style<UIButton> {
        $0.setTitleColor(.primary, for: .normal)
        $0.titleLabel?.font = .robotoRegular16
    }
    
    public static let editButton = Style<UIButton> {
        $0.setTitleColor(.secondary, for: .normal)
        $0.titleLabel?.font = .robotoBold16
    }

    ///
    /// Login/SignUp Styles
    ///

    public static let loginButton = Style<UIButton> {
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = .robotoBold16
        $0.backgroundColor = .primary
        $0.layer.cornerRadius = 6.0
    }


    public static let checkButton = Style<UIButton> {
        $0.setTitleColor(.primary, for: .normal)
        $0.titleLabel?.font = .robotoRegular12
        $0.contentHorizontalAlignment = .left
        $0.titleLabel?.lineBreakMode = .byWordWrapping
    }

}

public class Style<V> where V: UIView {
    public let style: (V) -> Void

    public init(_ style: @escaping (V) -> Void) {
        self.style = style
    }

    public func apply(to view: V) {
        style(view)
    }
}

extension UIButton {
    private static var _style = [String:Style<UIButton>]()

    public var style: Style<UIButton> {
        get {
            let tmpAddress = String(format: "%p", unsafeBitCast(self, to: Int.self))
            return UIButton._style[tmpAddress] ?? UIButtonStyles.defaultStyle
        }
        set(newValue) {
            let tmpAddress = String(format: "%p", unsafeBitCast(self, to: Int.self))
            UIButton._style[tmpAddress] = newValue
            newValue.apply(to: self)
        }
    }
}
