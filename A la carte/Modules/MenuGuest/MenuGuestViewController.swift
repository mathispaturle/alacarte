//
//  MenuGuestViewController.swift
//  A la carte
//
//  Created by Sopra on 29/03/2021.
//


import UIKit
import MapKit
import Firebase

class MenuGuestViewController: UIViewController {

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
    @IBOutlet private weak var titleLabel: UILabel!


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
        
        addChild(child)
        child.view.frame = view.frame
        view.addSubview(child.view)
        child.didMove(toParent: self)
    }
    
    private func endSpinner() {
        self.view.isUserInteractionEnabled = true
        
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

extension MenuGuestViewController: UITableViewDelegate, UITableViewDataSource {
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
        cell.parentId = categoryID
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
        
    }
}
