//
//  SongScore.swift
//  Project-Hotpot
//
//  Created by Harini Sundaram on 7/28/22.
//

import Foundation
class SongScoreManager: NSObject {
    //keep list of last K songs
    let K = 10
    //count of the numerical attributes that will be used in calculations
    let ATTRIBUTECOUNT = 4
    // TODO: removing head to maintain K may be inefficient, consider switching to linked list implementation?
    private var lastKSongDetails: [SongDetails] = []
    
    var movingAverages:[String:Float] = [:]
    
    private static var scoreManager: SongScoreManager = { return SongScoreManager() }()
    
    // MARK: - Accessors
    class func shared() -> SongScoreManager {
        return scoreManager
    }
    
     func calculateMovingAverages() {
        //TODO: Figure out less repetitive way to do this
        //iterate through each stored song detail
        self.movingAverages["danceability"] = (self.lastKSongDetails.map {song in
            song.danceability}).reduce(0, +)
        
        self.movingAverages["energy"] = (self.lastKSongDetails.map {song in
            song.energy}).reduce(0, +)
        
        self.movingAverages["tempo"] = (self.lastKSongDetails.map {song in
            song.tempo}).reduce(0, +)
        
        self.movingAverages["key"] = (self.lastKSongDetails.map {song in
            song.tempo}).reduce(0, +)
    }
    
    func removeOldestSongFromSongScores() {
         self.lastKSongDetails.remove(at: 0)
    }
    func addSongToLastKSongDetails(newSong: SongDetails) {
         if self.lastKSongDetails.count >= K{
             self.removeOldestSongFromSongScores()
        }
         self.lastKSongDetails.append(newSong)
    }
    
     func calculatePercentDifference(num1: Float, num2: Float) -> Float{
        return abs((num1 - num2)) / ((num1 + num2)/2)
    }
    
     func calculateSongScore(song:SongDetails) -> Float {
        self.calculateMovingAverages()
        var attributeArray: [Float] = []
        attributeArray.append(calculatePercentDifference(num1: song.danceability, num2: movingAverages["danceability"] ?? 0))
        
        attributeArray.append(self.calculatePercentDifference(num1: song.energy, num2: movingAverages["energy"] ?? 0))
        
        attributeArray.append(self.calculatePercentDifference(num1: song.tempo, num2: movingAverages["tempo"] ?? 0))
        
        attributeArray.append(self.calculatePercentDifference(num1: song.danceability, num2: movingAverages["key"] ?? 0))
        
        return (attributeArray.reduce(0.0,+)) / Float(ATTRIBUTECOUNT)
        
    }
    //function that iterates through list of SongDetail Object to find max -> return songObject
    
    func calculateSongScores(songs: [SongDetails]) -> [SongDetails : Float] {
        var resultDictionary:[SongDetails : Float] = [:]
        
        for song in songs {
            let score = self.calculateSongScore(song: song)
            resultDictionary[song] = score
        }
        print("cache song scores: \(resultDictionary)")
        return resultDictionary
    }
    
    func findMaxSongScore(songs: [SongDetails]) -> SongDetails? {
        let scoreDictionary = self.calculateSongScores(songs: songs)
        
        let maxElement = scoreDictionary.max { $0.value <= $1.value }
        
        if let newSong = maxElement?.key {
            self.addSongToLastKSongDetails(newSong: newSong)
        }
        NSLog("choosing cache song \(maxElement?.key) with score \(maxElement?.value)")
        return maxElement?.key
    }
}
