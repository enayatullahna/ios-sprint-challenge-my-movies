//
//  MovieController.swift
//  MyMovies
//
//  Created by Spencer Curtis on 8/17/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation
import CoreData



class MovieController {
    
    // firebase database url
    let storageURL = URL(string: "https://journal-ef55cc.firebaseio.com/")!
    
    
    // search url
    private let apiKey = "4cc920dab8b729a619647ccc4d191d5e"
    private let baseURL = URL(string: "https://api.themoviedb.org/3/search/movie")!
    
    
    var searchMovie: [MovieRepresentation] = []
    typealias CompletionHandler = (Error?) -> Void
    
    init() {
        self.fetchMoviesFromServer()
    }
    
    
    func fetchMoviesFromServer(completion: @escaping CompletionHandler = { _ in }) {
        let requestURL = storageURL.appendingPathExtension("json")
        
        URLSession.shared.dataTask(with: requestURL) { (data, _, error) in
            if let error = error {
                NSLog("Error fetching saved movies: \(error)")
                completion(error)
                return
            }
            
            guard let data = data else {
                NSLog("No data returned by data movie")
                completion(NSError())
                return
            }
            
            do {
                let movieRepresentations = Array(try JSONDecoder().decode([String: MovieRepresentation].self, from: data).values)
                let moc = CoreDataStack.shared.mainContext
                try self.updateMovies(representations: movieRepresentations, context: moc)
                completion(nil)
            } catch {
                NSLog("Error decoding movie representations: \(error)")
                completion(error)
                return
            }
            }.resume()
    }
    
    private func updateMovies(representations: [MovieRepresentation], context: NSManagedObjectContext) throws {
        
        var error: Error? = nil
        
        context.performAndWait {
            for movieRep in representations {
                if let identifier = movieRep.identifier {
                    if let movie = self.movie(forUUID: identifier.uuidString, in: context) {
                        self.update(movie: movie, with: movieRep, context: context)
                    } else {
                        let _ = Movie(movieRepresentation: movieRep, context: context)
                    }
                    
                }
            }
            do {
                try context.save()
            } catch let saveError {
                error = saveError
            }
        }
        if let error = error { throw error }
    }
    
    func movie(forUUID uuid: String, in context: NSManagedObjectContext) -> Movie? {
        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "identifier == %@", uuid)
        
        var searchResult: Movie? = nil
        
        context.performAndWait {
            do {
                searchResult = try context.fetch(fetchRequest).first
            } catch {
                NSLog("Error fetching movie with uuid: \(uuid): \(error)")
                
            }
        }
        return searchResult
    }
    
    func addMovie(title: String) {
        let movie = Movie(title: title)
        
        do {
            try CoreDataStack.shared.save()
            self.put(movie: movie)
        } catch {
            NSLog("Error adding movie: \(movie)")
        }
        
    }
    
    func updateMovieList(movie: Movie, title: String) {
        movie.title = title
        
        do {
            try CoreDataStack.shared.save()
            self.put(movie: movie)
        } catch {
            NSLog("Error updating movie list: \(error)")
        }
    }
    
    private func update(movie: Movie, with representation: MovieRepresentation, context: NSManagedObjectContext) {
        
        movie.title = representation.title
        
    }
    
    func updateHasWatchedMovie(movie: Movie) {
        movie.hasWatched.toggle()
        do {
            try CoreDataStack.shared.save()
            self.put(movie: movie)
        } catch {
            NSLog("Error updating watched/unwatched: \(error)")
        }
    }
    
    
    func deleteMovie(movie: Movie) {
        self.deleteMovieFromServer(movie: movie) { (error) in
            if let error = error {
                NSLog("Error deleting movie from the list: \(error)")
                return
            }
            
            DispatchQueue.main.async {
                let moc = CoreDataStack.shared.mainContext
                moc.delete(movie)
                
                do {
                    try moc.save()
                } catch {
                    NSLog("Error saving movie after deleting")
                }
            }
        }
        
    }
    
    // Deleting a movie
    func deleteMovieFromServer(movie: Movie, completion: @escaping CompletionHandler = { _ in }) {
        guard let uuid = movie.identifier else {
            completion(NSError())
            return
        }
        
        let requestURL = baseURL.appendingPathComponent("\(uuid)").appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        
        request.httpMethod = "DELETE"
        
        URLSession.shared.dataTask(with: request) { (_, data, error) in
            if let error = error {
                NSLog("Error Deleting data on server: \(error)")
                completion(error)
                return
            }
            completion(nil)
            }.resume()
    }
    
    
    
    
    // PUT
    func put(movie: Movie, completion: @escaping CompletionHandler = {_ in }) {
        let uuid = movie.identifier ?? UUID()
        let requestURL = baseURL.appendingPathComponent(uuid.uuidString).appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = "PUT"
        
        guard var reption = movie.movieRepresentation else { completion(NSError()); return }
        
        do {
            reption.identifier = uuid
            movie.identifier = uuid
            try CoreDataStack.shared.save()
            request.httpBody = try JSONEncoder().encode(reption)
        } catch {
            NSLog("Error ecoding movie: \(movie) \(error)")
            completion(error)
            return
        }
        URLSession.shared.dataTask(with: request) { (data, _, error) in
            if let error = error {
                NSLog("Error PUTting to the server")
                completion(error)
                return
            }
            completion(nil)
            }.resume()
    }
    
    
    // search
    func searchForMovie(with searchTerm: String, completion: @escaping (Error?) -> Void) {
        
        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: true)
        
        let queryParameters = ["query": searchTerm,
                               "api_key": apiKey]
        
        components?.queryItems = queryParameters.map({URLQueryItem(name: $0.key, value: $0.value)})
        
        guard let requestURL = components?.url else {
            completion(NSError())
            return
        }
        
        URLSession.shared.dataTask(with: requestURL) { (data, _, error) in
            
            if let error = error {
                NSLog("Error searching for movie with search term \(searchTerm): \(error)")
                completion(error)
                return
            }
            
            guard let data = data else {
                NSLog("No data returned from data task")
                completion(NSError())
                return
            }
            
            do {
                let movieRepresentations = try JSONDecoder().decode(MovieRepresentations.self, from: data).results
                self.searchedMovies = movieRepresentations
                completion(nil)
            } catch {
                NSLog("Error decoding JSON data: \(error)")
                completion(error)
            }
        }.resume()
    }
    
    // MARK: - Properties
    
    var searchedMovies: [MovieRepresentation] = []
}
