//
//  MoviesLoader.swift
//  MovieQuiz
//
//  Created by Danzl Wa on 11.12.2022.
//

import Foundation

protocol MoviesLoading {
    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void)
}

struct MoviesLoader: MoviesLoading {
    private let networkClient = NetworkClient()
    private var mostPopularMoviesUrl: URL {
        guard let url = URL(string: "https://imdb-api.com/en/API/Top250Movies/k_q8w9sd9g") else {
            preconditionFailure("Unable to construct mostPopularMoviesUrl")
        }
        return url
    }
    
    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void) {
        networkClient.fetch(url: mostPopularMoviesUrl) { result in
            switch result {
            case .success(let data):
                do {
                    let json = try JSONDecoder().decode(MostPopularMovies.self, from: data)
                    
                    if json.errorMessage.isEmpty && !json.items.isEmpty {
                        handler(.success(json))
                    } else {
                        handler(.failure(DecoderError.errorMessage(json.errorMessage)))
                    }
                } catch {
                    handler(.failure(error))
                }
            case .failure(let error):
                handler(.failure(error))
            }
        }
    }
    
    private enum DecoderError: Error {
        case errorMessage(String)
    }
}
