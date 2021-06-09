//
//  CategoryOrigin.swift
//  A la carte
//
//  Created by Sopra on 18/03/2021.
//

import Foundation

struct CategoryOrigin {
    let uuid: String
    let menuUid: String
    let indexPath: IndexPath
    let nameCategory: String
    let descriptionCategory: String
    
    init(uuid: String, menuUid: String, indexPath: IndexPath, name: String, description: String) {
        self.uuid = uuid
        self.menuUid = menuUid
        self.indexPath = indexPath
        self.nameCategory = name
        self.descriptionCategory = description
    }
    
    init() {
        self.uuid = ""
        self.menuUid = ""
        self.indexPath = IndexPath()
        self.nameCategory = ""
        self.descriptionCategory = ""
    }
}
