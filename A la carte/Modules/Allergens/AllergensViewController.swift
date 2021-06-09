//
//  AllergensViewController.swift
//  A la carte
//
//  Created by Sopra on 16/03/2021.
//

import UIKit

class AllergensViewController: UIViewController {

    private enum Constants {
        static let spacingRows: CGFloat = 16.0
        static let cornerRadius: CGFloat = 20
        static let shadowRadius: CGFloat = 5.0
        static let shadowOpacity: Float = 0.5
        static let padding: CGFloat = 16.0
        static let key = "isSet"
    }
    
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var titleAllergens: UILabel!
    @IBOutlet private weak var dismissButton: UIButton!
    @IBOutlet private weak var addAllergensButton: UIButton!
    
    var allergensList: [Int] = []
    
    private var allergens: Allergens = Allergens()
    var delegate: AllergensProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
    }
    
    func updateAllergens(list: [Int]) {
        for index in list {
            allergens.allergens[index].isChecked = true
            tableView.reloadData()
        }
    }
    
    func freshUpdateAllergens(list: [Int]) {
        for index in list {
            allergens.allergens[index].isChecked = true
        }
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.tableFooterView = UITableView()
        tableView.register(cellType: AllergenCell.self)
    }
    
    private func setupUI() {
        titleAllergens.font = .robotoBold24
        titleAllergens.text = "ADD ALLERGENS"
        
        addAllergensButton.backgroundColor = .primary
        addAllergensButton.titleLabel?.font = .robotoBold16
        addAllergensButton.setTitle("ADD ALLERGENS", for: .normal)
        addAllergensButton.setTitleColor(.white, for: .normal)
        addAllergensButton.layer.shadowColor = UIColor.light.cgColor
        addAllergensButton.layer.shadowOpacity = Constants.shadowOpacity
        addAllergensButton.layer.shadowOffset = .zero
        addAllergensButton.layer.shadowRadius = Constants.shadowRadius
        addAllergensButton.layer.cornerRadius = Constants.cornerRadius
    }
    
    @IBAction private func dismissView(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func addAllergens(_ sender: UIButton) {
        var list: [Int] = []
        
        for item in allergens.allergens {
            if item.isChecked {
                list.append(item.id)
            }
        }
        delegate?.confirmAllergens(list: list)
        dismiss(animated: true, completion: nil)
    }
    
}

extension AllergensViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allergens.allergens.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: AllergenCell = tableView.dequeueReusableCell(for: indexPath)
        cell.delegate = self
        let allergen = allergens.allergens[indexPath.row]
        cell.configure(id: allergen.id, name: allergen.name, image: allergen.image, isActive: allergen.isChecked)
        return cell
    }
}

extension AllergensViewController: AllergensProtocol {
    func updateState(id: Int, isActive: Bool) {
        allergens.allergens[id].isChecked = isActive
    }
    func confirmAllergens(list: [Int]) {}
}
