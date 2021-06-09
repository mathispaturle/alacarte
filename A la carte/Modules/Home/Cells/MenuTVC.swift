//
//  MenuTVC.swift
//  A la carte
//
//  Created by Sopra on 25/02/2021.
//

import UIKit

class MenuTVC: UITableViewCell, NibReusable {

    private enum Constants {
        static let cornerRadius: CGFloat = 22
        static let shadowRadius: CGFloat = 5.0
        static let shadowOpacity: Float = 0.5
        static let padding: CGFloat = 16.0
    }
    
    // MARK: Variables

    @IBOutlet private weak var shadowView: UIView!
    @IBOutlet private weak var cardView: UIView!
    @IBOutlet private weak var menuTitle: UILabel!
    @IBOutlet private weak var menuSubtitle: UILabel!
    @IBOutlet private weak var menuPublished: UISwitch!
    
    var homeDelegate: HomeCallback?
    private var id: Int = 0
    
    // MARK: View lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    // MARK: Custom methods
    
    private func setupUI() {
        
        cardView.layer.cornerRadius = Constants.cornerRadius
        shadowView.layer.shadowColor = UIColor.light.cgColor
        shadowView.layer.shadowOpacity = Constants.shadowOpacity
        shadowView.layer.shadowOffset = .zero
        shadowView.layer.shadowRadius = Constants.shadowRadius
        shadowView.layer.cornerRadius = Constants.cornerRadius
        
        menuTitle.font = .robotoBold18
        menuTitle.textColor = .main
        
        menuSubtitle.font = .robotoRegular14
        menuSubtitle.textColor = .lightGray

        menuPublished.onTintColor = .primary
    }
    
    func configure(id: Int, title: String, description: String, published: Bool, isGuest: Bool = false) {
        self.id = id
        menuTitle.text = title
        menuSubtitle.text = description
        
        menuPublished.isOn = published
        menuPublished.isHidden = isGuest
        
        if isGuest {
            let image = UIImageView(forAutoLayout: ())
            contentView.addSubview(image)
            
            image.image = UIImage(systemName: "chevron.right")
            image.autoPinEdge(.trailing, to: .trailing, of: contentView, withOffset: -64)
            image.autoSetDimensions(to: CGSize(width: 16, height: 22))
            image.autoAlignAxis(.horizontal, toSameAxisOf: contentView)
        }
        
    }
    
    // MARK: - Actions
    @IBAction func didToggleSwitch(_ sender: UISwitch) {
        homeDelegate?.updatePublishedState(id: id, isPublished: menuPublished.isOn)
    }
}


