//
//  SongDetails.swift
//  Project-Hotpot
//
//  Created by Harini Sundaram on 7/27/22.
//

import Foundation

class SongDetails: NSObject{
    static public var numericalAttributes = ["danceability","energy","tempo","key"]
    
    var uri: String
    var id: String
    var danceability: Float
    var energy: Float
    var tempo: Float
    var key: Float
    
    init(uri: String, id: String, danceability: NSNumber, energy: NSNumber, tempo: NSNumber, key: NSNumber) {
        self.uri = uri
        self.id = id
        self.danceability = danceability.floatValue
        self.energy = energy.floatValue
        self.tempo = tempo.floatValue
        self.key = key.floatValue
    }
    //for debugging
    func printSong(){
        NSLog("object with \(id), danceability: \(self.danceability) energy : \(self.energy)")
    }
}
