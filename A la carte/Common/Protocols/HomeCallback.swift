//
//  HomeCallback.swift
//  A la carte
//
//  Created by Sopra on 08/03/2021.
//

import Foundation

protocol HomeCallback {
    func getUpdatedElements()
    func updatePublishedState(id: Int, isPublished: Bool)
    func presentQRScreenEncrypted(withID: String)
}
