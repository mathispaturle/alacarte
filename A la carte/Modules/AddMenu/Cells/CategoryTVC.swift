//
//  CategoryTVC.swift
//  A la carte
//
//  Created by Sopra on 03/03/2021.
//

import UIKit
import Firebase

class CategoryTVC: UITableViewCell, NibReusable {

    private enum Constants {
        static let cornerRadius: CGFloat = 22
        static let shadowRadius: CGFloat = 5.0
        static let shadowOpacity: Float = 0.5
        static let padding: CGFloat = 16.0
    }
    
    @IBOutlet private weak var shadowView: UIView!
    @IBOutlet private weak var container: UIView!
    @IBOutlet private weak var categoryLabel: UILabel!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var dropdown: UIButton!
    @IBOutlet private weak var addButton: UIButton!
    @IBOutlet private weak var moreInfoButton: UIButton!
    
    @IBOutlet private weak var tableViewHeight: NSLayoutConstraint!

    var dishDelegate: AddDishProtocol?
    var dishDelete: DishDelete?
    
    var dishes: [DishForm] = []
    var indexPath: IndexPath = IndexPath()
    var parentId: Int = 0
    private var categoryId: String = ""
    private var menuId: String = ""
    let child = SpinnerViewController()
    private var isCollapsed: Bool = false
    var collapseDelegate: CollapsableCategory?
    var categoryDelegate: CategoryNavigation?
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
        setupTableView()
    }

    private func setupUI() {
        container.layer.cornerRadius = Constants.cornerRadius
        container.clipsToBounds = true
        
        shadowView.layer.shadowColor = UIColor.light.cgColor
        shadowView.layer.shadowOpacity = Constants.shadowOpacity
        shadowView.layer.shadowOffset = .zero
        shadowView.layer.shadowRadius = Constants.shadowRadius
        shadowView.layer.cornerRadius = Constants.cornerRadius
        
        categoryLabel.font = .robotoBold20
        categoryLabel.textColor = .main
        
        dropdown.tintColor = .main
        addButton.tintColor = .main
        moreInfoButton.tintColor = .main
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.tableFooterView = UIView()

        tableView.register(cellType: DishTVC.self)
    }
    
    func configure(menuId: String, categoryId: String, name: String, description: String, dishes: [DishForm], indexPath: IndexPath, isCollapsed: Bool) {
        self.menuId = menuId
        self.categoryId = categoryId
        categoryLabel.text = name
        self.dishes = dishes
        self.indexPath = indexPath
        self.isCollapsed = isCollapsed
        tableView.reloadData()
        updateLayout()
    }
    
    private func deleteDishFromFirebase(categoryId: String, uuid: String) {
        if !menuId.isEmpty && !categoryId.isEmpty && !uuid.isEmpty {
            
            print("Delete item from firebase with id: \(uuid) from categoryID: \(categoryId)")
            let db = Firestore.firestore()
            db.collection(Database.Table.Menu).document(menuId).collection(Database.Table.DishCategory).document(categoryId).collection(Database.Table.Dish).document(uuid).delete() {err in 
                if let err = err {
                    print("Error deleting dish: \(err)")
                    return
                }
            }
        }
    }
    
    private func updateLayout() {
        tableView.setNeedsLayout()
        setNeedsLayout()
        superview?.setNeedsLayout()
        layoutIfNeeded()
        tableView.layoutIfNeeded()
        if isCollapsed {
            tableViewHeight.constant = 0
        } else {
            tableViewHeight.constant = tableView.contentSize.height
        }
    }
    
    @IBAction func moreInformation(_ sender: UIButton) {
        categoryDelegate?.showSelection(indexPath: indexPath, uuid: categoryId)
    }
    
    @IBAction func addNewDish(_ sender: UIButton) {
        let origin = DishOrigin(isNew: true, indexPath: indexPath)
        dishDelegate?.navigateToAddDish(origin: origin)
    }
    
    @IBAction func dropDownState(_ sender: UIButton) {
        isCollapsed = !isCollapsed
        
        if isCollapsed {
            UIView.animate(withDuration: 0.25, animations: {
                self.dropdown.transform = CGAffineTransform(rotationAngle: CGFloat(Float.pi))
            })
        } else {
            UIView.animate(withDuration: 0.25, animations: {
                self.dropdown.transform = CGAffineTransform(rotationAngle: 0)
            })
        }
        
        tableView.reloadSections(IndexSet(integersIn: 0...0), with: .fade)
        collapseDelegate?.updateLayoutCallback(indexPath: indexPath, isCollapsed: isCollapsed)
        updateLayout()
    }
}

extension CategoryTVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isCollapsed {
            return 0
        }
        return dishes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: DishTVC = tableView.dequeueReusableCell(for: indexPath)
        cell.delegate = self
        dishes[indexPath.row].id = indexPath.row
        cell.configure(categoryId: categoryId, id: dishes[indexPath.row].id, name: dishes[indexPath.row].name, price: dishes[indexPath.row].price.description, allergens: [])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

extension CategoryTVC: DishController {
    func deleteDish(id: Int, categoryId: String) {
        
        // TODO: Show dialogue before removing...
        dishDelete?.deleteDish(id: id, parentId: parentId)
        deleteDishFromFirebase(categoryId: categoryId, uuid: dishes[id].uuid)
    }
    
    func editDish(id: Int) {
        if let delegate = dishDelegate {
            let origin = DishOrigin(isNew: false, indexPath: indexPath)
            delegate.navigateToAddDish(origin: origin)
        }
    }
}
