//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Danzl Wa on 28.11.2022.
//

import UIKit

struct AlertPresenter: AlertProtocol {
    
    private weak var viewController: UIViewController?
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    func showAlert(quiz result: AlertModel) {
        let alert = UIAlertController(title: result.title, message: result.message, preferredStyle: .alert)
        let action = UIAlertAction(title: result.buttonText, style: .default, handler: result.completion)
        
        alert.addAction(action)
        viewController?.present(alert, animated: true, completion: nil)
    }
}
