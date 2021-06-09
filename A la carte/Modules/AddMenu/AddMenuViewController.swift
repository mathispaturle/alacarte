//
//  AddMenuViewController.swift
//  A la carte
//
//  Created by Sopra on 26/02/2021.
//


import UIKit
import MapKit
import Firebase

class AddMenuViewController: UIViewController {

    private enum Constants {
        static let spacingRows: CGFloat = 16.0
        static let cornerRadius: CGFloat = 20
        static let shadowRadius: CGFloat = 5.0
        static let shadowOpacity: Float = 0.5
        static let padding: CGFloat = 16.0
        static let key = "isSet"
    }
    
    private enum FormIDs: Int {
        case name = 0
        case email
        case phone
        case website
        case instagram
        case location
    }
    
    private enum Segue {
        static let location = "showSelectLocation"
        static let addCategory = "showNewCategory"
        static let dishSegue = "showAddDish"
        static let categorySelection = "showCategorySelection"
    }
    
    // MARK: UIElements
    
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var cancelButton: UIButton!
    @IBOutlet private weak var addButton: UIButton!
    @IBOutlet private weak var titleLabel: UILabel!

    // MARK: Variables
    
    var menuContainer: MenuContainer = MenuContainer()
    var selectedPin: MKPlacemark? = nil
    let child = SpinnerViewController()
    var allergens: [Int] = []
    
