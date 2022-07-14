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
    @NSManaged var user : PFUser
    @NSManaged var name : String
    @NSManaged var URI: String
    @NSManaged var duration: UInt
    @NSManaged var artist: String
    @NSManaged var album: String
    
    static func parseClassName() -> String {
        return "PastSongs"
    }
    
    class func saveSong(song:SPTAppRemoteTrack) {
       // use subclass approach
       let newSong = PFSong()
       
        // Add relevant fields to the object
        
        //TODO: Lookup other ways to prevent forced unwrapping
        if let current_user = PFUser.current()
        {
            newSong.user = current_user
        }
        else{
            NSLog("current user is nil")
        }
        
        newSong.name = song.name
        newSong.URI = song.uri
        newSong.duration = song.duration
        newSong.artist = song.artist.name
        newSong.album = song.album.name
        
       // Save object (following function will save the object in Parse asynchronously)
        newSong.saveInBackground(block: { (success, error) in
            if (success) {
             // The object has been saved.
                NSLog("Song was saved successfully")
           } else {
               // There was a problem, check error.description
               let error_description = error?.localizedDescription
               NSLog(error_description ?? "error occured while saving")
           }
         })
    }
}


