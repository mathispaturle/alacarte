//
//  UITableView+Scroll.swift
//  A la carte
//
//  Created by Sopra on 01/03/2021.
//

import Foundation
import UIKit

extension UITableView {

    func scrollToTop(section: Int) {
        let rows = self.numberOfRows(inSection: section)

        if rows > 0 {
            DispatchQueue.main.async {
                let indexPath = IndexPath(row: rows - 1, section: section)
                self.scrollToRow(at: indexPath, at: .top, animated: true)
            }
        }
    }
}
