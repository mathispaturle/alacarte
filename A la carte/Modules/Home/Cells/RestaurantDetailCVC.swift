//
//  RestaurantDetailCVC.swift
//  A la carte
//
//  Created by Sopra on 25/02/2021.
//

import UIKit
import MapKit

class RestaurantDetailCVC: UICollectionViewCell, NibReusable {

    private enum Constants {
        static let cornerRadius: CGFloat = 22
        static let shadowRadius: CGFloat = 5.0
        static let shadowOpacity: Float = 0.5
        static let padding: CGFloat = 16.0
        static let key: String = "likedKey"
    }
    
    // MARK: Variables
    
    @IBOutlet private weak var shadowView: UIView!
    @IBOutlet private weak var cardView: UIView!
    @IBOutlet private weak var mapView: MKMapView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var qrButton: UIButton!

    var selectedPin: MKPlacemark? = nil
    var homeDelegate: HomeCallback?
    var restaurantID: String = ""
    private var isGuest: Bool = false
    private var isLiked: Bool = false
    private var qrInformation: String = ""
    
    // MARK: View lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
        setupTexts()
    }
    
    // MARK: Custom methods
    
    private func setupUI() {
        cardView.layer.cornerRadius = Constants.cornerRadius
        shadowView.layer.shadowColor = UIColor.light.cgColor
        shadowView.layer.shadowOpacity = Constants.shadowOpacity
        shadowView.layer.shadowOffset = .zero
        shadowView.layer.shadowRadius = Constants.shadowRadius
        shadowView.layer.cornerRadius = Constants.cornerRadius
        
        titleLabel.font = .robotoBold22
        titleLabel.textColor = .main
        
        subtitleLabel.font = .robotoRegular14
        subtitleLabel.textColor = .lightGray
        
        qrButton.tintColor = .primary
    }
    
    private func setupTexts() {
        titleLabel.text = "Restaurante del mar".uppercased()
        subtitleLabel.text = "Lorem ipsum dolor lorem, 5"
    }
    
    func configure(id: String, title: String, subtitle: String, longitude: Double, latitude: Double, isGuest: Bool = false, qrInformation: String = "") {
        restaurantID = id
        titleLabel.text = title
        subtitleLabel.text = subtitle
        
        let coordinate = CLLocation(latitude: latitude, longitude: longitude)
        mapView.centerToLocation(coordinate)
        
        self.isGuest = isGuest
        self.qrInformation = qrInformation
        isLikedState()
    }
    
    private func isLikedState() {
        
        // Access Shared Defaults Object
        let userDefaults = UserDefaults.standard

        // Read/Get Array of Strings
        let ids: [String] = userDefaults.object(forKey: Constants.key) as? [String] ?? []

        // Append String to Array of Strings
        if ids.contains(qrInformation) {
           isLiked = true
        }
        
        if isGuest {
            var imageName = "heart"
            if isLiked { imageName += ".fill"}
            
            qrButton.setImage(UIImage(systemName: imageName), for: .normal)
        }
    }
    
    @IBAction func qrCodeButtonTapped(_ sender: UIButton) {
        if !isGuest {
            homeDelegate?.presentQRScreenEncrypted(withID: restaurantID)
        } else {
            isLiked = !isLiked
            storeInLocalLikedRestaurants()
            isLikedState()
        }
    }
    
    private func storeInLocalLikedRestaurants() {
        // Access Shared Defaults Object
        let userDefaults = UserDefaults.standard

        // Read/Get Array of Strings
        var ids: [String] = userDefaults.object(forKey: Constants.key) as? [String] ?? []

        // Append String to Array of Strings
        if !ids.contains(qrInformation) {
            ids.append(qrInformation)
        } else {
            guard let index = ids.firstIndex(of: qrInformation) else { return }
            ids.remove(at: index)
        }
        
        // Write/Set Array of Strings
        userDefaults.set(ids, forKey: Constants.key)
    }
}

private extension MKMapView {
    func centerToLocation(_ location: CLLocation, regionRadius: CLLocationDistance = 1000) {
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: regionRadius,longitudinalMeters: regionRadius)
        setRegion(coordinateRegion, animated: true)
        
        let pin = MKPointAnnotation()
        pin.coordinate = location.coordinate
        addAnnotation(pin)
        
    }
}
