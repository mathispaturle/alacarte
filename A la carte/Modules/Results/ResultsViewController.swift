//
//  ResultsViewController.swift
//  A la carte
//
//  Created by Sopra on 25/03/2021.
//

import UIKit
import Firebase

class ResultsViewController: UIViewController {

    private enum Constants {
        static let rowHeight: CGFloat = 95
        static let spaceCells: CGFloat = 16
    }
    
    private enum Segues {
        static let showSelection = "showSelection"
        static let showUser = "showUser"
        static let showMenu = "showMenu"
        static let showRestaurant = "showRestaurant"
        static let showQRScreen = "showQRScreen"
    }
    
    private enum StoryboardIDs {
        static let detailMenu = "DetailMenu"
    }
    
    var qrQuery = "QldJ3L5geZbrUoOvPx7v8r4tmQH3-FuSqDN3JxyuqQzz9chvX"
    var userID = ""
    var restaurantID = ""
    private var selectedMenu = 0
    
    @IBOutlet private weak var profileButton: UIButton!
    @IBOutlet private weak var titleRestaurant: UILabel!
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var menuCollectionView: UICollectionView!

    // MARK: UI Variables
    
    private var restaurants: [Restaurant] = []
    private var menus: [Menu] = []

    let child = SpinnerViewController()
    var selectedRestaurantId: String = ""
    private var menuCells: [MenuCell?] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCollectionView()
        setupMenuCollectionView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        retrieveFirebaseData()
    }
    
    // MARK: Custom methods

    private func setupUI() {
        titleRestaurant.font = .robotoBold20
        titleRestaurant.text = "Restaurant del mar"
        titleRestaurant.textColor = .main
    }
    
    private func setupData() {
        menuCells = [MenuCell?](repeating: nil, count: menus.count)
    }
    
    private func setupCollectionView() {
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(cellType: MenuCell.self)
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize

        collectionView.collectionViewLayout = layout
    }
    
    private func setupMenuCollectionView() {
        
        menuCollectionView.delegate = self
        menuCollectionView.dataSource = self
        menuCollectionView.register(cellType: MenuDetailCell.self)
        menuCollectionView.isPagingEnabled = true
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width, height: menuCollectionView.frame.height)
        menuCollectionView.collectionViewLayout = layout
    }
    
    @IBAction private func dismissAction(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}


// MARK: Collection View

extension ResultsViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    private enum CollectionViewConstants {
        static let sidePadding: CGFloat = 32
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView != menuCollectionView {
            return menus.count
        }
        return menus.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView != menuCollectionView {
            let cell: MenuCell = collectionView.dequeueReusableCell(for: indexPath)
            menuCells[indexPath.row] = cell
            cell.configure(id: indexPath.row, text: menus[indexPath.row].name, isSelected: indexPath.row == selectedMenu)
            return cell
        }
        
        let cell: MenuDetailCell = collectionView.dequeueReusableCell(for: indexPath)
        cell.configure(categories: menus[indexPath.row].categories)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView != menuCollectionView {
            selectedMenu = indexPath.row
            
            if let rect = self.menuCollectionView.layoutAttributesForItem(at:indexPath)?.frame {
                self.menuCollectionView.scrollRectToVisible(rect, animated: true)
            }

            self.collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
            self.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            
            setSelection()
            return
        }
    }
    
    private func setSelection() {
        for cell in menuCells {
            cell?.setSelected(isSelected: cell?.id == selectedMenu)
        }
    }
}


extension ResultsViewController {
    private func retrieveFirebaseData() {
        
        let arr = qrQuery.components(separatedBy: ["-"])
        userID = String(arr[0])
        restaurantID = String(arr[1])
        
        showSpinner()
        restaurants.removeAll()
        menus.removeAll()
        
        getRestaurants(completionHandler: {_ in
            self.getMenus(completionHandler: {_ in
                self.getPublishedMenusByRestaurant()
            })
        })
    }
    
    private typealias CompletionHandler = (_ success: Bool) -> Void
    
    private func getRestaurants(completionHandler: @escaping CompletionHandler) {
        
        let db = Firestore.firestore()
        let doc = db.collection(Database.Table.Restaurants).document(restaurantID)
        
        doc.getDocument { (querySanpshot, err) in
            if let err = err {
                print("Error getting restaurants: \(err)")
                completionHandler(false)
            }
            
            let restaurant = Restaurant(document: querySanpshot)
            self.restaurants.append(restaurant)
            self.titleRestaurant.text = restaurant.name
            completionHandler(true)
        }
    }
    
