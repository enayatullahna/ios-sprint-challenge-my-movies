//
//  MyMoviesTableViewCell.swift
//  MyMovies
//
//  Created by Enayatullah Naseri on 12/14/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class MyMoviesTableViewCell: UITableViewCell {

    @IBOutlet weak var movieTitleLabel: UILabel!
    @IBOutlet weak var watchedButton: UIButton!
    
    
    
    var movie: Movie? {
        didSet {
            self.updateViews()
        }
    }
    
    weak var delegate: MovieTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func updateViews() {
        guard let movie = self.movie else { return }
        
        self.movieTitleLabel.text = movie.title
        
        if movie.hasWatched == true {
            self.watchedButton.setTitle("watched", for: .normal)
        } else {
            self.watchedButton.setTitle("Unwatched", for: .normal)
        }
    }

    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func watchButtonTapped(_ sender: Any) {
        delegate?.hasWatchedTapped(cell: self)
    }
    

}
