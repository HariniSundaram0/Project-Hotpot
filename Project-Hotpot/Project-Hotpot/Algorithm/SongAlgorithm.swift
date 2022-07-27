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
    var genreQueueManager = GenreQueueManager.shared()
    
    func getRandomSong(completion: @escaping(Any?, Error?) -> Void){
        fetchSong { (dictionary, error) in
            if let error = error {
                NSLog("Fetching token request error \(error)")
                return completion(nil, error)
            }
            else{
                //beginning of series of conditional downcasting to parse
                guard let tracks = dictionary?["tracks"] as? [String:Any]?,
                      let items = tracks?["items"] as? [[String:Any]?],
                      let randomSong = items.randomElement(),
                      let randomURI = randomSong?["uri"]
                else{
                    NSLog("failed parsing random song dictionary response")
                    return completion(nil, error)
                }
                return completion(randomURI, error)
            }
        }
    }
    
    func getRandomGenre() -> String? {
        //returns nil if the queue is empty
        guard let genre = genreQueueManager.getGenre() else {
            return nil
        }
        //edge case: user changes perferences after queue was initialized,
        //instead of removing all genres and enqueuing just the preferred genres, just discard for now
        if userPreferences.removedGenres.contains(genre.name){
            NSLog("skipping \(genre.name) since not preferred")
            return getRandomGenre()
        }
        else{
            return genre.name
        }
    }
    
    func fetchSong(completion: @escaping ([String: Any]?, Error?) -> Void) {
        //TODO: add seed to increase randomness
        let randomOffset = Int.random(in: 1..<800)
        guard let genre = getRandomGenre()
        else {
            NSLog("no genre's available")
            return
        }
        NSLog("requesting randomOffset: \(randomOffset), genre: \(genre)")
        apiInstance.fetchSongsFromGenre(genre: genre, offset: randomOffset, completion: completion)
    }
}

