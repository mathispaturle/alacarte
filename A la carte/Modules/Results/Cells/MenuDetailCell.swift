//
//  MenuDetailCell.swift
//  A la carte
//
//  Created by Mathis Paturle on 6/6/21.
//

import UIKit

class MenuDetailCell: UICollectionViewCell, NibReusable {

    @IBOutlet private weak var tableView: UITableView!
    
    private var categories: [Categories] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupTableView()
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
    }

    func configure(categories: [Categories]) {
        self.categories = categories
        
        if categories.isEmpty {
            tableView.backgroundView = EmptyBackgroundView(image: UIImage(named: "menu-1") ?? UIImage(), top: "This menu is empty", bottom: "Try again later")
        } else {
            tableView.backgroundView = nil
        }
        
        tableView.reloadData()
    }
}

extension MenuDetailCell: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Header section name"
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIView()
        header.backgroundColor = .white
        
        let title = UILabel(forAutoLayout: ())
        title.text = categories[section].name
        title.font = .robotoBold18
        title.textColor = .main
        header.addSubview(title)
        
        let separator = UIView(forAutoLayout: ())
        separator.backgroundColor = .systemGray6
        header.addSubview(separator)
        
        title.autoPinEdge(.left, to: .left, of: header, withOffset: 32)
        title.autoAlignAxis(.horizontal, toSameAxisOf: header, withOffset: 16)
        title.autoPinEdge(.right, to: .right, of: header, withOffset: -32)

        separator.autoPinEdge(.left, to: .left, of: header, withOffset: 32)
        separator.autoPinEdge(.right, to: .right, of: header, withOffset: -32)
        separator.autoPinEdge(.bottom, to: .bottom, of: header, withOffset: -1)
        separator.autoSetDimension(.height, toSize: 1)

        return header
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories[section].dishes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let dish = categories[indexPath.section].dishes[indexPath.row]
        
        let cell = UITableViewCell()
        cell.selectionStyle = .none
        
        let dishName = UILabel(forAutoLayout: ())
        dishName.font = .robotoRegular16
        dishName.textColor = .main
        dishName.numberOfLines = 0
        dishName.text = dish.name.capitalizingFirstLetter()
        
        let dishPrice = UILabel(forAutoLayout: ())
        dishPrice.font = .robotoRegular16
        dishPrice.textColor = .secondMain
        dishPrice.text = "\(dish.price)€"
        dishPrice.textAlignment = .right
        
        cell.addSubview(dishName)
        cell.addSubview(dishPrice)
        
        dishName.autoPinEdge(.left, to: .left, of: cell, withOffset: 32)
        dishName.autoPinEdge(.right, to: .left, of: dishPrice, withOffset: -64)
        dishName.autoPinEdge(.top, to: .top, of: cell, withOffset: 16)
        dishName.autoPinEdge(.bottom, to: .bottom, of: cell, withOffset: -16)

        dishPrice.autoPinEdge(.right, to: .right, of: cell, withOffset: -32)
        dishPrice.autoAlignAxis(.firstBaseline, toSameAxisOf: dishName)
        
        return cell
    }
    
    
}