    // MARK: UI Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        setupForm()
    }
    
    // MARK: Custom methods

    private func setupUI() {
        titleLabel.font = .robotoBold24
        titleLabel.text = "ADD NEW MENU"
        
        addButton.backgroundColor = .primary
        addButton.titleLabel?.font = .robotoBold16
        addButton.setTitle("ADD MENU", for: .normal)
        addButton.setTitleColor(.white, for: .normal)
        addButton.layer.shadowColor = UIColor.light.cgColor
        addButton.layer.shadowOpacity = Constants.shadowOpacity
        addButton.layer.shadowOffset = .zero
        addButton.layer.shadowRadius = Constants.shadowRadius
        addButton.layer.cornerRadius = Constants.cornerRadius
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.register(cellType: RestTextTVC.self)
        tableView.register(cellType: ControlTVC.self)
        tableView.register(cellType: CategoryTVC.self)
        tableView.rowHeight = UITableView.automaticDimension
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func setupForm() {
        let form_menu_name = DataFormModel(id: 0, title: "Menu Name".capitalized, placeholder: "Name".uppercased(), fromType: .freeText)
        let form_menu_description = DataFormModel(id: 1, title: "Menu description".capitalized, placeholder: "Description".uppercased(), fromType: .freeText)
        
        menuContainer.menuInformation.append(form_menu_name)
        menuContainer.menuInformation.append(form_menu_description)

        tableView.reloadData()
    }
    
    private func handleFirebaseUpload() {
        self.showSpinner()
        let db = Firestore.firestore()
        guard let currentUser = Auth.auth().currentUser?.uid else { self.endSpinner(); return }
        
        let menuKeys = Database.MenuKey.self
        let userMenuDocument = db.collection(Database.Table.Users).document(currentUser).collection(Database.Table.Menu).document()
        
        handleRestaurantMenuLinking(userId: currentUser, menuId: userMenuDocument.documentID)
        
        userMenuDocument.setData([
            menuKeys.uuid: userMenuDocument.documentID
        ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
                return
            }
            
            let menuDoc = db.collection(Database.Table.Menu).document(userMenuDocument.documentID)
            menuDoc.setData([
                menuKeys.uuid: menuDoc.documentID,
                menuKeys.name: self.menuContainer.menuInformation[0].value,
                menuKeys.description: self.menuContainer.menuInformation[1].value,
                menuKeys.published: true
            ]) { err in
                if let err = err {
                    print("Error writing document: \(err)")
                    return
                }
                
                let dispatcher = DispatchGroup()
                for category in self.menuContainer.categories {
                    dispatcher.enter()
                    let categoryCollection = menuDoc.collection(Database.Table.DishCategory).document()
                    let categoryKeys = Database.CategoryKey.self
                    categoryCollection.setData([
                        categoryKeys.uuid: categoryCollection.documentID,
                        categoryKeys.id: category.id,
                        categoryKeys.name: category.name,
                        categoryKeys.description: category.description
                    ]) { err in
                        if let err = err {
                            print("Error writing document: \(err)")
                            dispatcher.leave()
                            return
                        }
                        
                        let dishDispatcher = DispatchGroup()
                        let dishKey = Database.DishKey.self
                        
                        for dish in category.dishes {
                            dishDispatcher.enter()
                            let dishCollection = categoryCollection.collection(Database.Table.Dish).document()
                            dishCollection.setData([
                                dishKey.uuid: dishCollection.documentID,
                                dishKey.name: dish.name,
                                dishKey.description: dish.description,
                                dishKey.price: dish.price,
                                dishKey.allergens: dish.allergens
                            ]) { err in
                                if let err = err {
                                    print("Error writing document: \(err)")
                                    dishDispatcher.leave()
                                    return
                                }
                                dishDispatcher.leave()
                            }
                        }
                        dishDispatcher.notify(queue: .main) {
                            dispatcher.leave()
                        }
                    }
                }
                dispatcher.notify(queue: .main) {
                    self.endSpinner()
                    UserDefaults.standard.setValue(true, forKey: Constants.key)
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    private func handleRestaurantMenuLinking(userId: String, menuId: String) {
        let db = Firestore.firestore()
        let doc = db.collection(Database.Table.Users).document(userId).collection(Database.Table.Restaurants)
        doc.getDocuments { (snapshot, err) in
            if let err = err {
                print("Error getting document: \(err)")
                return
            }
            
            if let snapshot = snapshot {
                let dispatcher = DispatchGroup()
                for document in snapshot.documents {
                    dispatcher.enter()
                    doc.document(document.documentID).collection(Database.Table.Menu).document(menuId).setData([
                        Database.UserRestaurantKey.id: menuId,
                        Database.UserRestaurantKey.published: true
                    ]) { err in
                        if let err = err {
                            print("Error writing document: \(err)")
                            dispatcher.leave()
                            return
                        }
                        dispatcher.leave()
                    }
                }
                dispatcher.notify(queue: .main) {
                    print("Finished setting all published states for menus in restaurants...")
                }
            }
        }
    }
    
    private func showSpinner() {
        self.view.isUserInteractionEnabled = false
        addButton.isUserInteractionEnabled = false
        
        addChild(child)
        child.view.frame = view.frame
        view.addSubview(child.view)
        child.didMove(toParent: self)
    }
    
    private func endSpinner() {
        self.view.isUserInteractionEnabled = true
        addButton.isUserInteractionEnabled = true
        
        child.willMove(toParent: nil)
        child.view.removeFromSuperview()
        child.removeFromParent()
    }
    
    // MARK: Actions

    @IBAction func cancelAction(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addAction(_ sender: UIButton) {
        handleFirebaseUpload()
    }
        
}

// MARK: TableView

extension AddMenuViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return menuContainer.menuInformation.count + 1 + menuContainer.categories.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIView()
        header.backgroundColor = .clear
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return Constants.spacingRows
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section < menuContainer.menuInformation.count {
            let cell: RestTextTVC = tableView.dequeueReusableCell(for: indexPath)
            cell.textDelegate = self
            let form = menuContainer.menuInformation[indexPath.section]
            cell.configureCell(id: form.id, type: form.formType, detailText: form.title, placeholderText: form.placeholder, value: form.value)
            return cell
        } else if indexPath.section == menuContainer.menuInformation.count + menuContainer.categories.count {
            //Control new categories
            let cell: ControlTVC = tableView.dequeueReusableCell(for: indexPath)
            return cell
        }
        
        let categoryID = indexPath.section - menuContainer.menuInformation.count
        
        //Categories
        let cell: CategoryTVC = tableView.dequeueReusableCell(for: indexPath)
        cell.selectionStyle = .none
        cell.dishDelegate = self
        cell.dishDelete = self
        cell.parentId = categoryID
        cell.categoryDelegate = self
        let category = menuContainer.categories[categoryID]
        cell.configure(menuId: "", categoryId: category.uuid, name: category.name, description: category.description, dishes: category.dishes, indexPath: indexPath, isCollapsed: category.isCollapsed)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == menuContainer.menuInformation.count + menuContainer.categories.count {
            self.performSegue(withIdentifier: Segue.addCategory, sender: self)
        }
    }

    @objc private func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height + tableView.rowHeight, right: 0)
        }
    }

    @objc private func keyboardWillHide(notification: NSNotification) {
        tableView.contentInset = .zero
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Segue.addCategory {
            let targetController = segue.destination as! AddCategoryViewController
            targetController.categoryDelegate = self
        } else if segue.identifier == Segue.dishSegue {
            let targetController = segue.destination as! AddDishViewController
            targetController.dishDelegate = self

            if let origin = sender as? DishOrigin {
                
                let parentId = origin.indexPath.section - menuContainer.menuInformation.count
                targetController.categoryID = parentId
                targetController.isNew = origin.isNew

                if !origin.isNew {
                    targetController.dish = menuContainer.categories[parentId].dishes[origin.indexPath.row]
                }
            }
        } else if segue.identifier == Segue.categorySelection {
            let targetController = segue.destination as! SelectionCategoryViewController
            targetController.delegate = self
            if let origin = sender as? CategoryOrigin {
                targetController.origin = origin
            }
        }
    }
}

