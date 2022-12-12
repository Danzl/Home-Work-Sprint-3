//
//  AlertProtocol.swift
//  MovieQuiz
//
//  Created by Danzl Wa on 11.12.2022.
//

import UIKit

protocol AlertProtocol {
    func showAlert(quiz result: AlertModel)
}

public struct AlertModel {
    let title: String
    let message: String
    let buttonText: String
    let completion: ((UIAlertAction) -> Void)?
}
