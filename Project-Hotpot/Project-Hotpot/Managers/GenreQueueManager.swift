//
//  GenreQueueManager.swift
//  Project-Hotpot
//
//  Created by Harini Sundaram on 7/26/22.
//

import Foundation

class GenreQueueManager: NSObject {
    //using sets to make checking existance more efficient
    //will be used primarily by UI
    var genreQueue : GenreQueue = GenreQueue()
    
    private static var genreQueueManager: GenreQueueManager = {
        return GenreQueueManager()
    }()
    
    // MARK: - Initializers
    //doing this way so that only 1 instance of settings should be created per user.
    override private init() {
        super.init()
        reinitializeQueue()
    }
    
    // MARK: - Accessors
    class func shared() -> GenreQueueManager {
        return genreQueueManager
    }
    
    func reinitializeQueue () {
        if(self.genreQueue.isEmpty) {
            let userGenres = UserSettingsManager.shared().userGenres
            self.genreQueue.enqueueFromList(genres: Array(userGenres).shuffled())
        }
    }
    
    func getGenre() -> Genre?{
        if self.genreQueue.isEmpty{
            self.reinitializeQueue()
        }
        return self.genreQueue.dequeue()
    }
}
