//
//  AddDishProtocol.swift
//  A la carte
//
//  Created by Sopra on 03/03/2021.
//

import Foundation

protocol AddDishProtocol {
    func navigateToAddDish(origin: DishOrigin)
}

protocol DishConfirmation {
    func addDish(isNew: Bool, categoryID: Int, dishId: Int, name: String, description: String, allergens: [Int], price: String)
}

protocol DishController {
    func deleteDish(id: Int, categoryId: String)
    func editDish(id: Int)
}

protocol DishDelete {
    func deleteDish(id: Int, parentId: Int)
}
