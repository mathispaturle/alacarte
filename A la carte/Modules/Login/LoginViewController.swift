//
//  LoginViewController.swift
//  A la carte
//
//  Created by Sopra on 24/02/2021.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {

    private enum Constants {
        static let cornerRadius: CGFloat = 10.0
        static let shadowRadius: CGFloat = 5.0
        static let shadowOpacity: Float = 0.5
        static let padding: CGFloat = 16.0
        
        static let segueShowMenus = "showMenus"
        static let segueShowRegister = "showRegister"

        static let clientId = "211676783926-2j3d3me78s85j0b24jfn225cm01qf4q4.apps.googleusercontent.com"
    }
    
    // MARK: Variables
    
    @IBOutlet private weak var loginLabel: UILabel!
    @IBOutlet private weak var emailField: UITextField!
    @IBOutlet private weak var passwordField: UITextField!
    @IBOutlet private weak var loginButton: UIButton!
    @IBOutlet private weak var registerButton: UIButton!
    @IBOutlet private weak var forgotButton: UIButton!

    // MARK: View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTextFields()
    }
    
    // MARK: Custom methods
    private func setupUI() {
        loginLabel.font = .robotoBold32
        
        loginButton.layer.cornerRadius = Constants.cornerRadius
        loginButton.backgroundColor = .primary
        loginButton.setTitle("LOGIN", for: .normal)
        loginButton.setTitleColor(.white, for: .normal)
        loginButton.titleLabel?.font = .robotoBold14
        loginButton.layer.shadowColor = UIColor.light.cgColor
        loginButton.layer.shadowOpacity = Constants.shadowOpacity
        loginButton.layer.shadowOffset = .zero
        loginButton.layer.shadowRadius = Constants.shadowRadius
     
        registerButton.setTitle("Don't have an account? Register", for: .normal)
        registerButton.setTitleColor(.main, for: .normal)
        registerButton.titleLabel?.font = .robotoBold14
        
        forgotButton.setTitle("Forgot password?", for: .normal)
        forgotButton.setTitleColor(.main, for: .normal)
        forgotButton.titleLabel?.font = .robotoRegular14
        
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
        
        hideKeyboardWhenTappedAround()
    }
    
    func hideKeyboardWhenTappedAround() {
        let tapGesture = UITapGestureRecognizer(target: self,
                         action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapGesture)
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
    
    @IBAction func login() {
        if let email = emailField.text, let password = passwordField.text {
            Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
                guard let strongSelf = self else { return }
                strongSelf.performSegue(withIdentifier: Constants.segueShowMenus, sender: self)
            }
        }
    }
    
    @IBAction func showRegister() {
        performSegue(withIdentifier: Constants.segueShowRegister, sender: self)
    }
    
    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.segueShowMenus {
            
        }
    }
    
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
}
