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
    let ATTRIBUTECOUNT = 10
    // TODO: removing head to maintain K may be inefficient, consider switching to linked list implementation?
    private var lastKSongDetails: [SongDetails] = []
    let numericalAttributes = ["acousticness", "danceability", "energy","instrumentalness","liveness","loudness","speechiness","tempo","key","valence"]
    
    var movingAverages:[String:Double] = [:]
    
    private static var scoreManager: SongScoreManager = { return SongScoreManager() }()
    
    // MARK: - Accessors
    class func shared() -> SongScoreManager {
        return scoreManager
    }
    
    func calculateMovingAverages() {
        //TODO: Figure out less repetitive way to do this
        //iterate through each stored song detail
        self.movingAverages["danceability"] = (self.lastKSongDetails.map {$0.danceability}).reduce(0, +)
        self.movingAverages["energy"] = (self.lastKSongDetails.map {$0.energy}).reduce(0, +)
        self.movingAverages["tempo"] = (self.lastKSongDetails.map {$0.tempo}).reduce(0, +)
        self.movingAverages["key"] = (self.lastKSongDetails.map {$0.key}).reduce(0, +)
        self.movingAverages["acousticness"] = (self.lastKSongDetails.map {$0.acousticness}).reduce(0, +)
        self.movingAverages["instrumentalness"] = (self.lastKSongDetails.map {$0.instrumentalness}).reduce(0, +)
        self.movingAverages["liveness"] = (self.lastKSongDetails.map {$0.liveness}).reduce(0, +)
        self.movingAverages["loudness"] = (self.lastKSongDetails.map {$0.loudness}).reduce(0, +)
        self.movingAverages["speechiness"] = (self.lastKSongDetails.map {$0.speechiness}).reduce(0, +)
        self.movingAverages["valence"] = (self.lastKSongDetails.map {$0.valence}).reduce(0, +)
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
    
    func calculatePercentDifference(num1: Double, num2: Double) -> Double{
        return abs((num1 - num2)) / ((num1 + num2)/2)
    }
    
    func calculateSongScore(song:SongDetails) -> Double {
        self.calculateMovingAverages()
        var attributeArray: [Double] = []
    
        attributeArray.append(calculatePercentDifference(num1: song.danceability, num2: movingAverages["danceability"] ?? 0))
        attributeArray.append(self.calculatePercentDifference(num1: song.energy, num2: movingAverages["energy"] ?? 0))
        attributeArray.append(self.calculatePercentDifference(num1: song.tempo, num2: movingAverages["tempo"] ?? 0))
        attributeArray.append(self.calculatePercentDifference(num1: song.key, num2: movingAverages["key"] ?? 0))
        attributeArray.append(self.calculatePercentDifference(num1: song.acousticness, num2: movingAverages["acousticness"] ?? 0))
        attributeArray.append(self.calculatePercentDifference(num1: song.instrumentalness, num2: movingAverages["instrumentalness"] ?? 0))
        attributeArray.append(self.calculatePercentDifference(num1: song.loudness, num2: movingAverages["loudness"] ?? 0))
        attributeArray.append(self.calculatePercentDifference(num1: song.speechiness, num2: movingAverages["speechiness"] ?? 0))
        attributeArray.append(self.calculatePercentDifference(num1: song.valence, num2: movingAverages["valence"] ?? 0))
        attributeArray.append(self.calculatePercentDifference(num1: song.liveness, num2: movingAverages["liveness"] ?? 0))
        
        return (attributeArray.reduce(0.0,+)) / Double(ATTRIBUTECOUNT)
        
    }
    //function that iterates through list of SongDetail Object to find max -> return songObject
    
    func calculateSongScores(songs: [SongDetails]) -> [SongDetails : Double] {
        var resultDictionary:[SongDetails : Double] = [:]
        
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
        NSLog("choosing cache song \(maxElement?.key) with maximum score \(maxElement?.value)")
        return maxElement?.key
    }
    
    func findMinSong(songs: [SongDetails]) -> SongDetails? {
        let scoreDictionary = self.calculateSongScores(songs: songs)
        let minElement = scoreDictionary.min { $0.value <= $1.value }
        
        if let newSong = minElement?.key {
            self.addSongToLastKSongDetails(newSong: newSong)
        }
        NSLog("choosing cache song \(minElement?.key) with minimum score \(minElement?.value)")
        return minElement?.key
        
    }
}
