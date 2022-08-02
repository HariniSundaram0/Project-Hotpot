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
                        NSLog("refilled cache successfully")
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
                self.spotifyIdToSongDetails(ids: trackIDs) { result in
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
    //TODO: Should the cache Manager be parsing? Consider moving to Spotify Manager?
    private func spotifyIdToSongDetails(ids: [String], completion: @escaping (_ result: Result<[SongDetails], Error>) -> Void) {
        SpotifyManager.shared().fetchAudioFeaturesFromTracks(for: ids) { result in
            switch result{
            case .success(let dictionary):
                guard let features = dictionary["audio_features"] as? [[String:Any]]
                else {
                    return completion(.failure(CustomError.failedResponseParsing))
                }
                let songDetailsArray:[SongDetails]? = features.compactMap { feature in
                    guard let featureDictionary = feature as? [String: Any],
                          let uri = featureDictionary["uri"] as? String,
                          let id = featureDictionary["id"] as? String,
                          let danceability = featureDictionary["danceability"] as? NSNumber,
                          let energy = featureDictionary["energy"] as? NSNumber,
                          let tempo = featureDictionary["tempo"] as? NSNumber,
                          let key = featureDictionary["key"] as? NSNumber
                    else {
                        NSLog("failed parse of audio feature dictionary")
                        //throws error later on
                        return nil
                    }
                    return SongDetails(uri: uri, id: id, danceability: Float(danceability), energy: Float(energy), tempo: Float(tempo), key: Float(key))
                }
                
                guard let songDetailsArray = songDetailsArray else {
                    return completion(.failure(CustomError.failedResponseParsing))
                }
                return completion(.success(songDetailsArray))
                
            case .failure(let error):
                NSLog("failed creating audio song details object: \(error)")
                completion(.failure(error))
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
    

