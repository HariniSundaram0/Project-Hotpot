//
//  SongManager.swift
//  Project-Hotpot
//
//  Created by Harini Sundaram on 7/21/22.
//

import Foundation
import Parse

class SongManager : NSObject {
    var historySet: Set<String> = []
    
     override private init() {
        //we don't want to be working with multiple instances, otherwise unnecessary network calls
        super.init()
        if let currentUser = PFUser.current() {
            PFHistory.getHistoryInBackground(user: currentUser) { result in
                switch result {
                case .success(let items):
                    let trackIDs: [String] = items.compactMap {$0.uri}
                    self.historySet = Set(trackIDs)
                case .failure(let error):
                    NSLog(error.localizedDescription)
                }
            }
        }
    }
    private static var sharedSongManager: SongManager = {
        return SongManager()
    }()
    
    class func shared() -> SongManager {
        return sharedSongManager
    }
    
    //returns PFSong object via completion block to prevent unneccessary object creation
    func addSpotifySongToHistory(spotifySong: SPTAppRemoteTrack, completion:  @escaping (_ result: Result<PFSong, Error>) -> Void){
        self.getParseSongObject(spotifySong: spotifySong) { result in
            switch result {
            case .success(let parseSong):
                PFHistory.addPFSongToHistory(song: parseSong) { result in
                    switch result {
                    case .success(_):
                        return completion(.success(parseSong))
                    case .failure(let error):
                        return completion(.failure(error))
                    }
                }
            case .failure(let error):
                return completion(.failure(error))
            }
        }
        self.historySet.insert(spotifySong.uri)
    }
    
    func getParseSongObject (spotifySong: SPTAppRemoteTrack, completion:  @escaping (_ result: Result<PFSong, Error>) -> Void) {
        //first query past songs to see if there are any already created objects.
        PFSong.getPFSongInBackground(song: spotifySong) {result in
            switch result{
            case .success(let parseSong):
                completion(.success(parseSong))
            case .failure(_):
                SpotifyManager.shared().fetchArtwork(for: spotifySong) { result in
                    switch result {
                    case .success(let image):
                        PFSong.createPFSongInBackground(song: spotifySong, image: image) { result in
                            switch result {
                            case .success(let parseSong):
                                return completion(.success(parseSong))
                            case .failure(let error):
                                completion(.failure(error))
                                return
                            }
                        }
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            }
        }
    }
}

