//
//  QRPreviewViewController.swift
//  A la carte
//
//  Created by Sopra on 10/03/2021.
//

import UIKit
import AlamofireImage

class QRPreviewViewController: UIViewController {

    private enum Constants {
        static let cornerRadius: CGFloat = 22
        static let shadowRadius: CGFloat = 5.0
        static let shadowOpacity: Float = 0.5
        static let padding: CGFloat = 16.0
        static let url = "https://api.qrserver.com/v1/create-qr-code/?size=550x550&color=333333&data="
    }
    
    var qrInformation: String = "" {
        didSet {
            print("QR Information to be passed: \(qrInformation)")
//            if let decr = try? Encryptor.shared.decryptMessage(encryptedMessage: qrInformation, encryptionKey: Encryptor.shared.encryptionKey) {
//                print("Decrypted from QR Information: \(decr)")
//            }
        }
    }
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var locationLabel: UILabel!
    @IBOutlet private weak var codeLabel: UILabel!
    @IBOutlet private weak var qrImage: UIImageView!
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var qrDownload: UIButton!

    var restaurant: Restaurant = Restaurant()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        
        titleLabel.font = .robotoBold24
        titleLabel.textColor = .main
        
        locationLabel.font = .robotoRegular16
        locationLabel.textColor = .secondMain
        
        codeLabel.font = .robotoBold16
        codeLabel.textColor = .white
        codeLabel.backgroundColor = .main
        
        qrDownload.backgroundColor = .primary
        qrDownload.titleLabel?.font = .robotoBold16
        qrDownload.setTitleColor(UIColor.white, for: .normal)
        
        containerView.layer.shadowColor = UIColor.light.cgColor
        containerView.layer.shadowOpacity = Constants.shadowOpacity
        containerView.layer.shadowOffset = .zero
        containerView.layer.shadowRadius = Constants.shadowRadius
        containerView.layer.cornerRadius = Constants.cornerRadius
        
        codeLabel.layer.cornerRadius = Constants.cornerRadius
        qrDownload.layer.cornerRadius = Constants.cornerRadius

        titleLabel.text = restaurant.name
        locationLabel.text = restaurant.locationName
        codeLabel.text = "R-783642"
        qrDownload.setTitle("DOWNLOAD QR", for: .normal)
        handleQRDisplay(info: qrInformation)
    }
    
    private func handleQRDisplay(info: String) {
        
        let path = "\(Constants.url)\(info)"
        if let url = URL(string: path) {
            qrImage.af.setImage(withURL: url)
        }
    }
    
    
    @IBAction func dismissButton(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func downloadQR(_ sender: UIButton) {
        
    }
}
