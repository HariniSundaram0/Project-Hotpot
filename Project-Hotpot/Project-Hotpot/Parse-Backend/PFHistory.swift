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
    //TODO: add song id attribute for faster querying in the future
    //in future will include audio analysis features such as 'liked', 'disliked', genre, tags, etc
    
    static func parseClassName() -> String {
        return "History"
    }
    
    class func addSongToHistoryInBackground(user: PFUser, song:PFSong, completion: @escaping (_ result: Result<Void, Error>) -> Void) {
        let newHistory = PFHistory()
        newHistory.user = user
        newHistory.song = song
        newHistory.playTimeStamp = NSDate()
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
    
    class func addPFSongToHistory(song:PFSong) {
        guard let currentUser = PFUser.current()
        else {
            NSLog("Current User is nil")
            return
        }
        PFHistory.addSongToHistoryInBackground(user: currentUser, song: song) { result in
            switch result {
            case .success(_): return
            case .failure(let error):
                NSLog(error.localizedDescription)
            }
        }
    }
}



