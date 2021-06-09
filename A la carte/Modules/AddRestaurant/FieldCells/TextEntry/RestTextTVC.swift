//
//  RestTextTVC.swift
//  A la carte
//
//  Created by Sopra on 01/03/2021.
//

import UIKit

class RestTextTVC: UITableViewCell, NibReusable {

    private enum Constants {
        static let cornerRadius: CGFloat = 5.0
        static let shadowRadius: CGFloat = 5.0
        static let shadowOpacity: Float = 0.5
        static let padding: CGFloat = 16.0
    }
    
    @IBOutlet private weak var shadowView: UIView!
    @IBOutlet private weak var cardView: UIView!
    @IBOutlet private weak var detailInfo: UILabel!
    @IBOutlet private weak var entryTextField: UITextField!
    @IBOutlet private weak var detailBar: UIView!
    
    var textDelegate: DataEntryProtocol?
    var id: Int = 0
    var type: FormType = .freeText
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    private func setupUI() {
        cardView.layer.cornerRadius = Constants.cornerRadius
        shadowView.layer.shadowColor = UIColor.light.cgColor
        shadowView.layer.shadowOpacity = Constants.shadowOpacity
        shadowView.layer.shadowOffset = .zero
        shadowView.layer.shadowRadius = Constants.shadowRadius
        shadowView.layer.cornerRadius = Constants.cornerRadius
        
        detailInfo.font = .robotoBold12
        detailInfo.textColor = .secondMain
        
        entryTextField.font = .robotoBold16
        entryTextField.textColor = .dark
        entryTextField.delegate = self
        
        detailBar.backgroundColor = .primary
    }
    
    func configureCell(id: Int, type: FormType, detailText: String, placeholderText: String, value: String) {
        self.id = id
        self.type = type
        detailInfo.text = detailText
        entryTextField.attributedPlaceholder = NSAttributedString(string: placeholderText, attributes: [NSAttributedString.Key.foregroundColor: UIColor.light, NSAttributedString.Key.font: UIFont.robotoBold14])
        entryTextField.text = value
    }
}

extension RestTextTVC: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let text = textField.text {
            textDelegate?.getTextFieldText(id: id, text: text)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let text = textField.text {
            textDelegate?.getTextFieldText(id: id, text: text)
        }
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if type == .location {
            textDelegate?.performLocationSegue()
            textField.resignFirstResponder()
        }
    }
}
