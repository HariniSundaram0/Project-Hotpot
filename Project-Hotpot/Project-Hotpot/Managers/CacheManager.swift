//
//  CacheManager.swift
//  Project-Hotpot
//
//  Created by Harini Sundaram on 7/27/22.
//

import Foundation

class CacheManager: NSObject {
    
    //level of layering allows me to easily make changes to Cache implementation later on
    private var cache : Cache
    //I believe conventions are the constants are all caps
    let MIN_CACHE_LIMIT = 0
    let SONGS_PER_GENRE = 5
    
    private static var sharedCacheManager: CacheManager = { return CacheManager() }()
    
    override private init() {
        cache = Cache(genreKeys: SpotifyManager.shared().originalGenreSeeds)
        super.init()
        
    }
    // MARK: - Accessors
    class func shared() -> CacheManager {
        return sharedCacheManager
    }
    
    //TODO: unsure of naming in this case
    func retrieveSongsFromCache(genre:String, completion: @escaping (_ result: Result<[SongDetails], Error>) -> Void) {
        let songDetailsArray = cache.retrieveSongs(genre: genre)
        if songDetailsArray == nil{
            NSLog("unable to retreive from genre")
            completion(.failure(CustomError.invalidCacheKey))
        }
        else if let songDetailsArray = songDetailsArray {
            if songDetailsArray.count <= MIN_CACHE_LIMIT {
                NSLog("Cache Miss for genre :\(genre)")
                refillCache(genre:genre) { result in
                    switch result {
                    case .success(let newSongDetailsArray):
                        self.filterRepeatSongs(genre: genre, songs: newSongDetailsArray) { filterResult in
                            switch filterResult {
                            case .success(let filterArray):
                                NSLog("filtered successfully")
                                completion(.success(filterArray))
                                
                            case .failure(let error):
                                completion(.failure(error))
                            }
                        }
                        completion(.success(newSongDetailsArray))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            }
            else {
                NSLog("Cache Hit for \(genre)")
                completion(.success(songDetailsArray))
            }
        }
    }

    func filterRepeatSongs(genre:String, songs: [SongDetails], completion: @escaping (_ result: Result<[SongDetails], Error>) -> Void) {
        NSLog("filter iteration")
        let  filteredSongs : [SongDetails] = songs.filter { song in
            if SongManager.shared().historySet.contains(song.uri) {
                removeSongFromCache(genre: genre, song: song)
                return false
            }
            else {
                return true
            }
        }
        //recursive strategy, which in practice is very unlikely
           if filteredSongs.isEmpty {
               refillCache(genre: genre) { result in
                   switch result {
                   case .success(let newSongs):
                       return self.filterRepeatSongs(genre: genre, songs: newSongs, completion: completion)
                   case .failure(let error):
                       completion(.failure(error))
                   }
               }
           }
               else {
                   return completion(.success(filteredSongs))
               }
           }

    func removeSongFromCache(genre: String, song: SongDetails) {
        cache.evictFromCache(genre: genre, evictSong: song)
    }
    func refillCache(genre:String, completion: @escaping (_ result: Result<[SongDetails], Error>) -> Void) {
        fetchNSongs(limit:SONGS_PER_GENRE, genre:genre) { result in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let dictionary):
                guard let tracks = dictionary["tracks"] as? [String:Any]?,
                      let items = tracks?["items"] as? [[String:Any]?]
                else{
                    NSLog("failed parsing random song dictionary response")
                    return completion(.failure(CustomError.failedResponseParsing))
                }
                let trackIDs : [String] = items.compactMap{ $0?["id"] as? String}
                SpotifyManager.shared().spotifyIdToSongDetails(ids: trackIDs) { result in
                    switch result{
                    case .success(let songDetailsArray):
                        self.cache.addToCache(genre: genre, songs: songDetailsArray)
                        completion(.success(songDetailsArray))
                    case .failure(let error) :
                        completion(.failure(error))
                    }
                }
            }
        }
    }
    
    private func fetchNSongs (limit: Int, genre: String, completion: @escaping (_ result: Result<[String:Any], Error>) -> Void) {
        let randomOffset = Int.random(in: 1..<800)
        NSLog("requesting randomOffset: \(randomOffset), genre: \(genre)")
        SpotifyManager.shared().fetchNSongsFromGenre(limit: limit, genre: genre, offset: randomOffset, completion: completion)
    }

    func saveCache() {
        self.cache.saveCache()
    }
}
    

