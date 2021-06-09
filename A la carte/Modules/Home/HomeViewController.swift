//
//  HomeViewController.swift
//  A la carte
//
//  Created by Sopra on 25/02/2021.
//

import UIKit
import Firebase
import PureLayout

class HomeViewController: UIViewController {
    
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
    
    // MARK: UI Elements
    
    @IBOutlet private weak var profileButton: UIButton!
    @IBOutlet private weak var addMenuButton: UIButton!
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var restaurantPageControl: UIPageControl!
    @IBOutlet private weak var collectionViewHeight: NSLayoutConstraint!

    
    // MARK: UI Variables
    
    private var restaurants: [Restaurant] = []
    private var menus: [Menu] = []

    let child = SpinnerViewController()
    var selectedRestaurantId: String = ""
    
    // MARK: View lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCollectionView()
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        retrieveFirebaseData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = false
    }
    
    // MARK: Custom methods

    private func setupUI() {
        addMenuButton.backgroundColor = .primary
        addMenuButton.layer.cornerRadius = addMenuButton.frame.height / 2
    }
    
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(cellType: RestaurantDetailCVC.self)
        
        let screenWidth = UIScreen.main.bounds.width
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal

        layout.sectionInset = UIEdgeInsets(top: 0, left: CollectionViewConstants.sidePadding, bottom: 0, right: CollectionViewConstants.sidePadding)

        layout.minimumInteritemSpacing = 2 * CollectionViewConstants.sidePadding
        layout.minimumLineSpacing = 2 * CollectionViewConstants.sidePadding

        let width = screenWidth - ( 2 * CollectionViewConstants.sidePadding)
        let height = collectionViewHeight.constant
        
        layout.itemSize = CGSize(width: width, height: height)
        
        collectionView.collectionViewLayout = layout
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(cellType: MenuTVC.self)
        tableView.tableFooterView = UIView()
    }
    
    // MARK: Actions

    @IBAction func showSelection(_ sender: UIButton) {
        performSegue(withIdentifier: Segues.showSelection, sender: self)
    }
    
    @IBAction func showUser(_ sender: UIButton) {
//        performSegue(withIdentifier: Segues.showUser, sender: self)
//        self.viewDidAppear(true)
        try? Auth.auth().signOut()
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Segues.showSelection {
            let targetController = segue.destination as! SelectionViewController
            targetController.delegate = self
        } else if segue.identifier == Segues.showMenu {
            if let indexPath = sender as? IndexPath {
                let targetController = segue.destination as! DetailMenuViewController
                targetController.menu = menus[indexPath.section]
                targetController.title = targetController.menu?.name
            }
        } else if segue.identifier == Segues.showQRScreen {
            if let qrInformation = sender as? String {
                let targetController = segue.destination as! QRPreviewViewController
                targetController.restaurant = restaurants[restaurantPageControl.currentPage]
                targetController.qrInformation = qrInformation
            }
        }
    }
}

// MARK: Collection View

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    private enum CollectionViewConstants {
        static let sidePadding: CGFloat = 32
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if restaurants.isEmpty {
            collectionView.backgroundView = createEmptyCollectionView()
        } else {
            collectionView.backgroundView = nil
        }
        
        return restaurants.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: RestaurantDetailCVC = collectionView.dequeueReusableCell(for: indexPath)
        let restaurant = restaurants[indexPath.row]
        cell.homeDelegate = self
        cell.configure(id: restaurant.uuid, title: restaurant.name, subtitle: restaurant.locationName, longitude: restaurant.locationLongitude, latitude: restaurant.locationLatitude)
        return cell
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        for cell in collectionView.visibleCells {
            if let row = collectionView.indexPath(for: cell)?.row {
                restaurantPageControl.currentPage = row
                getPublishedMenusByRestaurant()
            }
        }
    }
}

// MARK: Table View

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        
        if menus.isEmpty {
            tableView.backgroundView = createEmptyTableView()
        } else {
            tableView.backgroundView = nil
        }
        
        return menus.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return Constants.spaceCells
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIView()
        header.backgroundColor = .clear
        return header
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if menus.isEmpty { return 0 }
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: MenuTVC = tableView.dequeueReusableCell(for: indexPath)
        let menu = menus[indexPath.section]
        cell.homeDelegate = self
        cell.configure(id: indexPath.section, title: menu.name, description: menu.description, published: menu.published)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constants.rowHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: Segues.showMenu, sender: indexPath)
    }
}

// MARK: Firebase methods

extension HomeViewController {
    private func retrieveFirebaseData() {
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
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        let doc = db.collection(Database.Table.Users).document(uid).collection(Database.Table.Restaurants)
        doc.getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting restaurants: \(err)")
                completionHandler(false)
            }
            
