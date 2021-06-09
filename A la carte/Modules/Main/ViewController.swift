//
//  ViewController.swift
//  A la carte
//
//  Created by Sopra on 17/01/2021.
//

import UIKit

class ViewController: UIViewController {

    private enum Constants {
        static let cornerRadius: CGFloat = 16.0
        static let shadowRadius: CGFloat = 5.0
        static let shadowOpacity: Float = 0.5
        
        static let segueRestaurant = "show_restaurant"
        static let segueGuests = "show_guests"
        static let segueLiked = "show_liked"
    }
    
    @IBOutlet private weak var imageLogo: UIImageView!
    @IBOutlet private weak var helloLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var disclaimerCopyright: UILabel!
    @IBOutlet private weak var restaurantButton: UIButton!
    @IBOutlet private weak var inviteButton: UIButton!
    @IBOutlet private weak var likedButton: UIButton!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTexts()
    }
    
    private func setupUI() {
        helloLabel.font = .robotoBold18
        helloLabel.textColor = .main
        
        descriptionLabel.font = .robotoRegular16
        descriptionLabel.textColor = .secondMain
        
        disclaimerCopyright.font = .robotoBold12
        disclaimerCopyright.textColor = .main
        
        restaurantButton.setTitle("Restaurant access".uppercased(), for: .normal)
        restaurantButton.setTitleColor(.white, for: .normal)
        restaurantButton.backgroundColor = .primary
        restaurantButton.layer.cornerRadius = Constants.cornerRadius
        restaurantButton.titleLabel?.font = .robotoBold16
        
        inviteButton.setTitle("Guest access".uppercased(), for: .normal)
        inviteButton.setTitleColor(.white, for: .normal)
        inviteButton.backgroundColor = .primary
        inviteButton.layer.cornerRadius = Constants.cornerRadius
        inviteButton.titleLabel?.font = .robotoBold16
        
        likedButton.setTitle("Liked restaurants".uppercased(), for: .normal)
        likedButton.setTitleColor(.white, for: .normal)
        likedButton.backgroundColor = .primary
        likedButton.layer.cornerRadius = Constants.cornerRadius
        likedButton.titleLabel?.font = .robotoBold16

    }
    
    private func setupTexts() {
        helloLabel.text = "HELLO!"
        descriptionLabel.text = "Para ofrecerte un contenido personalizado, indícanos qué tipo de perfil eres"
        disclaimerCopyright.text = "© 2021 A la carte. All rights reserved"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.segueRestaurant {
            
        } else if segue.identifier == Constants.segueGuests {
            
        }
    }
    
    @IBAction func restaurantButtonAction(_ sender: UIButton) {
        performSegue(withIdentifier: Constants.segueRestaurant, sender: self)
    }
    
    @IBAction func inviteButtonAction(_ sender: UIButton) {
        performSegue(withIdentifier: Constants.segueGuests, sender: self)
    }
    
    @IBAction func likedButtonAction(_ sender: UIButton) {
        performSegue(withIdentifier: Constants.segueLiked, sender: self)
    }
}

class OptionGestureRecognizer: UITapGestureRecognizer {
    var isRestaurant = Bool()
}
