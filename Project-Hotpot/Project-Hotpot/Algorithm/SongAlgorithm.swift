//
//  randomSong.swift
//  Project-Hotpot
//
//  Created by Harini Sundaram on 7/11/22.
//

import Foundation
import Parse
import AFNetworking

class SongAlgorithm{
    var apiInstance = SpotifyManager.shared()
    var userPreferences = UserSettingsManager.shared()
    var genreManager = GenreManager.shared()
    var cacheManager = CacheManager.shared()
    var scoreManager = SongScoreManager.shared()
    var songManager = SongManager()
    

    func getAlgorithmSong(completion: @escaping (_ result: Result<String, Error>) -> Void) {
        guard let genre = getRandomGenre() else {
            return completion(.failure(CustomError.invalidCacheKey))
        }
        let songs = cacheManager.retrieveSongsFromCache(genre:genre) { result in
            switch result {
            case .success(let songs):
                //TODO: next iteration switch to scoring metric
                guard let song = self.scoreManager.findMaxSongScore(songs:songs) else {
                    completion(.failure(CustomError.failedResponseParsing))
                    return
                }
                //remove played song from cache to prevent repeat songs
                self.cacheManager.removeSongFromCache(genre: genre, song: song)
                completion(.success(song.uri))
            case .failure(let error):
                NSLog("error retreiving: \(error)")
                completion(.failure(error))
            }
        }
    }
    
    func getRandomGenre() -> String? {
        //returns nil if the queue somehow returns a nil object, which cannot happen
        //TODO: consider instead of returning nil, throw error instead?
        guard let genre = genreManager.getGenre() else {
            return nil
        }
        if userPreferences.removedGenres.contains(genre.name) {
            NSLog("skipping \(genre.name) since not preferred")
            return getRandomGenre()
        }
        else {
            return genre.name
        }
    }
}

