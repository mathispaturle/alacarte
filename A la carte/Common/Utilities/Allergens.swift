//
//  Allergens.swift
//  A la carte
//
//  Created by Sopra on 16/03/2021.
//

import Foundation

struct Allergens {
    var allergens: [Allergen]
    
    init() {
        allergens = [
            Allergen(id: 0, name: "Gluten free",                            image: "gluten-free.png"),
            Allergen(id: 1, name: "Crustaceans free",                       image: "crustean-free.png"),
            Allergen(id: 2, name: "Eggs free",                              image: "egg-free.png"),
            Allergen(id: 3, name: "Fish free",                              image: "fish-free.png"),
            Allergen(id: 4, name: "Peanuts free",                           image: "peanut-free.png"),
            Allergen(id: 5, name: "Soybeans free",                          image: "soya-free.png"),
            Allergen(id: 6, name: "Milk free",                              image: "dairy-free.png"),
            Allergen(id: 7, name: "Nuts free",                              image: "walnut-free.png"),
            Allergen(id: 8, name: "Celery free",                            image: "cruelty-free.png"),
            Allergen(id: 9, name: "Mustard free",                           image: "mustard-free.png"),
            Allergen(id: 10, name: "Sesame seeds free",                     image: "cruelty-free.png"),
            Allergen(id: 11, name: "Sulphur and sulphites free",            image: "gmo-free.png"),
            Allergen(id: 12, name: "Lupin free",                            image: "cruelty-free.png"),
            Allergen(id: 13, name: "Molluscs free",                         image: "molluscs-free.png")
        ]
    }
}

struct Allergen {
    
    let id: Int
    let name: String
    let image: String
    var isChecked: Bool
    
    init(id: Int, name: String, image: String) {
        self.id = id
        self.name = name
        self.image = image
        isChecked = false
    }
}
