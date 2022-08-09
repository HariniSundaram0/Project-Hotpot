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
    
    class func createPlaylistInBackground(user: PFUser, name:String, completion: @escaping (_ result: Result<PFPlaylist, Error>) -> Void) {
        let newPlaylist = PFPlaylist()
        newPlaylist.user = user
        newPlaylist.name = name
        
        //save asynchronously via parse function
        newPlaylist.saveInBackground(block: {isSuccessful, error in
            if (isSuccessful && error == nil){
                completion(.success(newPlaylist))
            }
            else if let error = error{
                NSLog("Error saving new playlist: \(error)")
                return completion(.failure(error))
            }
        })
    }
    
    
    class func addSongtoPlaylistInBackground(song: PFSong, playlist: PFPlaylist, completion: @escaping (_ result: Result<Void, Error>) -> Void) {
        // create an entry in the Follow table
        let joinTable = PFObject(className: "SongJoinTable")
        joinTable.setObject(song, forKey: "song")
        joinTable.setObject(playlist, forKey: "playlist")
        
        let currentDate = NSDate()
        joinTable.setObject(currentDate, forKey: "addedAt")
        joinTable.setObject(currentDate, forKey: "lastPlayed")
        
        joinTable.saveInBackground {saveSuccessful, error in
            if let error = error {
                completion(.failure(error))
            }
            else {
                NSLog("song saved successfully")
                completion(.success(()))
            }
        }
    }
    
    class func addPFSongToLastPlaylist(song:PFSong) {
        PFPlaylist.getLastNPlaylistsInBackground(limit: 1) { result in
            switch result {
            case .success(let playlistArray):
                let currPlaylist = playlistArray[0]
                addPFSongToPlaylist(song: song, currPlaylist: currPlaylist)
            case .failure(let error):
                NSLog(error.localizedDescription)
            }
        }
    }
    
    
    
    class func addPFSongToPlaylist(song: PFSong, currPlaylist:PFPlaylist) {
        PFPlaylist.addSongtoPlaylistInBackground(song: song, playlist: currPlaylist) { result in
            switch result{
            case .success(_):
                NSLog("added to playlist: \(currPlaylist.name)")
                
            case .failure(let error):
                NSLog(error.localizedDescription)
            }
        }
    }
    
    class func getAllSongsFromPlaylist(playlist: PFPlaylist, completion: @escaping (_ result: Result<[PFSong], Error>) -> Void) {
        let query = PFQuery(className: "SongJoinTable")
        query.includeKey("song")
        query.whereKey("playlist", equalTo: playlist)
        query.order(byAscending: "addedAt")
        query.findObjectsInBackground { objects, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            else if let objects = objects {
                let songArray : [PFSong] = objects.compactMap{ obj in obj.object(forKey: "song") as? PFSong }
                return completion(.success(songArray))
            }
            //returns success if either no songs (empty array), or the songs if found.
            completion(.success([]))
        }
    }
    
    
    class func getLastNPlaylistsInBackground(limit: Int?, completion: @escaping (_ result: Result<[PFPlaylist], Error>) -> Void) {
        let query = PFQuery(className:PFPlaylist.parseClassName())
        query.order(byDescending: "createdAt")
        if let limit = limit {
            query.limit = limit
        }
        //we only want data from the current user
        query.whereKey("user", equalTo: PFUser.current())
        query.findObjectsInBackground(block: { playlistObjects, error in
            if let playlistObjects = playlistObjects as? [PFPlaylist] {
                completion(.success(playlistObjects))
            }
            else if let error = error{
                completion(.failure(error))
            }
        })
    }
    
    class func getSongPlaylistObject(song: PFSong, playlist: PFPlaylist, completion: @escaping (_ result: Result<PFObject, Error>) -> Void) {
        let query = PFQuery(className: "SongJoinTable")
        query.whereKey("playlist", equalTo: playlist)
        query.whereKey("song", equalTo: song)
        
        query.getFirstObjectInBackground { relation, error in
            if let error = error {
                completion(.failure(error))
            }
            else if let relation = relation {
                completion(.success(relation))
            }
        }
    }
    
    
    class func removeSongFromPlaylistInBackground(song: PFSong, playlist: PFPlaylist, completion: @escaping (_ result: Result<Void, Error>) -> Void) {
        // create an entry in the Follow table
        
        getSongPlaylistObject(song: song, playlist: playlist) { result in
            switch result {
            case .success(let songRelation):
                songRelation.deleteInBackground {isSuccessful, error in
                    if let error = error {
                        completion(.failure(error))
                    }
                    else{
                        completion(.success(()))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}


