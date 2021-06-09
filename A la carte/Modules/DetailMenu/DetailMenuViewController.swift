//
//  DetailMenuViewController.swift
//  A la carte
//
//  Created by Sopra on 10/03/2021.
//

import UIKit
import MapKit
import Firebase

protocol DetailMenuProtocol {
    func updateFirebase()
}

class DetailMenuViewController: UIViewController {

    var menu: Menu?
    
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
    @IBOutlet private weak var deleteButton: UIButton!

    // MARK: Variables
    
    var menuContainer: MenuContainer = MenuContainer()
    var selectedPin: MKPlacemark? = nil
    let child = SpinnerViewController()
    
    // MARK: UI Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        retrieveMenuDetails(completion: { status in
            if status {
                self.setupForm()
            } else {
                self.endSpinner()
            }
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    // MARK: Custom methods

    private func setupUI() {
        
        addButton.backgroundColor = .primary
        addButton.titleLabel?.font = .robotoBold16
        addButton.setTitle("UPDATE MENU", for: .normal)
        addButton.setTitleColor(.white, for: .normal)
        addButton.layer.shadowColor = UIColor.light.cgColor
        addButton.layer.shadowOpacity = Constants.shadowOpacity
        addButton.layer.shadowOffset = .zero
        addButton.layer.shadowRadius = Constants.shadowRadius
        addButton.layer.cornerRadius = Constants.cornerRadius
        
        deleteButton.layer.cornerRadius = Constants.cornerRadius
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.register(cellType: RestTextTVC.self)
        tableView.register(cellType: ControlTVC.self)
        tableView.register(cellType: CategoryTVC.self)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func setupForm() {
        if let menu = menu {
            
            menuContainer.categories.removeAll()
            menuContainer.menuInformation.removeAll()
            
            let form_menu_name = DataFormModel(id: 0, title: "Menu Name".capitalized, placeholder: "Name".uppercased(), fromType: .freeText, value: menu.name)
            let form_menu_description = DataFormModel(id: 1, title: "Menu description".capitalized, placeholder: "Description".uppercased(), fromType: .freeText, value: menu.description)
            
            menuContainer.menuInformation.append(form_menu_name)
            menuContainer.menuInformation.append(form_menu_description)
            menuContainer.categories = menu.categories
            
            tableView.reloadData()
            endSpinner()
        }
    }
    
    private typealias CompletionHandler = (_ success: Bool) -> Void
    
    private func retrieveMenuDetails(completion: @escaping CompletionHandler) {
        showSpinner()
        guard let menu = menu else { return }
        self.menu?.categories.removeAll()
        
        let db = Firestore.firestore()
                
        let categoryRoute = db.collection(Database.Table.Menu).document(menu.uuid).collection(Database.Table.DishCategory)
        categoryRoute.getDocuments { (snapshot, err) in
            if let err = err {
                print("Error getting menu information: \(err.localizedDescription)")
                completion(false)
            }
            
            guard let snapshot = snapshot else { completion(false); return }
            
            let categoryDispatch = DispatchGroup()
            
            for category in snapshot.documents {
                
                categoryDispatch.enter()
                var categoryData = Categories(snapshot: category)
                
                let dishesRoute = categoryRoute.document(category.documentID).collection(Database.Table.Dish)
                dishesRoute.getDocuments { (dishesSnapshot, err) in
                    if let err = err {
                        print("Error getting menu information: \(err.localizedDescription)")
                        completion(false)
                    }
                    
                    guard let dishesSnapshot = dishesSnapshot else { completion(false); return }
                    
                    let dishDispatch = DispatchGroup()
                    
                    for dish in dishesSnapshot.documents {
                        dishDispatch.enter()
                        dishesRoute.document(dish.documentID).getDocument { (dishSnapshot, err) in
                            if let err = err {
                                print("Error getting menu information: \(err.localizedDescription)")
                                completion(false)
                            }
                            guard let dishSnapshot = dishSnapshot else { completion(false); return }

                            //GET THE DATA
                            let dish = DishForm(snapshot: dishSnapshot)
                            categoryData.dishes.append(dish)
                            dishDispatch.leave()
                        }
                    }
                    
                    dishDispatch.notify(queue: .main) {
                        self.menu?.categories.append(categoryData)
                        categoryDispatch.leave()
                    }
                }
            }
            
            categoryDispatch.notify(queue: .main) {
                guard let _ = self.menu else { return }
                if var categories = self.menu?.categories {
                    categories = categories.sorted(by: { $0.id < $1.id })
                    self.menu?.categories = categories
                }
                completion(true)
            }
        }
    }
    
    private func handleFirebaseUpload() {
        self.showSpinner()
        let db = Firestore.firestore()
        guard let menu = menu else { self.endSpinner(); return }
        let menuKeys = Database.MenuKey.self
                        
        let menuDoc = db.collection(Database.Table.Menu).document(menu.uuid)
        menuDoc.setData([
            menuKeys.uuid: menuDoc.documentID,
            menuKeys.name: self.menuContainer.menuInformation[0].value,
            menuKeys.description: self.menuContainer.menuInformation[1].value,
            menuKeys.published: true
        ], merge: true) { err in
            if let err = err {
                print("Error writing document: \(err)")
                return
            }
            
            let dispatcher = DispatchGroup()
            for category in self.menuContainer.categories {
                dispatcher.enter()
                
                var categoryCollection = menuDoc.collection(Database.Table.DishCategory).document()
                
                if !category.uuid.isEmpty {
                    categoryCollection = menuDoc.collection(Database.Table.DishCategory).document(category.uuid)
                }
                
                let categoryKeys = Database.CategoryKey.self
                categoryCollection.setData([
                    categoryKeys.uuid: categoryCollection.documentID,
                    categoryKeys.name: category.name,
                    categoryKeys.description: category.description,
                ], merge: true) { err in
                    if let err = err {
                        print("Error writing document: \(err)")
                        dispatcher.leave()
                        return
                    }
                    
                    let dishDispatcher = DispatchGroup()
                    let dishKey = Database.DishKey.self
                    
                    for dish in category.dishes {
                        dishDispatcher.enter()
                        
                        var dishCollection = categoryCollection.collection(Database.Table.Dish).document()
                        
                        if !dish.uuid.isEmpty {
                            dishCollection = categoryCollection.collection(Database.Table.Dish).document(dish.uuid)
                        }
                        
                        dishCollection.setData([
                            dishKey.uuid: dishCollection.documentID,
                            dishKey.name: dish.name,
                            dishKey.description: dish.description,
                            dishKey.price: dish.price,
                            dishKey.allergens: dish.allergens
                        ], merge: true) { err in
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
                self.dismiss(animated: true, completion: nil)
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
    
    @IBAction func deleteAction(_ sender: UIButton) {
        deleteDocument()
    }
     
    private func deleteDocument() {
        guard let menu = menu else { return }
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        let doc = db.collection(Database.Table.Menu).document(menu.uuid)
        doc.delete { (err) in
            if let err = err {
                print("Error deleting menu: \(err.localizedDescription)")
                return
            }
                    
            db.collection(Database.Table.Users).document(uid).collection(Database.Table.Menu).document(menu.uuid).delete() { _ in
                self.dismiss(animated: true, completion: nil)
            }
        }
//        let alert = UIAlertController(title: "Your title", message: "Your message", preferredStyle: .alert)
//        let ok = UIAlertAction(title: "OK", style: .default, handler: { action in
//            if action.style == .default {
//                db.collection(Database.Table.Menu).document(menu.uuid).delete { (err) in
//                    if let err = err {
//                        print("Error deleting menu: \(err.localizedDescription)")
//                        return
//                    }
//                }
//            }
//        })
//        let cancel = UIAlertAction(title: "Cancel", style: .default, handler: { action in
//        })
//        alert.addAction(ok)
//        alert.addAction(cancel)
//        DispatchQueue.main.async(execute: {
//            self.present(alert, animated: true)
//        })
    }
}

// MARK: TableView

extension DetailMenuViewController: UITableViewDelegate, UITableViewDataSource {
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
        cell.collapseDelegate = self
        cell.dishDelete = self
        cell.parentId = categoryID
        cell.categoryDelegate = self
        let category = menuContainer.categories[categoryID]
        cell.configure(menuId: menu?.uuid ?? "", categoryId: category.uuid, name: category.name, description: category.description, dishes: category.dishes, indexPath: indexPath, isCollapsed: category.isCollapsed)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == menuContainer.menuInformation.count + menuContainer.categories.count {
            self.performSegue(withIdentifier: Segue.addCategory, sender: self)
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
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
            guard let menu = menu else { return }
            let targetController = segue.destination as! SelectionCategoryViewController
            targetController.delegate = self
            targetController.detailMenuDelegate = self
            targetController.menu = menu
            if let origin = sender as? CategoryOrigin {
                targetController.origin = origin
            }
        }
    }
}

extension DetailMenuViewController: DataEntryProtocol {
    func getTextFieldText(id: Int, text: String) {
        menuContainer.menuInformation[id].value = text
    }
    
    func performLocationSegue() {
        //performSegue(withIdentifier: Segue.location, sender: self)
    }
}

extension DetailMenuViewController: CategoryProtocol {
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

extension DetailMenuViewController: AddDishProtocol {
    func navigateToAddDish(origin: DishOrigin) {
        performSegue(withIdentifier: Segue.dishSegue, sender: origin)
    }
}

extension DetailMenuViewController: DishConfirmation {
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

extension DetailMenuViewController: DishDelete {
    func deleteDish(id: Int, parentId: Int) {
        menuContainer.categories[parentId].dishes.remove(at: id)
        tableView.reloadData()
    }
}

extension DetailMenuViewController: CollapsableCategory {
    func updateLayoutCallback(indexPath: IndexPath, isCollapsed: Bool) {
        menuContainer.categories[indexPath.section - menuContainer.menuInformation.count].isCollapsed = isCollapsed
//        tableView.reloadSections(IndexSet(section...section), with: .none)
//        tableView.reloadRows(at: [indexPath], with: .fade)
    }
}

extension DetailMenuViewController: CategoryNavigation {
    func showSelection(indexPath: IndexPath, uuid: String) {
        guard let menuUID = menu?.uuid else { return }
        let category = menuContainer.categories[indexPath.section - menuContainer.menuInformation.count]
        let origin = CategoryOrigin(uuid: uuid, menuUid: menuUID, indexPath: indexPath, name: category.name, description: category.description)
        performSegue(withIdentifier: Segue.categorySelection, sender: origin)
    }
}

extension DetailMenuViewController: SelectionCategoryProtocol {
    func deleteCategory(index: Int) {
        let id = index - menuContainer.menuInformation.count
        menuContainer.categories.remove(at: id)
        tableView.reloadData()
    }
    
    func reloadCategories() {
        menu?.categories.removeAll()
        menuContainer.categories.removeAll()
        retrieveMenuDetails(completion: { status in
            if status {
                self.setupForm()
            } else {
                self.endSpinner()
            }
        })
    }
}

extension DetailMenuViewController: DetailMenuProtocol {
    func updateFirebase() {
        retrieveMenuDetails(completion: { status in
            if status {
                self.setupForm()
            } else {
                self.endSpinner()
            }
        })
    }
}
