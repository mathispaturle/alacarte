//
//  Encryptor.swift
//  A la carte
//
//  Created by Sopra on 10/03/2021.
//

import Foundation
import UIKit
import RNCryptor

class Encryptor {
    
    var encryptionKey: String

    static var shared: Encryptor = {
        let instance = Encryptor()
        instance.encryptionKey = try! instance.generateEncryptionKey(withPassword: "123")
        return instance
    }()
    
    private init() { encryptionKey = "" }
    
    func encryptMessage(message: String, encryptionKey: String) throws -> String {
        let messageData = message.data(using: .utf8)!
        let cipherData = RNCryptor.encrypt(data: messageData, withPassword: encryptionKey)
        return cipherData.base64EncodedString()
    }

    func decryptMessage(encryptedMessage: String, encryptionKey: String) throws -> String {

        let encryptedData = Data.init(base64Encoded: encryptedMessage)!
        let decryptedData = try RNCryptor.decrypt(data: encryptedData, withPassword: encryptionKey)
        let decryptedString = String(data: decryptedData, encoding: .utf8)!

        return decryptedString
    }
    
    func generateEncryptionKey(withPassword password: String) throws -> String {
        let randomData = RNCryptor.randomData(ofLength: 32)
        let cipherData = RNCryptor.encrypt(data: randomData, withPassword: password)
        return cipherData.base64EncodedString()
    }
}
