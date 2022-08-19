//
//  SettingsViewController.swift
//  Project-Hotpot
//
//  Created by Harini Sundaram on 7/26/22.
//

import UIKit
import RSSelectionMenu

class SettingsViewController: UIViewController {
    
    @IBOutlet weak var genreButton: UIButton!
    @IBOutlet weak var LogoutButton: UIButton!
    
    var genresToAdd: Set<String> = []
    var genresToRemove: Set<String> = []
    
    
    func setGenreMenu() -> RSSelectionMenu<String> {
        let genreMenu = RSSelectionMenu(selectionStyle: .multiple, dataSource: SpotifyManager.shared().originalGenreSeeds) { (cell, genre, indexPath) in
            cell.textLabel?.text = genre
        }
        //sets the values that will be already selected once menu is shown
        genreMenu.setSelectedItems(items: Array(UserSettingsManager.shared().userGenres)) { (genre, index, isSelected, selectedItems) in
            guard let genre = genre else{
                NSLog("genre is nil")
                return
            }
            if isSelected {
                self.genresToAdd.insert(genre)
            }
            else {
                self.genresToRemove.insert(genre)
            }
        }
        
        genreMenu.onDismiss = { [weak self] selectedItems in
            guard let removeGenres = self?.genresToRemove,
                  let addGenres = self?.genresToAdd
            else {
                NSLog("returning, unable to access temporary arrays")
                return
            }
            let removeDifference = removeGenres.subtracting(addGenres)
            let addDifference = addGenres.subtracting(removeGenres)
            UserSettingsManager.shared().removeMultipleGenresFromPreferences(genres: removeDifference)
            UserSettingsManager.shared().addMultipleGenresFromPreferences(genres: addDifference)
            //reset temporary arrays
            self?.genresToAdd = []
            self?.genresToRemove = []
        }
        return genreMenu
    }
    
    @IBAction func onClickShowDropDown(_ sender: Any) {
        print(SpotifyManager.shared().originalGenreSeeds)
        let genreMenu = setGenreMenu()
        genreMenu.show(style: .present, from: self)
    }
    @IBAction func didTapLogout(_ sender: Any) {
        //if music is playing pause it
        SpotifyManager.shared().appRemote.playerAPI?.pause()
        //disconnect from spotify
        SpotifyManager.shared().appRemote.disconnect()
        //move view to original
        PFUser.logOut()
        self.view.window?.rootViewController = SceneDelegate.rootViewController
    }
}
