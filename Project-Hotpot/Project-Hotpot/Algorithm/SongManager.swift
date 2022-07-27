//
//  SongManager.swift
//  Project-Hotpot
//
//  Created by Harini Sundaram on 7/21/22.
//

import Foundation
import Parse

class SongManager : NSObject {
    //returns PFSong object via completion block to prevent unneccessary object creation
    class func addSpotifySongToHistory (spotifySong: SPTAppRemoteTrack?, completion: @escaping (_ result: Result<PFSong, Error>) -> Void) {
        if let spotifySong = spotifySong {
            //create PFSong from spotify track object
            PFSong.createPFSongInBackground(song: spotifySong) { result in
                switch result {
                case .success(let parseSong):
                    PFHistory.addPFSongToHistory(song: parseSong)
                    return completion(.success(parseSong))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
}
