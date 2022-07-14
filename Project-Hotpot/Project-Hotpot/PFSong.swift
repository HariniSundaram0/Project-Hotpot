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
    @NSManaged var URI: String
    @NSManaged var duration: UInt
    @NSManaged var artist: String
    @NSManaged var album: String
    
    static func parseClassName() -> String {
        return "Song"
    }
    
    class func saveSong(song:SPTAppRemoteTrack) {
       // use subclass approach
       let newSong = PFSong()
       
        // Add relevant fields to the object
        newSong.name = song.name
        newSong.URI = song.uri
        newSong.duration = song.duration
        newSong.artist = song.artist.name
        newSong.album = song.album.name
        
       // Save object (following function will save the object in Parse asynchronously)
        newSong.saveInBackground()
    
    }
}


