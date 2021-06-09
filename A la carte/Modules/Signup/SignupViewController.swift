//
//  SignupViewController.swift
//  A la carte
//
//  Created by Sopra on 24/02/2021.
//

import UIKit
import Firebase

class SignupViewController: UIViewController {

    private enum Constants {
        static let cornerRadius: CGFloat = 10.0
        static let shadowRadius: CGFloat = 5.0
        static let shadowOpacity: Float = 0.5
        static let padding: CGFloat = 16.0
        
        static let segueShowMenus = "showMenus"
        static let clientId = "211676783926-2j3d3me78s85j0b24jfn225cm01qf4q4.apps.googleusercontent.com"
    }
    
    // MARK: Variables
    
    @IBOutlet private weak var signupLabel: UILabel!
    @IBOutlet private weak var emailField: UITextField!
    @IBOutlet private weak var passwordField: UITextField!
    @IBOutlet private weak var repeatPasswordField: UITextField!
    @IBOutlet private weak var signupButton: UIButton!

    // MARK: View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTextFields()
    }
    
    // MARK: Custom methods
    private func setupUI() {
        signupLabel.font = .robotoBold32
        
        signupButton.layer.cornerRadius = Constants.cornerRadius
        signupButton.backgroundColor = .primary
        signupButton.setTitle("SIGN UP", for: .normal)
        signupButton.setTitleColor(.white, for: .normal)
        signupButton.titleLabel?.font = .robotoBold14
        signupButton.layer.shadowColor = UIColor.light.cgColor
        signupButton.layer.shadowOpacity = Constants.shadowOpacity
        signupButton.layer.shadowOffset = .zero
        signupButton.layer.shadowRadius = Constants.shadowRadius
    }
    
    private func setupTextFields() {
        emailField.layer.cornerRadius = Constants.cornerRadius
        emailField.backgroundColor = .white
        emailField.layer.shadowColor = UIColor.light.cgColor
        emailField.layer.shadowOpacity = Constants.shadowOpacity
        emailField.layer.shadowOffset = .zero
        emailField.layer.shadowRadius = Constants.shadowRadius
        emailField.setLeftPaddingPoints(Constants.padding)
        emailField.font = .robotoBold16
        emailField.textColor = .dark
        emailField.attributedPlaceholder = NSAttributedString(string: "EMAIL", attributes: [NSAttributedString.Key.foregroundColor: UIColor.light, NSAttributedString.Key.font: UIFont.robotoBold14])

        passwordField.layer.cornerRadius = Constants.cornerRadius
        passwordField.backgroundColor = .white
        passwordField.layer.shadowColor = UIColor.light.cgColor
        passwordField.layer.shadowOpacity = Constants.shadowOpacity
        passwordField.layer.shadowOffset = .zero
        passwordField.layer.shadowRadius = Constants.shadowRadius
        passwordField.setLeftPaddingPoints(Constants.padding)
        passwordField.isSecureTextEntry = true
        passwordField.font = .robotoBold16
        passwordField.textColor = .dark
        passwordField.attributedPlaceholder = NSAttributedString(string: "PASSWORD", attributes: [NSAttributedString.Key.foregroundColor: UIColor.light, NSAttributedString.Key.font: UIFont.robotoBold14])
        
        repeatPasswordField.layer.cornerRadius = Constants.cornerRadius
        repeatPasswordField.backgroundColor = .white
        repeatPasswordField.layer.shadowColor = UIColor.light.cgColor
        repeatPasswordField.layer.shadowOpacity = Constants.shadowOpacity
        repeatPasswordField.layer.shadowOffset = .zero
        repeatPasswordField.layer.shadowRadius = Constants.shadowRadius
        repeatPasswordField.setLeftPaddingPoints(Constants.padding)
        repeatPasswordField.isSecureTextEntry = true
        repeatPasswordField.font = .robotoBold16
        repeatPasswordField.textColor = .dark
        repeatPasswordField.attributedPlaceholder = NSAttributedString(string: "CONFIRM PASSWORD", attributes: [NSAttributedString.Key.foregroundColor: UIColor.light, NSAttributedString.Key.font: UIFont.robotoBold14])
    }
    
    
    // MARK: Action methods
    
    @IBAction func closeScreen(_ sender: UIButton) {
        dismiss(animated: true, completion: {
            let firebaseAuth = Auth.auth()
            do {
                try firebaseAuth.signOut()
            } catch let signOutError as NSError {
                print ("Error signing out: %@", signOutError)
            }
        })
    }
    
    @IBAction func signup() {
        if let email = emailField.text, let password = passwordField.text, let repeatPassword = repeatPasswordField.text {
            if password == repeatPassword {
                Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                    
                    if let err = error {
                        print("ERROR::SignupViewController: \(err.localizedDescription)")
                        return
                    }
                    
                    if let uuid = authResult?.user.uid {
                    
                        let db = Firestore.firestore()
                        let keys = Database.UserKey.self
                        db.collection(Database.Table.Users).document(uuid).setData([
                            keys.uuid: uuid,
                            keys.email: email,
                            keys.name: "",
                            keys.location: "",
                            keys.image: "",
                            keys.phone: ""
                        ]) { err in
                            if let err = err {
                                print("Error writing document: \(err)")
                                return
                            }
                            self.performSegue(withIdentifier: Constants.segueShowMenus, sender: self)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.segueShowMenus {
            
        }
    }
}

