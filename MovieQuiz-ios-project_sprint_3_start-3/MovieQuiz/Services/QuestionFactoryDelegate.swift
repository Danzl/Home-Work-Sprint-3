//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Danzl Wa on 28.11.2022.
//

import Foundation

protocol QuestionFactoryDelegate : AnyObject {
    func didRecieveNextQuestion(question: QuizQuestion?)
    func didLoadDateFromServer()
    func didFailToLoadData(with error: Error)
}
