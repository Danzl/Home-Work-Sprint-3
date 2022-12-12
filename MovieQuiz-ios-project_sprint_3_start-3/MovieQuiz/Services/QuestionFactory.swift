//
//  QuestionFactory.swift
//  MovieQuiz
//
//  Created by Danzl Wa on 28.11.2022.
//

import Foundation

class QuestionFactory: QuestionFactoryProtocol {
    
    private var movies: [MostPopularMovie] = []
    private let moviesLoader: MoviesLoading
    weak var delegate: QuestionFactoryDelegate?
    
    init(moviesLoader: MoviesLoading, delegate: QuestionFactoryDelegate?) {
        self.moviesLoader = moviesLoader
        self.delegate = delegate
    }
    
    private enum errorHTTP: Error {
        case errorhttp
    }

    
    func loadData() {
        moviesLoader.loadMovies { result in
            DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    switch result {
                    case .success(let mostPopularMovies):
                        if mostPopularMovies.errorMessage.isEmpty {
                            self.movies = mostPopularMovies.items
                            self.delegate?.didLoadDateFromServer() }
                        else {
                            self.delegate?.didFailToLoadData(with: errorHTTP.errorhttp)
                        }
                    case .failure(let error):
                        self.delegate?.didFailToLoadData(with: error)
                    }
                }
            }
        }
    
    func requestNextQuestion(){
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            let index = (0..<self.movies.count).randomElement() ?? 0
            
            guard let movie = self.movies[safe: index] else { return }
            
            do {
                let imageData = try Data(contentsOf: movie.resizedImageUrl)
                let rating = Float(movie.rating) ?? 0
                let questionRating = Float.random(in: 7.50...9.00)
                let text = "Рейтинг этого фильма больше \(String(format: "%.2f", questionRating))?"
                let correctAnswer = rating > questionRating
                let question = QuizQuestion(image: imageData,
                                            text: text,
                                            correctAnswer: correctAnswer)
                
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.delegate?.didRecieveNextQuestion(question: question)
                }
            } catch {
                self.delegate?.didFailToLoadData(with: error)
                return
            }
        }
    }
}
