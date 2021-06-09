//
//  AddCategoryViewController.swift
//  A la carte
//
//  Created by Sopra on 03/03/2021.
//

import UIKit
import Firebase

class AddCategoryViewController: UIViewController {

    private enum Constants {
        static let spacingRows: CGFloat = 16.0
        static let cornerRadius: CGFloat = 20
        static let shadowRadius: CGFloat = 5.0
        static let shadowOpacity: Float = 0.5
        static let padding: CGFloat = 16.0
        static let key = "isSetB"
    }
    
    @IBOutlet private weak var cancelButton: UIButton!
    @IBOutlet private weak var addButton: UIButton!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var categoryField: UITextField!
    @IBOutlet private weak var descriptionField: UITextField!
    
    var categoryDelegate: CategoryProtocol?
    
    var origin: CategoryOrigin?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTextFields()
        setupTexts()
    }
    
    private func setupUI() {
        titleLabel.font = .robotoBold24
        titleLabel.text = "ADD NEW CATEGORY"
        
        addButton.backgroundColor = .primary
        addButton.titleLabel?.font = .robotoBold16
        addButton.setTitle("ADD CATEGORY", for: .normal)
        addButton.setTitleColor(.white, for: .normal)
        addButton.layer.shadowColor = UIColor.light.cgColor
        addButton.layer.shadowOpacity = Constants.shadowOpacity
        addButton.layer.shadowOffset = .zero
        addButton.layer.shadowRadius = Constants.shadowRadius
        addButton.layer.cornerRadius = Constants.cornerRadius
    }
    
    private func setupTextFields() {
        categoryField.layer.cornerRadius = Constants.cornerRadius
        categoryField.backgroundColor = .white
        categoryField.layer.shadowColor = UIColor.light.cgColor
        categoryField.layer.shadowOpacity = Constants.shadowOpacity
        categoryField.layer.shadowOffset = .zero
        categoryField.layer.shadowRadius = Constants.shadowRadius
        categoryField.setLeftPaddingPoints(Constants.padding)
        categoryField.font = .robotoBold16
        categoryField.textColor = .dark
        categoryField.attributedPlaceholder = NSAttributedString(string: "CATEGORY", attributes: [NSAttributedString.Key.foregroundColor: UIColor.light, NSAttributedString.Key.font: UIFont.robotoBold14])

        descriptionField.layer.cornerRadius = Constants.cornerRadius
        descriptionField.backgroundColor = .white
        descriptionField.layer.shadowColor = UIColor.light.cgColor
        descriptionField.layer.shadowOpacity = Constants.shadowOpacity
        descriptionField.layer.shadowOffset = .zero
        descriptionField.layer.shadowRadius = Constants.shadowRadius
        descriptionField.setLeftPaddingPoints(Constants.padding)
        descriptionField.font = .robotoBold16
        descriptionField.textColor = .dark
        descriptionField.attributedPlaceholder = NSAttributedString(string: "DESCRIPTION", attributes: [NSAttributedString.Key.foregroundColor: UIColor.light, NSAttributedString.Key.font: UIFont.robotoBold14])
    }
    
    private func setupTexts() {
        guard let origin = origin else { return }
        
        categoryField.text = origin.nameCategory
        descriptionField.text = origin.descriptionCategory
        
        titleLabel.text = "EDIT CATEGORY"
        addButton.setTitle("UPDATE CATEGORY", for: .normal)

    }
    
    @IBAction func cancelAction(_ sender: UIButton) {
        if let nc = navigationController {
            nc.popViewController(animated: true)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func addAction(_ sender: UIButton) {
        handleFirebaseUpload()
    }
}

extension AddCategoryViewController {
    private func handleFirebaseUpload() {
        if let category = categoryField.text, let description = descriptionField.text {
            if !category.isEmpty {
                if let origin = origin {
                    let db = Firestore.firestore()
                    let key = Database.CategoryKey.self
                    db.collection(Database.Table.Menu).document(origin.menuUid).collection(Database.Table.DishCategory).document(origin.uuid).setData([
                        key.name: category,
                        key.description: description
                    ], merge: true) { err in
                        if let err = err {
                            print("Error updating category: \(err)")
                            return
                        }
                        
                        UserDefaults.standard.setValue(true, forKey: Constants.key)
                        
                        if let nc = self.navigationController {
                            nc.popViewController(animated: true)
                        } else {
                            self.dismiss(animated: true, completion: nil)
                        }
                    }
                } else {
                    self.categoryDelegate?.getCategorySettings(name: category, description: description)
                    if let nc = navigationController {
                        nc.popViewController(animated: true)
                    } else {
                        dismiss(animated: true, completion: nil)
                    }
                }
            }
        }
    }
}
