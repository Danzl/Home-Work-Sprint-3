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
    private let networkClient: NetworkRouting
    
    init(networkClient: NetworkRouting = NetworkClient()) {
        self.networkClient = networkClient
    }
    
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
                let mostPopularMovieList = try? JSONDecoder().decode(MostPopularMovies.self, from: data)
                if let mostPopularMovieList = mostPopularMovieList {
                    handler(.success(mostPopularMovieList)) } else {
                        handler(.failure(DecoderError.errorMessage))
                    }
            case .failure(let error):
                handler(.failure(error))
            }
        }
    }

    
    private enum DecoderError: Error {
        case errorMessage
    }
}
