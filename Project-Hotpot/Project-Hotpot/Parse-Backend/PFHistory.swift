//
//  PFHistory.swift
//  Project-Hotpot
//
//  Created by Harini Sundaram on 7/20/22.
//

import Foundation
import Parse

class PFHistory: PFObject, PFSubclassing {
    @NSManaged var user : PFUser
    @NSManaged var song : PFSong
    @NSManaged var playTimeStamp : NSDate
    //max query for history
    static let LIMIT : Int = 100
    @NSManaged var uri : String
    
    static func parseClassName() -> String {
        return "History"
    }
    
    class func addSongToHistoryInBackground(user: PFUser, song:PFSong, completion: @escaping (_ result: Result<Void, Error>) -> Void) {
        let newHistory = PFHistory()
        newHistory.user = user
        newHistory.song = song
        newHistory.playTimeStamp = NSDate()
        newHistory.uri = song.uri
        //save asynchronously
        newHistory.saveInBackground(block: {isSuccessful, error in
            if let error = error {
                completion(.failure(error))
            }
            else if isSuccessful{
                completion(.success(()))
            }
        })
    }
    
    class func getHistoryInBackground(user:PFUser, completion: @escaping (_ result: Result<[PFHistory], Error>) -> Void) {
        let query = PFQuery(className: PFHistory.parseClassName())
        query.includeKey("song")
        query.limit = self.LIMIT
        query.whereKey("user", equalTo: user)
        query.order(byDescending: "playTimeStamp")
        
        query.findObjectsInBackground { historyObjects, error in
            //TODO: is there a more efficient way to do this? similar to O(n) efficiency.
            if let historyObjects = historyObjects as? [PFHistory] {
                NSLog("obtained history")
                completion(.success(historyObjects))
            }
            else if let error = error {
                completion(.failure(error))
            }
        }
    }
    
    class func addPFSongToHistory(song:PFSong, completion:  @escaping (_ result: Result<Void, Error>) -> Void) {
        guard let currentUser = PFUser.current()
        else {
            return completion(.failure(CustomError.nilPFUser))
        }
        PFHistory.addSongToHistoryInBackground(user: currentUser, song: song, completion: completion)
    }
}



