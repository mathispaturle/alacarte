//
//  UISearchBar+TextField.swift
//  WeAreNutrition
//
//  Created by Sopra on 23/11/2020.
//  Copyright © 2020 MORALES OSORIO Irene. All rights reserved.
//

import Foundation
import UIKit
extension UISearchBar {
    var textField: UITextField? {
        if #available(iOS 13.0, *) {
            return self.searchTextField
        } else {
            // Fallback on earlier versions
            for view: UIView in subviews[0].subviews {
                if let textField = view as? UITextField {
                    return textField
                }
            }
        }
        return nil
    }
}
