//
//  UserSettingsManager.swift
//  Project-Hotpot
//
//  Created by Harini Sundaram on 7/26/22.
//

import Foundation
//TODO: unsure of which group to put this in Managers or Algorithm?
//TODO: cache Genre Preferences and load in from session to session
class UserSettingsManager: NSObject {
    //using sets to make checking existance more efficient
    //will be used primarily by UI
    var removedGenres : Set <String>
    //used by algorithm
    var userGenres : Set <String>
    
    private static var userSettings: UserSettingsManager = {
        let settings = UserSettingsManager()
        return settings
    }()
    
    // MARK: - Initializers
    //doing this way so that only 1 instance of settings should be created per user.
    override private init() {
        removedGenres = []
        let originalGenres = SpotifyManager.shared().originalGenreSeeds
        userGenres = Set(originalGenres)
        NSLog("initialized Settings Manager")
    }
    
    // MARK: - Accessors
    class func shared() -> UserSettingsManager {
        return userSettings
    }
    
    func addGenreToPreferences(genre: String) {
        //making sure genre lists were stored correctly
        if (userGenres.contains(genre)){
            NSLog("already in preferences")
            return
        }
        else if (!removedGenres.contains(genre)){
            NSLog("wasn't previously removed from genres")
            return
        }
        userGenres.insert(genre)
        removedGenres.remove(genre)
    }
    
    func removeGenreFromPrefences(genre: String){
        //making sure genre lists were stored correctly
        if (userGenres.contains(genre) == false){
            NSLog("wasn't previously added to genre list")
            return
        }
        else if (removedGenres.contains(genre)){
            NSLog("already removed")
            return
        }
        removedGenres.insert(genre)
        userGenres.remove(genre)
        
    }
}
