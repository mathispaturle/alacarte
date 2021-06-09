//
//  LocationViewController.swift
//  A la carte
//
//  Created by Sopra on 02/03/2021.
//

import UIKit
import MapKit

protocol HandleMapSearch {
    func dropPinZoomIn(placemark: MKPlacemark)
}

class LocationViewController: UIViewController {

    private enum Constants {
        static let storyboardID = "LocationSearchTable"
        static let cornerRadius: CGFloat = 20
        static let shadowRadius: CGFloat = 5.0
        static let shadowOpacity: Float = 0.5
        static let padding: CGFloat = 16.0
    }
    
    // MARK: UIElements

    @IBOutlet var mapView: MKMapView!

    @IBOutlet private weak var cancelButton: UIButton!
    @IBOutlet private weak var confirmButton: UIButton!

    // MARK: Variables

    let locationManager = CLLocationManager()
    var resultSearchController: UISearchController? = nil
    var selectedPin: MKPlacemark? = nil
    var delegate: MapViewProtocol?
    
    // MARK: UI Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupMapKit()
        setupSearchBar()
    }
    
    // MARK: Custom methods
    
    private func setupMapKit() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }
    
    private func setupSearchBar() {
        if let storyboard = storyboard {
            if let locationSearchTable = storyboard.instantiateViewController(withIdentifier: Constants.storyboardID) as? LocationSearchTable {
                resultSearchController = UISearchController(searchResultsController: locationSearchTable)
                resultSearchController?.searchResultsUpdater = locationSearchTable
                locationSearchTable.mapView = mapView
                locationSearchTable.handleMapSearchDelegate = self
            }
        }
        
        if let searchBar = resultSearchController?.searchBar {
            searchBar.sizeToFit()
            searchBar.placeholder = "Search for places"
            navigationItem.titleView = resultSearchController?.searchBar
        }
        
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        definesPresentationContext = true
    }
    
    private func setupUI() {
        cancelButton.backgroundColor = .primary
        cancelButton.titleLabel?.font = .robotoBold16
        cancelButton.setTitle("CANCEL", for: .normal)
        cancelButton.setTitleColor(.white, for: .normal)
        cancelButton.layer.shadowColor = UIColor.light.cgColor
        cancelButton.layer.shadowOpacity = Constants.shadowOpacity
        cancelButton.layer.shadowOffset = .zero
        cancelButton.layer.shadowRadius = Constants.shadowRadius
        cancelButton.layer.cornerRadius = Constants.cornerRadius
        
        confirmButton.backgroundColor = .primary
        confirmButton.titleLabel?.font = .robotoBold16
        confirmButton.setTitle("CONFIRM", for: .normal)
        confirmButton.setTitleColor(.white, for: .normal)
        confirmButton.layer.shadowColor = UIColor.light.cgColor
        confirmButton.layer.shadowOpacity = Constants.shadowOpacity
        confirmButton.layer.shadowOffset = .zero
        confirmButton.layer.shadowRadius = Constants.shadowRadius
        confirmButton.layer.cornerRadius = Constants.cornerRadius
    }
    
    // MARK: Actions
    @IBAction func cancelTapped (_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func confirmTapped (_ sender: UIButton) {
        if let pin = selectedPin {
            delegate?.getSelectedLocation(placemark: pin)
        }
        dismiss(animated: true, completion: nil)
    }
}

// MARK: Extension for Location Delegate

extension LocationViewController : CLLocationManagerDelegate {
    private func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            let span = MKCoordinateSpan.init(latitudeDelta: 0.05, longitudeDelta: 0.05)
            let region = MKCoordinateRegion(center: location.coordinate, span: span)
            mapView.setRegion(region, animated: true)
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Swift.Error) {
        print("error:: \(error)")
    }
}

extension LocationViewController: HandleMapSearch {
    func dropPinZoomIn(placemark: MKPlacemark){
        // cache the pin
        selectedPin = placemark
        // clear existing pins
        mapView.removeAnnotations(mapView.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name
        if let city = placemark.locality, let state = placemark.administrativeArea {
            annotation.subtitle = "\(city) \(state)"
        }
        mapView.addAnnotation(annotation)
        let span = MKCoordinateSpan.init(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion.init(center: placemark.coordinate, span: span)
        mapView.setRegion(region, animated: true)
    }
}
