//
//  MovieSearchTableViewDelegate.swift
//  MyMovies
//
//  Created by Enayatullah Naseri on 12/14/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation

protocol MovieSearchTableViewDelegate: class {
    func addMovieTappedAtSearch(cell: MovieSearchTableViewCell)
}
