//
//  ControlTVC.swift
//  A la carte
//
//  Created by Sopra on 03/03/2021.
//

import UIKit

class ControlTVC: UITableViewCell, NibReusable {

    private enum Constants {
        static let cornerRadius: CGFloat = 22
        static let shadowRadius: CGFloat = 5.0
        static let shadowOpacity: Float = 0.5
        static let padding: CGFloat = 16.0
    }
    
    @IBOutlet private weak var shadowView: UIView!
    @IBOutlet private weak var cardView: UIView!
    @IBOutlet private weak var titleCategory: UILabel!
    @IBOutlet private weak var imageCategory: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    private func setupUI() {
        cardView.layer.cornerRadius = Constants.cornerRadius
        cardView.clipsToBounds = true
        cardView.layer.borderWidth = 1
        cardView.layer.borderColor = UIColor.primary.cgColor
        
        shadowView.layer.shadowColor = UIColor.light.cgColor
        shadowView.layer.shadowOpacity = Constants.shadowOpacity
        shadowView.layer.shadowOffset = .zero
        shadowView.layer.shadowRadius = Constants.shadowRadius
        shadowView.layer.cornerRadius = Constants.cornerRadius
        
        titleCategory.font = .robotoBold16
        imageCategory.tintColor = .primary
    }
    
}
