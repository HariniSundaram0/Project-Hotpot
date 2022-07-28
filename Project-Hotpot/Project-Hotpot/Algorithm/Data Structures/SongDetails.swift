//
//  SongDetails.swift
//  Project-Hotpot
//
//  Created by Harini Sundaram on 7/27/22.
//

import Foundation

class SongDetails: NSObject{
    var uri: String
    var id: String
    var danceability: NSNumber
    var energy: NSNumber
    var tempo: NSNumber
    var key: NSNumber
    
    init(uri: String, id: String, danceability: NSNumber, energy: NSNumber, tempo: NSNumber, key: NSNumber) {
        self.uri = uri
        self.id = id
        self.danceability = danceability
        self.energy = energy
        self.tempo = tempo
        self.key = key
        NSLog("success!")
    }
    
    //store in cache
    //once you choose a song to play -> add to history by getting storing the spt track -> saving normally
    //also store the parse object in a variabl
    
    //add attribute object to attribute list for scoring metrics
    
    
    //store last K songs attributes --> some object which contains PFSong
}
