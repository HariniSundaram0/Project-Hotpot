//
//  Cache.swift
//  Project-Hotpot
//
//  Created by Harini Sundaram on 7/27/22.
//

import Foundation

class Cache: NSObject{
    //TODO: currently using dictionary, so can save to disk easily, but consider alternative implementations?
    var cache: [String: [SongDetails]] = [:]
    let genreKeys: [String]
    
    init(genreKeys: [String]) {
        self.genreKeys = genreKeys
        super.init()
        loadCache()
    }
    //TODO: add function to return songs based on key
    func retrieveSongs(genre:String) -> [SongDetails]? {
        if let results = cache[genre]{
            NSLog("results from cache: \(results)")
            return results
        }
        else {
            NSLog("not a valid key")
            return nil
        }
    }
    
    func addToCache(genre: String, songs: [SongDetails]) {
        if var oldSongs = retrieveSongs(genre: genre){
            oldSongs.append(contentsOf: songs)
            cache[genre] = oldSongs
        }
        else {
            //TODO: Reconsider if this is what you want
            cache[genre] = songs
        }
    }
    
    func evictFromCache(genre: String, evictSong: SongDetails) {
        if var oldSongs = retrieveSongs(genre: genre){
            oldSongs.removeAll { song in
                return song.id == evictSong.id
            }
            cache[genre] = oldSongs
        }
        else{
            NSLog("couldn't find songs to evict at this genre")
        }
    }
    
    func saveCache(){
        Storage.store(self.cache, to: Storage.Directory.documents, as: "cache.json")
        NSLog("stored")
    }
    
    func loadCache(){
        if Storage.fileExists("cache.json", in: .documents) {
            // we have a cache to retrieve
            self.cache = Storage.retrieve("cache.json", from: .documents, as: [String: [SongDetails]].self)
            print("loaded in cache: \(self.cache)" )
        }
        else{
            for genreKey in genreKeys {
                //manually initialize key to empty array
                cache[genreKey] = []
            }
            NSLog("manually created new cache")
        }
    }
        
}
