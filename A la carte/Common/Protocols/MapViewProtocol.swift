//
//  MapViewProtocol.swift
//  A la carte
//
//  Created by Sopra on 02/03/2021.
//

import Foundation
import MapKit

protocol MapViewProtocol {
    func getSelectedLocation(placemark: MKPlacemark)
}
