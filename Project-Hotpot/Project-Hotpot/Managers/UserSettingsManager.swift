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
    
    let defaults = UserDefaults.standard
    
    private static var userSettings: UserSettingsManager = {
        let settings = UserSettingsManager()
        return settings
    }()
    
    // MARK: - Initializers
    //doing this way so that only 1 instance of settings should be created per user.
    override private init() {
        guard let savedUserGenres = defaults.object(forKey: "userGenres") as? [String],
              let savedRemovedGenres = defaults.object(forKey: "removedGenres") as? [String],
              let genres = SpotifyManager.shared().originalGenreSeeds as? [String],
              genres.isEmpty == false,
              savedUserGenres.isEmpty == false
        else {
            removedGenres = []
            userGenres = Set(backupGenres)
            super.init()
            NSLog("initialized Settings Manager")
            print(userGenres)
            return
        }
        NSLog("initialized Settings Manager from previous sessions: removed genres :\(savedRemovedGenres)")
        userGenres = Set(savedUserGenres)
        removedGenres = Set(savedRemovedGenres)
        super.init()
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
    
    func removeMultipleGenresFromPreferences(genres: Set<String>) {
        genres.map{ genre in removeGenreFromPrefences(genre: genre)}
    }
    
    func addMultipleGenresFromPreferences(genres: Set<String>) {
        genres.map{ genre in addGenreToPreferences(genre: genre)}
    }
    
    func savePreferences() {
        defaults.set(Array(userGenres), forKey: "userGenres")
        defaults.set(Array(self.removedGenres), forKey: "removedGenres")
        NSLog("saved user preferences")
    }
}
