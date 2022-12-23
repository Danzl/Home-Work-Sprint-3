//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Danzl Wa on 28.11.2022.
//

import UIKit

protocol AlertPresenterProtocol  {
    func showAlert(alertModel: AlertModel)
}

extension AlertPresenterProtocol where Self: UIViewController {
    func showAlert(alertModel: AlertModel) {
        let alert = UIAlertController(title: alertModel.title,
                                      message: alertModel.message,
                                      preferredStyle: .alert)
        alert.view.accessibilityIdentifier = "Game results"
        let repeatAction = UIAlertAction(title: alertModel.buttonText, style: .default, handler: { _ in
            alertModel.completion()
        })
        alert.addAction(repeatAction)
        self.present(alert, animated: true, completion: nil)
    }
}
