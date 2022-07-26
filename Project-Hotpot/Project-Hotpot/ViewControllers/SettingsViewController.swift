//
//  SettingsViewController.swift
//  Project-Hotpot
//
//  Created by Harini Sundaram on 7/26/22.
//

import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet weak var genreButton: UIButton!
    
    //for now removes a random genre for testing purposes
    @IBAction func onClickRemoveRandomGenre(_ sender: Any) {
        if let randomGenre = UserSettingsManager.shared().userGenres.randomElement() as? String{
            UserSettingsManager.shared().removeGenreFromPrefences(genre: randomGenre)
        }
    }
    

}
