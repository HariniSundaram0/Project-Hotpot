//
//  RadioModeViewController.swift
//  Project-Hotpot
//
//  Created by Harini Sundaram on 8/9/22.
//

import UIKit

class RadioModeViewController: HomeViewController {
    //ensures correct algorithm is being used
    var genre: String?
    override func viewDidAppear(_ animated: Bool) {
        super.exploreMode = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isBeingDismissed {
            super.exploreMode = true
        }
    }
    
    override func resetSong() {
        let algInstance = SongAlgorithm()
        let completion: (Result<(String, String), Error>) -> Void = { result in
            switch result {
            case .success(let (uri, genre)):
                super.playNewSong(uri: uri)
                super.currentGenre = genre
                super.resetCard()
                
            case .failure(let error):
                NSLog("\(error)")
                super.resetCard()
            }
        }
        guard let genre = genre else {
            return
        }
        algInstance.getSimilarSong(genre: genre, completion: completion)
    }
}
