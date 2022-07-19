//
//  PFSong.swift
//  Project-Hotpot
//
//  Created by Harini Sundaram on 7/14/22.
//

import UIKit
import Parse

//will store Songs as PFSong objects
class PFSong: PFObject, PFSubclassing {
    @NSManaged var name : String
    @NSManaged var uri: String
    @NSManaged var duration: UInt
    @NSManaged var artist: String
    @NSManaged var album: String
    
    static func parseClassName() -> String {
        return "Songs"
    }
    
    class func saveSongInBackground(song:SPTAppRemoteTrack, completion: @escaping (PFSong?, Error?)-> (Void)) {
        // use subclass approach
        let newSong = PFSong()
        
        //TODO: Lookup other ways to prevent forced unwrapping
        newSong.name = song.name
        newSong.uri = song.uri
        newSong.duration = song.duration
        newSong.artist = song.artist.name
        newSong.album = song.album.name
        
        // Save object (following function will save the object in Parse asynchronously)
        newSong.saveInBackground(block: { (success, error) in
            if (success) {
                // The object has been saved.
                NSLog("Song was saved successfully for user")
                completion(newSong, nil)
            } else {
                // There was a problem, check error.description
                let error_description = error?.localizedDescription
                NSLog(error_description ?? "error occured while saving")
                completion(nil, error)
            }
        })
    }
}

