//
//  PFPlaylist.swift
//  Project-Hotpot
//
//  Created by Harini Sundaram on 7/18/22.
//

import Foundation
import Parse
import AFNetworking

class PFPlaylist: PFObject, PFSubclassing {
    @NSManaged var user : PFUser
    @NSManaged var name : String?
    @NSManaged var songArray : [PFSong]?
    
    static func parseClassName() -> String {
        return "Playlist"
    }
    
    class func createPlaylist(name:String, completion: (Bool) -> Void){
        let newPlaylist = PFPlaylist()
        if(PFUser.current() == nil){
            NSLog("current user is nil")
            completion(false)
        }
        newPlaylist.user = PFUser.current()!
        newPlaylist.name = name
        newPlaylist.songArray = []
        
        do {
            //save synchronously, since creation will most likely be followed by edits to the playlist
            //TODO: Feedback on synchronous creation or async? If synchronous, is completion necessary?
            try newPlaylist.save()
        }
        catch{
            NSLog("Error saving new playlist: \(error)")
            completion(false)
        }
        completion(true)
    }

}

