//
//  ReorderViewController.swift
//  A la carte
//
//  Created by Sopra on 24/03/2021.
//

import UIKit
import Firebase

class ReorderViewController: UIViewController {

    var menu: Menu?
    var origin: CategoryOrigin?
    
    private enum Constants {
        static let spacingRows: CGFloat = 16.0
        static let cornerRadius: CGFloat = 20
        static let shadowRadius: CGFloat = 5.0
        static let shadowOpacity: Float = 0.5
        static let padding: CGFloat = 16.0
        static let paddingTableView: CGFloat = 32.0
        static let key = "isSetB"
        static let height: CGFloat = 80
    }
    
    @IBOutlet private weak var reorderLabel: UILabel!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var cancelButton: UIButton!
    @IBOutlet private weak var addButton: UIButton!
    let child = SpinnerViewController()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
    }
    
    private func setupUI() {
        
        reorderLabel.font = .robotoBold24
        reorderLabel.text = "REORDER CATEGORIES"
        
        addButton.backgroundColor = .primary
        addButton.titleLabel?.font = .robotoBold16
        addButton.setTitle("UPDATE MENU", for: .normal)
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
        tableView.isEditing = true
        tableView.reloadData()
    }
    
    private func reorderFirebase() {
        
        guard let menu = menu else { return }
        guard let origin = origin else { return }

        showSpinner()
        let db = Firestore.firestore()
        let menuDoc = db.collection(Database.Table.Menu).document(origin.menuUid).collection(Database.Table.DishCategory)
        
        let dispatcher = DispatchGroup()
        
        var index = 0
        for category in menu.categories {
            dispatcher.enter()
            
            menuDoc.document(category.uuid).setData([
                Database.CategoryKey.id: index
            ], merge: true){_ in
                dispatcher.leave()
            }
            index += 1
        }
        
        
        dispatcher.notify(queue: .main) {
            UserDefaults.standard.setValue(true, forKey: Constants.key)

            self.endSpinner()
            
            if let nc = self.navigationController {
                nc.popViewController(animated: true)
            } else {
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
    
    @IBAction func addAction(_ sender: UIButton) {
        reorderFirebase()
    }
    
    @IBAction func cancelAction(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}

extension ReorderViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menu?.categories.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return createCellView(indexPath: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constants.height
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }

    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        if let item = menu?.categories[sourceIndexPath.row] {
            menu?.categories.remove(at: sourceIndexPath.row)
            menu?.categories.insert(item, at: destinationIndexPath.row)
        }
    }
    
    private func createCellView(indexPath: IndexPath) -> UITableViewCell {
        let category = menu?.categories[indexPath.row]

        let cell = UITableViewCell()
        cell.selectionStyle = .none
        cell.textLabel?.text = category?.name
        cell.textLabel?.font = .robotoBold18
        cell.textLabel?.textColor = .main

        let subtitleLabel = UILabel(forAutoLayout: ())
        subtitleLabel.text = category?.uuid
        subtitleLabel.font = .robotoRegular16
        subtitleLabel.textColor = .secondMain
        cell.addSubview(subtitleLabel)
        
        if let label = cell.textLabel {
            subtitleLabel.autoPinEdge(.top, to: .bottom, of: label, withOffset: -32)
            subtitleLabel.autoPinEdge(.leading, to: .leading, of: cell, withOffset: 20)
        }
        
        return cell
    }
}
