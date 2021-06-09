//
//  LikedGuestViewController.swift
//  A la carte
//
//  Created by Sopra on 27/03/2021.
//

import UIKit
import PureLayout

class LikedGuestViewController: UIViewController {

    private enum Segues {
        static let results = "show_guests"
    }
    
    private enum Constants {
        static let cornerRadius: CGFloat = 22
        static let shadowRadius: CGFloat = 5.0
        static let shadowOpacity: Float = 0.5
        static let padding: CGFloat = 16.0
        static let key: String = "likedKey"
    }
    
    @IBOutlet private weak var dismissButton: UIButton!
    @IBOutlet private weak var tableView: UITableView!
    
    private var names: [String] = []
    var ids: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupWithData()
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.rowHeight = 60
        tableView.separatorInset = .zero
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = .light
    }

    private func setupWithData() {
        let userDefaults = UserDefaults.standard
        ids = userDefaults.object(forKey: Constants.key) as? [String] ?? []

        for id in ids {
            let arr = id.components(separatedBy: ["-"])
            names.append(String(arr[2]))
        }
        
        tableView.reloadData()
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Segues.results {
            let target = segue.destination as! ResultsViewController
            target.qrQuery = sender as! String
        }
    }
    

    @IBAction private func dismissAction(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
}

extension LikedGuestViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if names.isEmpty {
            tableView.backgroundView = createEmptyView()
        } else {
            tableView.backgroundView = nil
        }
        
        return names.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = names[indexPath.row]
        cell.textLabel?.font = .robotoBold18
        cell.textLabel?.textColor = .main
        cell.accessoryType = .disclosureIndicator
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: Segues.results, sender: ids[indexPath.row])
    }
    
    private enum Values {
        static let topMargin: CGFloat = 50
        static let smallTopMargin: CGFloat = 16
    }
    
    private func createEmptyView() -> UIView {
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
        labelDescription.numberOfLines = 0
        labelDescription.textAlignment = .center
        labelDescription.text = "Add restaurants by scanning and liking them"
        emptyView.addSubview(labelDescription)
        
        labelDescription.autoAlignAxis(toSuperviewAxis: .vertical)
        labelDescription.autoPinEdge(.top, to: .bottom, of: label, withOffset: Values.smallTopMargin)
        labelDescription.autoPinEdge(.leading, to: .leading, of: emptyView, withOffset: Values.topMargin)
        labelDescription.autoPinEdge(.trailing, to: .trailing, of: emptyView, withOffset: -Values.topMargin)

        return emptyView
    }
}


