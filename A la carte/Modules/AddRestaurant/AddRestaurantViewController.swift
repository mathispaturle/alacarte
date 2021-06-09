//
//  AddRestaurantViewController.swift
//  A la carte
//
//  Created by Sopra on 01/03/2021.
//

import UIKit
import MapKit
import Firebase

class AddRestaurantViewController: UIViewController {

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
    }
    
    // MARK: UIElements
    
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var cancelButton: UIButton!
    @IBOutlet private weak var addButton: UIButton!
    @IBOutlet private weak var titleLabel: UILabel!

    // MARK: Variables
    
    var containerForm: ContainerForm = ContainerForm()
    var selectedPin: MKPlacemark? = nil
    let child = SpinnerViewController()
    
    // MARK: UI Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupForm()
        setupUI()
        setupTableView()
    }
    
    // MARK: Custom methods

    private func setupUI() {
        titleLabel.font = .robotoBold24
        titleLabel.text = "ADD NEW RESTAURANT"
        
        addButton.backgroundColor = .primary
        addButton.titleLabel?.font = .robotoBold16
        addButton.setTitle("ADD RESTAURANT", for: .normal)
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
        tableView.rowHeight = UITableView.automaticDimension
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
            
    }
    
    private func setupForm() {
        let form_rest_name = DataFormModel(id: FormIDs.name.rawValue, title: "Restaurant Name".capitalized, placeholder: "Name".uppercased(), fromType: .freeText)
        let form_rest_email = DataFormModel(id: FormIDs.email.rawValue, title: "Restaurant contact email".capitalized, placeholder: "Contact Email".uppercased(), fromType: .freeText)
        let form_rest_phone = DataFormModel(id: FormIDs.phone.rawValue, title: "Restaurant phone number".capitalized, placeholder: "Phone number".uppercased(), fromType: .freeText)
        let form_rest_website = DataFormModel(id: FormIDs.website.rawValue, title: "Restaurant Website".capitalized, placeholder: "Website".uppercased(), fromType: .freeText)
        let form_rest_instagram = DataFormModel(id: FormIDs.instagram.rawValue, title: "Restaurant Instagram".capitalized, placeholder: "Instagram".uppercased(), fromType: .freeText)
        let form_rest_location = DataFormModel(id: FormIDs.location.rawValue, title: "Restaurant Location".capitalized, placeholder: "Location".uppercased(), fromType: .location)
        
        containerForm.dataForm.append(form_rest_name)
        containerForm.dataForm.append(form_rest_email)
        containerForm.dataForm.append(form_rest_phone)
        containerForm.dataForm.append(form_rest_website)
        containerForm.dataForm.append(form_rest_instagram)
        containerForm.dataForm.append(form_rest_location)

        tableView.reloadData()
    }
    
    private func parseAddress(selectedItem: MKPlacemark) -> String {
        // put a space between "4" and "Melrose Place"
        let firstSpace = (selectedItem.subThoroughfare != nil && selectedItem.thoroughfare != nil) ? " " : ""
        // put a comma between street and city/state
        let comma = (selectedItem.subThoroughfare != nil || selectedItem.thoroughfare != nil) && (selectedItem.subAdministrativeArea != nil || selectedItem.administrativeArea != nil) ? ", " : ""
        // put a space between "Washington" and "DC"
        let secondSpace = (selectedItem.subAdministrativeArea != nil && selectedItem.administrativeArea != nil) ? " " : ""
        let addressLine = String(
            format:"%@%@%@%@%@%@%@",
            // street number
            selectedItem.subThoroughfare ?? "",
            firstSpace,
            // street name
            selectedItem.thoroughfare ?? "",
            comma,
            // city
            selectedItem.locality ?? "",
            secondSpace,
            // state
            selectedItem.administrativeArea ?? ""
        )
        return addressLine
    }
    
    private func handleFirebaseUpload() {
        self.showSpinner()
        guard let uuid = Auth.auth().currentUser?.uid else { self.endSpinner(); return }
        guard let pin = selectedPin else { self.endSpinner(); return }
        let db = Firestore.firestore()
        let keys = Database.RestaurantsKey.self
        let document = db.collection(Database.Table.Restaurants).document()
        let form = containerForm.dataForm
        document.setData([
            keys.uuid: document.documentID,
            keys.email: form[FormIDs.email.rawValue].value,
            keys.name: form[FormIDs.name.rawValue].value,
            keys.locationLongitude: pin.coordinate.longitude,
            keys.locationLatitude: pin.coordinate.latitude,
            keys.locationName: form[FormIDs.location.rawValue].value,
            keys.menus: [],
            keys.phone: form[FormIDs.phone.rawValue].value,
            keys.instagram: form[FormIDs.instagram.rawValue].value
        ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
                return
            }
            db.collection(Database.Table.Users).document(uuid).collection(Database.Table.Restaurants).document(document.documentID).setData([
                Database.UserKey.restaurants: document.documentID
            ]) { err in
                if let err = err {
                print("Error writing document: \(err)")
                return
                }
                self.endSpinner()
                UserDefaults.standard.setValue(true, forKey: Constants.key)
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
}

// MARK: TableView

extension AddRestaurantViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return containerForm.dataForm.count
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
        let cell: RestTextTVC = tableView.dequeueReusableCell(for: indexPath)
        cell.textDelegate = self
        let form = containerForm.dataForm[indexPath.section]
        cell.configureCell(id: form.id, type: form.formType, detailText: form.title, placeholderText: form.placeholder, value: form.value)
        return cell
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
        if segue.identifier == Segue.location {
            let destinationNavigationController = segue.destination as! UINavigationController
            let targetController = destinationNavigationController.topViewController as! LocationViewController
            targetController.delegate = self
        }
    }
}

extension AddRestaurantViewController: DataEntryProtocol {
    func getTextFieldText(id: Int, text: String) {
        containerForm.dataForm[id].value = text
    }
    
    func performLocationSegue() {
        performSegue(withIdentifier: Segue.location, sender: self)
    }
}

extension AddRestaurantViewController: MapViewProtocol {
    func getSelectedLocation(placemark: MKPlacemark) {
        selectedPin = placemark
        containerForm.dataForm[FormIDs.location.rawValue].value = parseAddress(selectedItem: placemark)
        tableView.reloadData()
    }
}
