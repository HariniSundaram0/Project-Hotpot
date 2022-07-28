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
    }
    
    func getParseSongObject (spotifySong: SPTAppRemoteTrack, completion:  @escaping (_ result: Result<PFSong, Error>) -> Void) {
        //first query past songs to see if there are any already created objects.
        PFSong.getPFSongInBackground(song: spotifySong) {result in
            switch result{
            case .success(let parseSong):
                completion(.success(parseSong))
            case .failure(_):
                //else create a new parse object
                PFSong.createPFSongInBackground(song: spotifySong) { result in
                    switch result {
                    case .success(let parseSong):
                        return completion(.success(parseSong))
                    case .failure(let error):
                        completion(.failure(error))
                        return
                    }
                }
            }
        }
    }
}

