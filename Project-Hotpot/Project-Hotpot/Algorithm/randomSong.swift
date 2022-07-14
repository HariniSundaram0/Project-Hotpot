//
//  randomSong.swift
//  Project-Hotpot
//
//  Created by Harini Sundaram on 7/11/22.
//

import Foundation
import Parse

var previous_array: [PFSong] = []

func getRandomSong() -> String{
    return "spotify:track:20I6sIOMTCkB6w7ryavxtO"
}

//this is a testing function, to make sure that I can query like I want to going forward

func getPreviousSongs() {
    
    let query = PFQuery(className:PFSong.parseClassName())
    query.findObjectsInBackground { (objects: [PFObject]?, error: Error?) -> Void in
        if error != nil {
            print(error?.localizedDescription)
        } else if let objects = objects as? [PFSong]{
            //I'm making sure I am able to access the PFSong objects
            for obj in objects{
                NSLog(obj.name)
            }

        }
 
    }
}

