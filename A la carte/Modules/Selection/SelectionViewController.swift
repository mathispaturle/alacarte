//
//  SelectionViewController.swift
//  A la carte
//
//  Created by Sopra on 01/03/2021.
//

import UIKit

class SelectionViewController: UIViewController {

    private enum Constants {
        static let cornerRadius: CGFloat = 20
        static let shadowRadius: CGFloat = 5.0
        static let shadowOpacity: Float = 0.5
        static let padding: CGFloat = 16.0
        static let key = "isSet"
    }
    
    private enum Segues {
        static let addRestaurant = "showAddRestaurant"
        static let addMenu = "showAddMenu"
    }
    
    @IBOutlet private weak var viewFrame: UIView!
    
    @IBOutlet private weak var restaurantView: UIView!
    @IBOutlet private weak var menuView: UIView!

    @IBOutlet private weak var restaurantLabel: UILabel!
    @IBOutlet private weak var menuLabel: UILabel!
    
    var delegate: HomeCallback?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let data = UserDefaults.standard.bool(forKey: Constants.key)
        
        if data {
            delegate?.getUpdatedElements()
            UserDefaults.standard.removeObject(forKey: Constants.key)
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func setupUI() {
//        view.backgroundColor = .clear
        viewFrame.layer.cornerRadius = Constants.cornerRadius
        
        restaurantLabel.font = .robotoBold18
        restaurantLabel.textColor = .main
        restaurantLabel.text = "Restaurant"
        restaurantLabel.isUserInteractionEnabled = false
        
        menuLabel.font = .robotoBold18
        menuLabel.textColor = .main
        menuLabel.text = "Menu"
        menuLabel.isUserInteractionEnabled = false
        
        let gestureRestaurant = UITapGestureRecognizer(target: self, action: #selector(addRestaurantButton(_:)))
        let gestureMenu = UITapGestureRecognizer(target: self, action: #selector(addMenuButton(_:)))
        let gestureClose = UITapGestureRecognizer(target: self, action: #selector(closeViewButton(_:)))
        
        restaurantView.isUserInteractionEnabled = true
        menuView.isUserInteractionEnabled = true
        view.isUserInteractionEnabled = true
        
        restaurantView.addGestureRecognizer(gestureRestaurant)
        menuView.addGestureRecognizer(gestureMenu)
        view.addGestureRecognizer(gestureClose)
    }

    @objc private func closeViewButton(_ sender: UITapGestureRecognizer) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func addRestaurantButton(_ sender: UITapGestureRecognizer) {
        performSegue(withIdentifier: Segues.addRestaurant, sender: self)
    }
    
    @objc private func addMenuButton(_ sender: UITapGestureRecognizer) {
        performSegue(withIdentifier: Segues.addMenu, sender: self)
    }
}
