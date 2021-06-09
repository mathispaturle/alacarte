//
//  MenuContainer.swift
//  A la carte
//
//  Created by Sopra on 02/03/2021.
//

import Foundation
import Firebase

struct MenuContainer {
    var menuInformation: [DataFormModel]
    var categories: [Categories]
    
    init() {
        self.menuInformation = []
        self.categories = []
    }
    
    init(dataForm: [DataFormModel]) {
        self.menuInformation = dataForm
        self.categories = []
    }
}

struct Categories {
    var id: Int
    var uuid: String
    var name: String
    var description: String
    var dishes: [DishForm]
    var isCollapsed: Bool
    
    init(id: Int, name: String, description: String) {
        self.id = id
        self.uuid = ""
        self.name = name
        self.description = description
        self.dishes = []
        self.isCollapsed = false
    }
    
    init(snapshot: DocumentSnapshot) {
        if let data = snapshot.data() {
            let key = Database.CategoryKey.self
            self.id = data[key.id] as? Int ?? 0
            self.uuid = snapshot.documentID
            self.name = data[key.name] as? String ?? ""
            self.description = data[key.description] as? String ?? ""
        } else {
            self.id = 0
            self.uuid = ""
            self.name = ""
            self.description = ""
        }
        self.dishes = []
        self.isCollapsed = false
    }
}

struct DishForm {
    var id: Int
    var uuid: String
    var name: String
    var price: String
    var description: String
    var allergens: [Int]
    
    init(name: String, description: String, price: String, allergens: [Int]) {
        self.id = 0
        self.uuid = ""
        self.name = name
        self.price = price
        self.description = description
        self.allergens = allergens
    }
    
    init(id: Int) {
        self.id = id
        self.uuid = ""
        self.name = ""
        self.price = "0.00"
        self.description = ""
        self.allergens = []
    }
    
    init(snapshot: DocumentSnapshot) {
        if let data = snapshot.data() {
            let key = Database.DishKey.self
            self.uuid = snapshot.documentID
            self.id = 0
            self.name = data[key.name] as? String ?? ""
            self.price = data[key.price] as? String ?? ""
            self.description = data[key.description] as? String ?? ""
            self.allergens = data[key.allergens] as? [Int] ?? []
        } else {
            self.id = 0
            self.uuid = ""
            self.name = ""
            self.price = "0.00"
            self.description = ""
            self.allergens = []
        }
    }
}
