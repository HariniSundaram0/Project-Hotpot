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
    @NSManaged var songArray : [String]?
    
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
        newPlaylist.saveInBackground(block: { isSuccessful, error in
            if (isSuccessful){
                completion(true)
            }
            else{
                NSLog("Error saving new playlist: \(error)")
                completion(false)
            }
            
        })
    }
    
    class func addSongToPlaylistInBackground(song: PFSong,
                                             playlist: PFPlaylist,
                                             completion: @escaping((Bool, Error?) -> Void)) {
        let songID = song.objectId!
        //TODO: consider switching from array of SongID's to relational table
        playlist.songArray?.append(songID)
        playlist.saveInBackground {success, error in
            if success == true {
                completion(true, nil)
            }
            else{
                completion(false, error)
            }
        }
    }
    
    //TODO: change to getting ALL playlists instead of just first.
    class func getPlaylistInBackground(completion: @escaping(PFPlaylist?, Error?) -> Void) {
        let query = PFQuery(className:PFPlaylist.parseClassName())
        //we only want data from the current user
        query.whereKey("user", equalTo: PFUser.current())
        query.getFirstObjectInBackground {playlistObject,error in
            if let playlistObject = playlistObject as? PFPlaylist {
                completion(playlistObject, nil)
            }
            else{
                completion(nil, error)
            }
        }
    }
}


