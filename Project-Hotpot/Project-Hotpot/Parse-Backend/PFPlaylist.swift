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
    
    static func parseClassName() -> String {
        return "Playlist"
    }
    
    class func createPlaylistInBackground(user: PFUser, name:String, completion: @escaping (PFPlaylist?) -> Void){
        let newPlaylist = PFPlaylist()
        newPlaylist.user = user
        newPlaylist.name = name
        
        //save asynchronously
        newPlaylist.saveInBackground(block: { isSuccessful, error in
            if (isSuccessful){
                completion(newPlaylist)
            }
            else{
                NSLog("Error saving new playlist: \(error)")
                completion(nil)
            }
        })
    }
    
    
    class func addSongtoPlaylistInBackground(song: PFSong, playlist: PFPlaylist, completion: @escaping ((Bool, Error?)-> Void)){
        // create an entry in the Follow table
        let joinTable = PFObject(className: "SongJoinTable")
        joinTable.setObject(song, forKey: "Song")
        joinTable.setObject(playlist, forKey: "Playlist")
        
        let currentDate = NSDate()
        joinTable.setObject(currentDate, forKey: "AddedAt")
        joinTable.setObject(currentDate, forKey: "LastPlayed")
        
        joinTable.saveInBackground { saved, error in
            if saved {
                NSLog("song saved successfully")
                completion(true, nil)
            }
            else {
                NSLog("failed to save song to playlist")
                completion(false, error)
            }
        }
    }
    
    class func getAllSongsFromPlaylist(playlist: PFPlaylist, completion: @escaping ([PFSong]?, Error?)->Void){
        let query = PFQuery(className: "SongJoinTable")
        var songArray: [PFSong]? = []
        //playlist is a pointer to playlist object
        query.includeKey("Song")
        query.whereKey("Playlist", equalTo: playlist)
        query.order(byAscending: "AddedAt")
        query.findObjectsInBackground { objects, error in
            //TODO: is there a more efficient way to do this? similar to O(n) efficiency.
            if let objects = objects{
                for o in objects{
                    if let songObject = o.object(forKey: "Song") as? PFSong{
                        songArray?.append(songObject)
                    }
                }
                completion(songArray, nil)
            }
            else{
                completion(nil, error)
                NSLog("didn't find anything")
            }
        }
    }
    
    class func getAllPlaylistsInBackground(completion: @escaping([PFPlaylist]?, Error?) -> Void) {
        let query = PFQuery(className:PFPlaylist.parseClassName())
        query.order(byDescending: "createdAt")
        //we only want data from the current user
        query.whereKey("user", equalTo: PFUser.current())
        query.findObjectsInBackground(block: {playlistObjects, error in
            if let playlistObjects = playlistObjects as? [PFPlaylist] {
                completion(playlistObjects, nil)
            }
            else{
                completion(nil, error)
            }
        })
    }
}


