//
//  GenreManager.swift
//  Project-Hotpot
//
//  Created by Harini Sundaram on 7/26/22.
//

import Foundation

class GenreManager: NSObject {
    //using sets to make checking existance more efficient
    //will be used primarily by UI
    var genreQueue : GenreQueue = GenreQueue()
    
    private static var genreManagerInstance: GenreManager = {
        return GenreManager()
    }()
    
    // MARK: - Initializers
    //doing this way so that only 1 instance of settings should be created per user.
    override private init() {
        NSLog("genre manager Initialized")
        super.init()
        reinitializeQueue()
    }
    
    // MARK: - Accessors
    class func shared() -> GenreManager {
        return genreManagerInstance
    }
    
    func reinitializeQueue () {
        if (self.genreQueue.isEmpty) {
            self.genreQueue.enqueueFromList(genres: Array(UserSettingsManager.shared().userGenres).shuffled())
        }
    }
    
    func getGenre() -> Genre?{
        if self.genreQueue.isEmpty{
            NSLog("is empty, reinitializing")
            self.reinitializeQueue()
        }
        NSLog("dequeing")
        return self.genreQueue.dequeue()
    }
}
