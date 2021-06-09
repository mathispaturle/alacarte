//
//  SelectionCategoryViewController.swift
//  A la carte
//
//  Created by Sopra on 18/03/2021.
//

import UIKit
import Firebase

class SelectionCategoryViewController: UIViewController {

    private enum Constants {
        static let key = "isSetB"
    }
    
    private enum Segues {
        static let editCategory = "showNewCategory"
        static let reorderCategories = "showReorder"
    }
    
    @IBOutlet private weak var dismissView: UIView!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var tableViewHeight: NSLayoutConstraint!
    
    private var selection: [InformationSelection] = []
    let child = SpinnerViewController()
    var delegate: SelectionCategoryProtocol?
    var detailMenuDelegate: DetailMenuProtocol?
    
    var menu: Menu?
    
    var origin: CategoryOrigin? {
        didSet {
            print("Origin: \(origin ?? CategoryOrigin())")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupInformation()
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let data = UserDefaults.standard.bool(forKey: Constants.key)
        
        if data {
            detailMenuDelegate?.updateFirebase()
            UserDefaults.standard.removeObject(forKey: Constants.key)
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.isUserInteractionEnabled = true
        
        tableView.reloadData()
        tableView.layoutIfNeeded()
        tableViewHeight.constant = tableView.contentSize.height
    }

    private func setupInformation() {
        let edit = InformationSelection(name: "Edit category", icon: "square.and.pencil")
        let reorder = InformationSelection(name: "Reorder categories", icon: "list.number")
        let delete = InformationSelection(name: "Delete category", icon: "xmark.bin")
        
        selection.append(edit)
        selection.append(reorder)
        selection.append(delete)
        
        let gestureClose = UITapGestureRecognizer(target: self, action: #selector(closeViewButton(_:)))
        dismissView.isUserInteractionEnabled = true
        dismissView.addGestureRecognizer(gestureClose)
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == Segues.editCategory {
            guard let origin = origin else { return }
            let targetController = segue.destination as! AddCategoryViewController
            targetController.origin = origin
        } else if segue.identifier == Segues.reorderCategories {
            guard let origin = origin else { return }
            guard let menu = menu else { return }
            let targetController = segue.destination as! ReorderViewController
            targetController.origin = origin
            targetController.menu = menu
        }
    }
    
    
    @objc private func closeViewButton(_ sender: UITapGestureRecognizer) {
        dismiss(animated: true, completion: nil)
    }

    private func removeFromDatabase() {
        showSpinner()
        guard let origin = origin else { endSpinner(); return }
        
        if origin.uuid.isEmpty {
            self.delegate?.deleteCategory(index: origin.indexPath.section)
            self.dismiss(animated: true) {
                self.endSpinner()
            }
            return
        }
        
        let db = Firestore.firestore()
        db.collection(Database.Table.Menu).document(origin.menuUid).collection(Database.Table.DishCategory).document(origin.uuid).delete { (err) in
            if let err = err {
                print("Error deleting category: \(err.localizedDescription)")
                self.endSpinner()
                return
            }
            self.dismiss(animated: true) {
                self.delegate?.reloadCategories()
                self.endSpinner()
            }
        }
    }
    
    private func popupDelete() {
        let alert = UIAlertController(title: "Delete Category", message: "Are you sure you want to delete the selected category?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            switch action.style{
            case .default:
                self.removeFromDatabase()
                break
            case .cancel:
                break
            case .destructive:
                break
            @unknown default:
                fatalError()
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
            switch action.style{
            case .default:
                break
            case .cancel:
                break
            case .destructive:
                break
            @unknown default:
                fatalError()
            }
        }))
        self.present(alert, animated: true, completion: nil)
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
    
    private func editCategory() {
        performSegue(withIdentifier: Segues.editCategory, sender: self)
    }
    
    private func reorderCategories() {
        performSegue(withIdentifier: Segues.reorderCategories, sender: self)
    }
}

extension SelectionCategoryViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selection.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.selectionStyle = .none
        cell.textLabel?.text = selection[indexPath.row].name
        cell.textLabel?.font = .robotoBold18
        cell.textLabel?.textColor = .main
        
        cell.imageView?.image = UIImage(systemName: selection[indexPath.row].icon)
        cell.imageView?.tintColor = .primary
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            editCategory()
            break
        case 1:
            reorderCategories()
            break
        case 2:
            popupDelete()
            break
        default:
            break
        }
    }
}

struct InformationSelection {

    let name: String
    let icon: String
    
    init(name: String, icon: String) {
        self.name = name
        self.icon = icon
    }
    
}