            let dispatcher = DispatchGroup()
            if let snapshot = querySnapshot?.documents {
                self.restaurantPageControl.numberOfPages = snapshot.count
                for document in snapshot {
                    dispatcher.enter()
                    // Get detail data of restaurants
                    db.collection(Database.Table.Restaurants).document(document.documentID).getDocument { (snap, err) in
                        if let err = err {
                            print("Error getting restaurant: \(err)")
                            dispatcher.leave()
                        }
                        let restaurant = Restaurant(document: snap)
                        self.restaurants.append(restaurant)
                        dispatcher.leave()
                    }
                }
                
                dispatcher.notify(queue: .main) {
                    self.collectionView.reloadData()
                    completionHandler(true)
                }
            }
        }
    }
    
    private func getMenus(completionHandler: @escaping CompletionHandler) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        let doc = db.collection(Database.Table.Users).document(uid).collection(Database.Table.Menu) 
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
                    db.collection(Database.Table.Menu).document(document.documentID).getDocument { (snap, err) in
                        if let err = err {
                            print("Error getting restaurant: \(err)")
                            dispatcher.leave()
                        }
                        let menu = Menu(document: snap)
                        self.menus.append(menu)
                        dispatcher.leave()
                    }
                }
                
                dispatcher.notify(queue: .main) {
                    completionHandler(true)
                }
            }
        }
    }
    
    private func getPublishedMenusByRestaurant() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        
        if menus.isEmpty {
            self.endSpinner()
            return
        }
        
        selectedRestaurantId = restaurants[restaurantPageControl.currentPage].uuid
    
        let doc = db.collection(Database.Table.Users).document(uid).collection(Database.Table.Restaurants).document(selectedRestaurantId).collection(Database.Table.Menu)
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
            self.tableView.reloadData()
            self.endSpinner()
        }
    }
    
    private func setPublishedStateForMenuInRestaurant(id: Int, isPublished: Bool) {
        self.showSpinner()
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        
        if let id = getUIDForMenu(withID: id) {
            let doc = db.collection(Database.Table.Users).document(uid).collection(Database.Table.Restaurants).document(selectedRestaurantId).collection(Database.Table.Menu).document(id)
            doc.setData([
                Database.UserRestaurantKey.published: isPublished
            ], merge: true) { err in
                if let err = err {
                    print("Error updating published state: \(err)")
                }
                self.endSpinner()
            }
        }
    }
    
    private func getUIDForMenu(withID: Int) -> String? {
        if withID < menus.count {
            return menus[withID].uuid
        }
        return nil
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

extension HomeViewController: HomeCallback {
    func getUpdatedElements() {
        retrieveFirebaseData()
    }
    
    func updatePublishedState(id: Int, isPublished: Bool) {
        setPublishedStateForMenuInRestaurant(id: id, isPublished: isPublished)
    }
    
    func presentQRScreenEncrypted(withID: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let rawInformation = "\(uid)-\(withID)"
        performSegue(withIdentifier: Segues.showQRScreen, sender: rawInformation)
//        if let enc = try? Encryptor.shared.encryptMessage(message: rawInformation, encryptionKey: Encryptor.shared.encryptionKey) {
//            performSegue(withIdentifier: Segues.showQRScreen, sender: enc)
//        }
    }
}

extension HomeViewController {
    private enum Values {
        static let topMargin: CGFloat = 50
        static let smallTopMargin: CGFloat = 16
    }
    
    private func createEmptyTableView() -> UIView {
        let emptyView = UIView()
        
        let label = UILabel(forAutoLayout: ())
        label.font = .robotoBold18
        label.textColor = .main
        label.text = "No menus available"
        emptyView.addSubview(label)
        
        label.autoAlignAxis(toSuperviewAxis: .vertical)
        label.autoPinEdge(.top, to: .top, of: emptyView, withOffset: Values.topMargin)
        
        let labelDescription = UILabel(forAutoLayout: ())
        labelDescription.font = .robotoRegular16
        labelDescription.textColor = .secondMain
        labelDescription.text = "Add menus by clicking the '+' button"
        emptyView.addSubview(labelDescription)
        
        labelDescription.autoAlignAxis(toSuperviewAxis: .vertical)
        labelDescription.autoPinEdge(.top, to: .bottom, of: label, withOffset: Values.smallTopMargin)
        
        return emptyView
    }
    
    private func createEmptyCollectionView() -> UIView {
        let emptyView = UIView()
        
        let label = UILabel(forAutoLayout: ())
        label.font = .robotoBold18
        label.textColor = .main
        label.text = "No restaurants available"
        emptyView.addSubview(label)
        
        label.autoAlignAxis(toSuperviewAxis: .vertical)
        label.autoPinEdge(.top, to: .top, of: emptyView, withOffset: Values.topMargin)
        
        let labelDescription = UILabel(forAutoLayout: ())
        labelDescription.font = .robotoRegular16
        labelDescription.textColor = .secondMain
        labelDescription.text = "Add restaurants by clicking the '+' button"
        emptyView.addSubview(labelDescription)
        
        labelDescription.autoAlignAxis(toSuperviewAxis: .vertical)
        labelDescription.autoPinEdge(.top, to: .bottom, of: label, withOffset: Values.smallTopMargin)
        
        return emptyView
    }
}
