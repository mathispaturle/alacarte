//
//  Menu.swift
//  A la carte
//
//  Created by Sopra on 07/03/2021.
//

import Foundation
import Firebase

struct Menu {
    
    let uuid: String
    let name: String
    let description: String
    var published: Bool
    var categories: [Categories]
    
    init(uuid: String, name: String, description: String, published: Bool) {
        self.uuid = uuid
        self.name = name
        self.description = description
        self.published = published
        self.categories = []
    }
    
    init(document: DocumentSnapshot?) {
        if let menu = document {
            if let data = menu.data() {
                let key = Database.MenuKey.self
                self.uuid = data[key.uuid] as? String ?? ""
                self.name = data[key.name] as? String ?? ""
                self.description = data[key.description] as? String ?? ""
                self.published = false

            } else {
                self.uuid = ""
                self.name = ""
                self.description = ""
                self.published = false
            }
        } else {
            self.uuid = ""
            self.name = ""
            self.description = ""
            self.published = false
        }
        self.categories = []
    }
}
