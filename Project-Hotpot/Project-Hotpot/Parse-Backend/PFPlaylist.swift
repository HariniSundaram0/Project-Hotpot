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
    
    class func createPlaylistInBackground(name:String, completion: @escaping (Bool) -> Void){
        let newPlaylist = PFPlaylist()
        if(PFUser.current() == nil){
            NSLog("current user is nil")
            completion(false)
        }
        newPlaylist.user = PFUser.current()!
        newPlaylist.name = name
        newPlaylist.songArray = []
        
        //save asynchronously
        newPlaylist.saveInBackground(block: {isSuccessful, error in
            if (isSuccessful){
                completion(true)
            }
            else{
                NSLog("Error saving new playlist: \(error)")
                completion(false)
            }
            
        })
    }
}
    
    
    
    
