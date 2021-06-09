//
//  CollapsableCategory.swift
//  A la carte
//
//  Created by Sopra on 16/03/2021.
//

import Foundation

protocol CollapsableCategory {
    func updateLayoutCallback(indexPath: IndexPath, isCollapsed: Bool)
}
