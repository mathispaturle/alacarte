//
//  DataFormModel.swift
//  A la carte
//
//  Created by Sopra on 01/03/2021.
//

import Foundation

struct ContainerForm {
    var dataForm: [DataFormModel]
    
    init() {
        self.dataForm = []
    }
    
    init(dataForm: [DataFormModel]) {
        self.dataForm = dataForm
    }
}

struct DataFormModel {
    
    let id: Int
    let title: String
    let placeholder: String
    let formType: FormType
    var value: String
    
    internal init(id: Int, title: String, placeholder: String, fromType: FormType, value: String = "") {
        self.id = id
        self.title = title
        self.placeholder = placeholder
        self.formType = fromType
        self.value = value
    }
}

enum FormType {
    case freeText
    case location
    case price
}