    private func getMenus(completionHandler: @escaping CompletionHandler) {
        let db = Firestore.firestore()
        let doc = db.collection(Database.Table.Users).document(userID).collection(Database.Table.Menu)
        doc.getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting restaurants: \(err)")
                completionHandler(false)
            }
            
            let dispatcher = DispatchGroup()
            if let snapshot = querySnapshot?.documents {
                for document in snapshot {
                    dispatcher.enter()
                    // Get detail data of restaurants
                    let path = db.collection(Database.Table.Menu).document(document.documentID)
                    path.getDocument { (snap, err) in
                        if let err = err {
                            print("Error getting restaurant: \(err)")
                            dispatcher.leave()
                        }
                        
                        path.collection(Database.Table.DishCategory).getDocuments { (snapDishes, errDishes) in
                            if let err = errDishes {
                                print("Error getting restaurant: \(err)")
                                dispatcher.leave()
                            }
                            
                            var categories: [Categories] = []
                            
                            let dishDispatcher = DispatchGroup()
                            
                            if let docs = snapDishes?.documents {
                                for documentDishCategory in docs {
                                    dishDispatcher.enter()
                                    
                                    var category = Categories(snapshot: documentDishCategory)
                                    
                                    let newPath = path.collection(Database.Table.DishCategory).document(documentDishCategory.documentID).collection(Database.Table.Dish)
                                    newPath.getDocuments { (snapDish, errDish) in
                                        if let err = errDishes {
                                            print("Error getting restaurant: \(err)")
                                            dishDispatcher.leave()
                                        }
                                        
                                        if let docsDishes = snapDish?.documents {
                                            for documentDish in docsDishes {
                                                let dish = DishForm(snapshot: documentDish)
                                                category.dishes.append(dish)
                                            }
                                        }
                                        
                                        category.dishes.sort(by: { return Double($0.price.replacingOccurrences(of: ",", with: ".")) ?? 0 < Double($1.price.replacingOccurrences(of: ",", with: ".")) ?? 0 })
                                        
                                        categories.append(category)
                                        dishDispatcher.leave()
                                    }
                                }
                            }
                            
                            dishDispatcher.notify(queue: .main) {
                                var menu = Menu(document: snap)
                                categories.sort(by: { return $0.id < $1.id })
                                menu.categories = categories
                                self.menus.append(menu)
                                dispatcher.leave()
                            }
                        }
                    }
                }
                
                dispatcher.notify(queue: .main) {
                    completionHandler(true)
                }
            }
        }
    }
    
    private func getPublishedMenusByRestaurant() {
        let db = Firestore.firestore()
        
        if menus.isEmpty {
            self.endSpinner()
            return
        }
            
        let doc = db.collection(Database.Table.Users).document(userID).collection(Database.Table.Restaurants).document(restaurantID).collection(Database.Table.Menu)
        doc.getDocuments { (snapshot, err) in
            if let err = err {
                print("Error getting restaurants: \(err)")
                self.endSpinner()
                return
            }
            
            if let snap = snapshot {
                for documentMenu in snap.documents {
                    self.setIsPublished(id: documentMenu.documentID, published: (documentMenu.data()[Database.UserRestaurantKey.published] as? Bool) ?? false)
                }
            }
        
            let tmpMenus = self.menus
            self.menus.removeAll()
            
            for menu in tmpMenus {
                if menu.published { self.menus.append(menu)}
            }
            
            self.setupData()

            self.collectionView.reloadData()
            self.menuCollectionView.reloadData()
            self.endSpinner()
        }
    }
    
    private func getUIDForMenu(withID: Int) -> String? {
        if withID < menus.count {
            return menus[withID].uuid
        }
        return nil
    }
    
    private func removeNonPublishedMenus() {
        for i in menus.count - 1...0 {
            if !menus[i].published {
                menus.remove(at: i)
            }
        }
    }
    
    private func setIsPublished(id: String, published: Bool) {
        for index in 0..<menus.count {
            if menus[index].uuid == id {
                menus[index].published = published
                return
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
    
    
}

extension CGFloat {
    static func random() -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
}

extension UIColor {
    static func random() -> UIColor {
        return UIColor(
            red:   .random(),
            green: .random(),
            blue:  .random(),
            alpha: 0.25
        )
    }
}
