//
//  randomSong.swift
//  Project-Hotpot
//
//  Created by Harini Sundaram on 7/11/22.
//

import Foundation
import Parse

class SongAlgortithm {
    


func getRandomSong() -> String{
    return "spotify:track:20I6sIOMTCkB6w7ryavxtO"
}

//this is a testing function, to make sure that I can query like I want to going forward

func getPreviousSongs () -> [PFSong] {
    var result: [PFSong] = []
    let query = PFQuery(className:PFSong.parseClassName())
    //we only want data from the current user
    query.whereKey("user", equalTo: PFUser.current())
    
    query.findObjectsInBackground { (objects: [PFObject]?, error: Error?) -> Void in
        if error != nil {
            print(error?.localizedDescription ?? "error happened while fetching from parse")
        } else if let objects = objects as? [PFSong]{
            result = objects
            NSLog("found %i number of queries", objects.count)
            
            //uncomment if you want to print out all of the song names
            //print_songs(songs: objects)
        }
    }
    return result
}

func print_songs(songs: [PFSong]){
//    let songs = getPreviousSongs()
    NSLog("printing now")
//    NSLog("%i", songs.count)
    for song in songs{
        NSLog(song.name)
    }
}

}
