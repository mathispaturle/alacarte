//
//  DishOrigin.swift
//  A la carte
//
//  Created by Sopra on 18/03/2021.
//

import Foundation

struct DishOrigin {
    let isNew: Bool
    let indexPath: IndexPath
    
    init(isNew: Bool, indexPath: IndexPath) {
        self.isNew = isNew
        self.indexPath = indexPath
    }
}
