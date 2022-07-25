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
    //in future will include audio analysis features such as 'liked', 'disliked', genre, tags, etc
    
    static func parseClassName() -> String {
        return "History"
    }
    
    class func addSongToHistoryInBackground(user: PFUser, song:PFSong, completion:((Bool) -> Void)?) {
        let newHistory = PFHistory()
        newHistory.user = user
        newHistory.song = song
        newHistory.playTimeStamp = NSDate()
        //save asynchronously
        newHistory.saveInBackground(block: {isSuccessful, error in
            if let completion = completion{
                completion(isSuccessful)
            }
        })
    }
    
    class func getHistoryInBackground(user:PFUser, completion: (([PFHistory]?, Error?)->Void)?) {
        let query = PFQuery(className: PFHistory.parseClassName())
        query.includeKey("song")
        query.whereKey("user", equalTo: user)
        query.order(byDescending: "playTimeStamp")
        
        query.findObjectsInBackground { historyObjects, error in
            //TODO: is there a more efficient way to do this? similar to O(n) efficiency.
            if let historyObjects = historyObjects as? [PFHistory] {
                NSLog("obtained history")
                if let completion = completion {
                    NSLog("passing into completion")
                    completion(historyObjects, nil)
                }
            }
            else{
                if let completion = completion {
                    completion(nil, error)
                }
                NSLog("didn't find anything")
            }
        }
    }
    
    class func addPFSongToHistory(song:PFSong){
        guard let currentUser = PFUser.current()
        else {
            NSLog("Current User is nil")
            return
        }
        PFHistory.addSongToHistoryInBackground(user: currentUser, song: song, completion: nil)
    }
}



