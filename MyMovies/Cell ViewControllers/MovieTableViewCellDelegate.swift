//
//  MovieTableViewCellDelegate.swift
//  MyMovies
//
//  Created by Enayatullah Naseri on 12/14/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation

protocol MovieTableViewCellDelegate: class {
    func hasWatchedTapped(cell: MyMoviesTableViewCell)
}