extension AddMenuViewController: DataEntryProtocol {
    func getTextFieldText(id: Int, text: String) {
        menuContainer.menuInformation[id].value = text
    }
    
    func performLocationSegue() {
        //performSegue(withIdentifier: Segue.location, sender: self)
    }
}

extension AddMenuViewController: CategoryProtocol {
    func getCategorySettings(name: String, description: String) {
        handleNewCategory(name: name, description: description)
    }
    
    private func handleNewCategory(name: String, description: String) {
        let nextID = menuContainer.categories.count
        let category = Categories(id: nextID, name: name, description: description)
        menuContainer.categories.append(category)
        tableView.reloadData()
    }
}

extension AddMenuViewController: AddDishProtocol {
    func navigateToAddDish(origin: DishOrigin) {
        performSegue(withIdentifier: Segue.dishSegue, sender: origin)
    }
}

extension AddMenuViewController: DishConfirmation {
    func addDish(isNew: Bool, categoryID: Int, dishId: Int, name: String, description: String, allergens: [Int], price: String) {
        var dish = DishForm(name: name, description: description, price: price, allergens: allergens)

        if isNew {
            menuContainer.categories[categoryID].dishes.append(dish)
        } else {
            let uuid = menuContainer.categories[categoryID].dishes[dishId].uuid
            dish.uuid = uuid
            menuContainer.categories[categoryID].dishes[dishId] = dish
        }

        tableView.reloadData()
    }
}

extension AddMenuViewController: DishDelete {
    func deleteDish(id: Int, parentId: Int) {
        menuContainer.categories[parentId].dishes.remove(at: id)
        tableView.reloadData()
    }
}

extension AddMenuViewController: CategoryNavigation {
    func showSelection(indexPath: IndexPath, uuid: String) {
        let menuID = menuContainer.categories[indexPath.section - menuContainer.menuInformation.count].uuid
        let category = menuContainer.categories[indexPath.section - menuContainer.menuInformation.count]
        let origin = CategoryOrigin(uuid: uuid, menuUid: menuID, indexPath: indexPath, name: category.name, description: category.description)
        performSegue(withIdentifier: Segue.categorySelection, sender: origin)
    }
}

extension AddMenuViewController: SelectionCategoryProtocol {
    func deleteCategory(index: Int) {
        let id = index - menuContainer.menuInformation.count
        menuContainer.categories.remove(at: id)
        tableView.reloadData()
    }
    
    func reloadCategories() {}
}
