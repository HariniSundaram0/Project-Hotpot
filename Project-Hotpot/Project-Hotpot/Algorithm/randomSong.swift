//
//  randomSong.swift
//  Project-Hotpot
//
//  Created by Harini Sundaram on 7/11/22.
//

import Foundation
import Parse

func getRandomSong() -> String{
    return "spotify:track:20I6sIOMTCkB6w7ryavxtO"
}

//this is a testing function, to make sure that I can query like I want to going forward

func getPreviousSongs () -> [PFSong] {
//    let var
    var result: [PFSong] = []
    let query = PFQuery(className:PFSong.parseClassName())
    query.findObjectsInBackground { (objects: [PFObject]?, error: Error?) -> Void in
        if error != nil {
            print(error?.localizedDescription ?? "error happened while fetching from parse")
        } else if let objects = objects as? [PFSong]{
            result = objects
        }
    }
    return result
}

