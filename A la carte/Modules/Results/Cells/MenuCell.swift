//
//  MenuCell.swift
//  A la carte
//
//  Created by Mathis Paturle on 5/6/21.
//

import UIKit

class MenuCell: UICollectionViewCell, NibReusable {

    var id = 0
    @IBOutlet private weak var name: UILabel!
    @IBOutlet private weak var bar: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    private func setupUI() {
        name.font = .robotoBold16
        name.textColor = .main
    }

    func configure(id: Int, text: String, isSelected: Bool) {
        self.id = id
        bar.backgroundColor = isSelected ? .primary : .clear
        name.text = text.capitalizingFirstLetter()
    }
    
    func setSelected(isSelected: Bool) {
        bar.backgroundColor = isSelected ? .primary : .clear
    }
}
