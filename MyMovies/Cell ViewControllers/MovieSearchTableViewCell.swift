//
//  MovieSearchTableViewCell.swift
//  MyMovies
//
//  Created by Enayatullah Naseri on 12/14/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class MovieSearchTableViewCell: UITableViewCell {

    // Outlets
    @IBOutlet weak var movieTitleLabel: UILabel!
    @IBOutlet weak var addMovieButton: UIButton!
    
    //Delegate
    weak var delegate: MovieSearchTableViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func addMovieTapped(_ sender: Any) {
        delegate?.addMovieTappedAtSearch(cell: self)
    }
    

}
