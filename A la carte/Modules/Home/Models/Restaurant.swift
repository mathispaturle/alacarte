//
//  Restaurant.swift
//  A la carte
//
//  Created by Sopra on 02/03/2021.
//

import Foundation
import Firebase

struct Restaurant {
    
    let uuid: String
    let name: String
    let locationLongitude: Double
    let locationLatitude: Double
    let locationName: String
    let email: String
    let instagram: String
    let phone: String
    
    init(uuid: String, name: String, locationLongitude: Double, locationLatitude: Double, locationName: String, email: String, instagram: String, phone: String) {
        self.uuid = uuid
        self.name = name
        self.locationLongitude = locationLongitude
        self.locationLatitude = locationLatitude
        self.locationName = locationName
        self.email = email
        self.instagram = instagram
        self.phone = phone
    }
    
    init(document: DocumentSnapshot?) {
        if let restaurant = document {
            if let data = restaurant.data() {
                let key = Database.RestaurantsKey.self
                self.uuid = data[key.uuid] as? String ?? ""
                self.name = data[key.name] as? String ?? ""
                self.locationLongitude = data[key.locationLongitude] as? Double ?? 0.0
                self.locationLatitude = data[key.locationLatitude] as? Double ?? 0.0
                self.locationName = data[key.locationName] as? String ?? ""
                self.email = data[key.email] as? String ?? ""
                self.instagram = data[key.instagram] as? String ?? ""
                self.phone = data[key.phone] as? String ?? ""
            } else {
                self.uuid = ""
                self.name = ""
                self.locationLongitude = 0.0
                self.locationLatitude = 0.0
                self.locationName = ""
                self.email = ""
                self.instagram = ""
                self.phone = ""
            }
        } else {
            self.uuid = ""
            self.name = ""
            self.locationLongitude = 0.0
            self.locationLatitude = 0.0
            self.locationName = ""
            self.email = ""
            self.instagram = ""
            self.phone = ""
        }
    }
    
    init() {
        self.uuid = ""
        self.name = ""
        self.locationLongitude = 0.0
        self.locationLatitude = 0.0
        self.locationName = ""
        self.email = ""
        self.instagram = ""
        self.phone = ""
    }
}
