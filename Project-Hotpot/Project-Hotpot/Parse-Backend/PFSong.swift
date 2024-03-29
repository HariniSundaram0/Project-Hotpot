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
    @NSManaged var image: PFFileObject?
    

    static func parseClassName() -> String {
        return "Songs"
    }
    //TODO: instead of creating a new PFObject everytime, first query master set to see if already added.
    class func createPFSongInBackground(song:SPTAppRemoteTrack, image: UIImage?, completion: @escaping (_ result: Result<PFSong, Error>) -> Void) {
        
        // use subclass approach
        let newSong = PFSong()
        
        newSong.name = song.name
        newSong.uri = song.uri
        newSong.duration = song.duration
        newSong.artist = song.artist.name
        newSong.album = song.album.name
        newSong.image = getPFFileFromImage(image: image)
        
        // Save object (following function will save the object in Parse asynchronously)
        newSong.saveInBackground(block: {(success, error) in
            if (success) {
                NSLog("Song was saved successfully for user")
                completion(.success(newSong))
            } else if let error = error{
                NSLog(error.localizedDescription)
                completion(.failure(error))
            }
        })
    }
    class func getPFFileFromImage(image: UIImage?) -> PFFileObject? {
        if let image = image {
            if let data = image.pngData() {
                NSLog("saved image :)")
                return PFFileObject(data: data)
            }
        }
        return nil
    }
    
    class func getPFSongInBackground(song:SPTAppRemoteTrack, completion: @escaping (_ result: Result<PFSong, Error>) -> Void) {
        let query = PFQuery(className: PFSong.parseClassName())
        query.whereKey("uri", equalTo: song.uri)
        query.getFirstObjectInBackground { parseSong, error in
            if let parseSong = parseSong as? PFSong{
                completion(.success(parseSong))
            }
            else if let error = error{
                completion(.failure(error))
            }
        }
    }
}

