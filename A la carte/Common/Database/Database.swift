//
//  Database.swift
//  A la carte
//
//  Created by Sopra on 24/02/2021.
//

import Foundation

final class Database {
    enum Table {
        static let Users = "USERS"
        static let Restaurants = "RESTAURANTS"
        static let Menu = "MENU"
        static let Dish = "DISH"
        static let DishCategory = "DISH_CATEGORY"
    }
    
    enum UserKey {
        static let uuid = "uuid"
        static let name = "name"
        static let location = "location"
        static let image = "image"
        static let menus = "menus"
        static let email = "email"
        static let phone = "phone"
        static let restaurants = "restaurants"
    }
    
    enum RestaurantsKey {
        static let uuid = "uuid"
        static let name = "name"
        static let locationLongitude = "locationLongitude"
        static let locationLatitude = "locationLatitude"
        static let locationName = "locationName"
        static let menus = "menus"
        static let email = "email"
        static let instagram = "instagram"
        static let phone = "phone"
    }
    
    enum MenuKey {
        static let uuid = "uuid"
        static let name = "name"
        static let description = "description"
        static let published = "published"
    }
    
    enum DishKey {
        static let uuid = "uuid"
        static let name = "name"
        static let description = "description"
        static let allergens = "allergens"
        static let price = "price"
    }
    
    enum CategoryKey {
        static let id = "id"
        static let uuid = "uuid"
        static let name = "name"
        static let description = "description"
    }
    
    enum UserRestaurantKey {
        static let id = "restaurants"
        static let published = "published"
    }
}
