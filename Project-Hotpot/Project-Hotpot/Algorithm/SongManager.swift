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
    class func addSpotifySongToHistory (spotifySong: SPTAppRemoteTrack?, completion: ((PFSong?, Error?) -> Void)?) {
        if let spotifySong = spotifySong {
            //create PFSong from spotify track object
            PFSong.createPFSongInBackground(song: spotifySong) {songObject, error in
                if error == nil, let songObject = songObject{
                    //extracted PFSong Object successfully
                    PFHistory.addPFSongToHistory(song:songObject)
                    if let completion = completion {
                        completion(songObject, nil)
                    }
                }
                else if let error = error, let completion = completion{
                        completion(nil, error)
                }
            }
        }
    }
    
}
