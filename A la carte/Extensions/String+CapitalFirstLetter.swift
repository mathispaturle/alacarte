//
//  String+CapitalFirstLetter.swift
//  A la carte
//
//  Created by Mathis Paturle on 7/6/21.
//

import UIKit

extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }

    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}
