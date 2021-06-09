//
//  AllergensProtocol.swift
//  A la carte
//
//  Created by Sopra on 17/03/2021.
//

import Foundation

protocol AllergensProtocol {
    func updateState(id: Int, isActive: Bool)
    func confirmAllergens(list: [Int])
}
