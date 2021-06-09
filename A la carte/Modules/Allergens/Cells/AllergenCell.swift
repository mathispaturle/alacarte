//
//  AllergenCell.swift
//  A la carte
//
//  Created by Sopra on 16/03/2021.
//

import UIKit

class AllergenCell: UITableViewCell, NibReusable {

    @IBOutlet private weak var iconImage: UIImageView!
    @IBOutlet private weak var allergenName: UILabel!
    @IBOutlet private weak var activeSwitch: UISwitch!
    private var id: Int = 0
    var delegate: AllergensProtocol?

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    private func setupUI() {
        allergenName.font = .robotoBold16
        allergenName.textColor = .main
        
        activeSwitch.onTintColor = .primary
    }

    func configure(id: Int, name: String, image: String, isActive: Bool) {
        self.id = id
        allergenName.text = name
        iconImage.image = UIImage(named: image)
        activeSwitch.isOn = isActive
    }
    
    @IBAction private func changeSwitch(_ sender: UISwitch) {
        delegate?.updateState(id: id, isActive: activeSwitch.isOn)
    }
}
