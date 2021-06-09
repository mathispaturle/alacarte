//
//  AddDishViewController.swift
//  A la carte
//
//  Created by Sopra on 03/03/2021.
//

import UIKit
import Firebase
import PureLayout

class AddDishViewController: UIViewController {

    private enum Segues {
        static let allergens = "showAllergens"
    }
    
    private enum Constants {
        static let spacingRows: CGFloat = 16.0
        static let cornerRadius: CGFloat = 20
        static let shadowRadius: CGFloat = 5.0
        static let shadowOpacity: Float = 0.5
        static let padding: CGFloat = 16.0
        static let key = "isSet"
    }
    
    @IBOutlet private weak var cancelButton: UIButton!
    @IBOutlet private weak var addButton: UIButton!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var dishLabel: UITextField!
    @IBOutlet private weak var descriptionField: UITextField!
    @IBOutlet private weak var allergensField: UIButton!
    @IBOutlet private weak var priceField: UITextField!

    var dishDelegate: DishConfirmation?
    var categoryID: Int = 0
    
    var allergensList: [Int] = []
    var dish: DishForm?
    var isNew: Bool = true
    private var id: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTextFields()
        setupTexts()
    }
    
    private func setupUI() {
        titleLabel.font = .robotoBold24
        titleLabel.text = "ADD NEW DISH"
        
        addButton.backgroundColor = .primary
        addButton.titleLabel?.font = .robotoBold16
        addButton.setTitle("ADD DISH", for: .normal)
        addButton.setTitleColor(.white, for: .normal)
        addButton.layer.shadowColor = UIColor.light.cgColor
        addButton.layer.shadowOpacity = Constants.shadowOpacity
        addButton.layer.shadowOffset = .zero
        addButton.layer.shadowRadius = Constants.shadowRadius
        addButton.layer.cornerRadius = Constants.cornerRadius
    }
    
    private func setupTextFields() {
        dishLabel.layer.cornerRadius = Constants.cornerRadius
        dishLabel.backgroundColor = .white
        dishLabel.layer.shadowColor = UIColor.light.cgColor
        dishLabel.layer.shadowOpacity = Constants.shadowOpacity
        dishLabel.layer.shadowOffset = .zero
        dishLabel.layer.shadowRadius = Constants.shadowRadius
        dishLabel.setLeftPaddingPoints(Constants.padding)
        dishLabel.font = .robotoBold16
        dishLabel.textColor = .dark
        dishLabel.attributedPlaceholder = NSAttributedString(string: "DISH NAME", attributes: [NSAttributedString.Key.foregroundColor: UIColor.light, NSAttributedString.Key.font: UIFont.robotoBold14])

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
        
        priceField.layer.cornerRadius = Constants.cornerRadius
        priceField.backgroundColor = .white
        priceField.layer.shadowColor = UIColor.light.cgColor
        priceField.layer.shadowOpacity = Constants.shadowOpacity
        priceField.layer.shadowOffset = .zero
        priceField.layer.shadowRadius = Constants.shadowRadius
        priceField.setLeftPaddingPoints(Constants.padding)
        priceField.font = .robotoBold16
        priceField.textColor = .dark
        priceField.attributedPlaceholder = NSAttributedString(string: "PRICE", attributes: [NSAttributedString.Key.foregroundColor: UIColor.light, NSAttributedString.Key.font: UIFont.robotoBold14])
        
        let prefixView = UIView()
        let prefix = UILabel(forAutoLayout: ())
        prefix.text = "€"
        prefix.sizeToFit()
        prefix.font = .robotoBold16
        prefix.textColor = .secondMain
        prefixView.addSubview(prefix)
        prefix.autoSetDimensions(to: CGSize(width: 22, height: 22))
        prefix.autoPinEdge(.leading, to: .leading, of: prefixView, withOffset: 16)
        prefix.autoPinEdge(.trailing, to: .trailing, of: prefixView, withOffset: -16)
        prefix.autoPinEdge(.top, to: .top, of: prefixView)
        prefix.autoPinEdge(.bottom, to: .bottom, of: prefixView)
        prefixView.sizeToFit()

        priceField.leftView = prefixView
        priceField.leftViewMode = .always
        
        allergensField.layer.cornerRadius = Constants.cornerRadius
        allergensField.backgroundColor = .white
        allergensField.layer.shadowColor = UIColor.light.cgColor
        allergensField.layer.shadowOpacity = Constants.shadowOpacity
        allergensField.layer.shadowOffset = .zero
        allergensField.layer.shadowRadius = Constants.shadowRadius
        allergensField.setTitle("ALLERGENS", for: .normal)
        allergensField.setTitleColor(.light, for: .normal)
        
        allergensField.titleLabel?.font = .robotoBold16
        allergensField.titleLabel?.textColor = .light
    }
    
    private func setupTexts() {
        guard let dish = dish else { return }
        self.id = dish.id
        addButton.setTitle("EDIT DISH", for: .normal)
        dishLabel.text = dish.name
        descriptionField.text = dish.description
        priceField.text = dish.price
        
        allergensList.removeAll()
        var additionalText = ""

        for item in dish.allergens {
            allergensList.append(item)
            additionalText = "\(additionalText) - \(item)"
        }
        
        allergensField.setTitle("ALLERGENS\(additionalText)", for: .normal)       
        
    }
    
    @IBAction func cancelAction(_ sender: UIButton) {
        if let nc = navigationController {
            nc.popViewController(animated: true)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func addAction(_ sender: UIButton) {
        if let dishName = dishLabel.text, let description = descriptionField.text, let price = priceField.text {
            if !dishName.isEmpty && !price.isEmpty {
                dishDelegate?.addDish(isNew: isNew, categoryID: categoryID, dishId: id, name: dishName, description: description, allergens: allergensList, price: price)
                if let nc = navigationController {
                    nc.popViewController(animated: true)
                } else {
                    dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    @IBAction func showAllergens(_ sender: UIButton) {
        performSegue(withIdentifier: Segues.allergens, sender: allergensList)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Segues.allergens {
            let targetController = segue.destination as! AllergensViewController
            targetController.delegate = self
            targetController.freshUpdateAllergens(list: allergensList)
        }
    }
}

extension AddDishViewController: AllergensProtocol {
    func updateState(id: Int, isActive: Bool) {}
    
    func confirmAllergens(list: [Int]) {
        allergensList.removeAll()
        var additionalText = ""

        for item in list {
            allergensList.append(item)
            additionalText = "\(additionalText) - \(item)"
        }
        
        allergensField.setTitle("ALLERGENS\(additionalText)", for: .normal)
    }
}

