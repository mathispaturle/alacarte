//
//  DishTVC.swift
//  A la carte
//
//  Created by Sopra on 05/03/2021.
//

import UIKit

class DishTVC: UITableViewCell, NibReusable {

    @IBOutlet private weak var dishName: UILabel!
    @IBOutlet private weak var dishPrice: UILabel!
    @IBOutlet private weak var dishAllergens: UIButton!
    @IBOutlet private weak var dishEdit: UIButton!
    @IBOutlet private weak var dishDelete: UIButton!

    var delegate: DishController?
    private var id: Int = 0
    private var categoryId: String = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    private func setupUI() {
        dishName.font = .robotoRegular16
        dishName.textColor = .secondMain
        
        dishPrice.font = .robotoRegular16
        dishPrice.textColor = .secondMain
        
        dishEdit.tintColor = .secondMain
        dishDelete.tintColor = .secondMain
        dishAllergens.tintColor = .secondMain
    }
    
    func configure(categoryId: String, id: Int, name: String, price: String, allergens: [Int]) {
        self.id = id
        self.categoryId = categoryId
        dishName.text = name
        dishPrice.text = "\(price)€"
        
        dishAllergens.isHidden = allergens.isEmpty
    }
    
    @IBAction func editPressed(_ sender: UIButton) {
        delegate?.editDish(id: id)
    }
    
    @IBAction func deletePressed(_ sender: UIButton) {
        delegate?.deleteDish(id: id, categoryId: categoryId)
    }
}
