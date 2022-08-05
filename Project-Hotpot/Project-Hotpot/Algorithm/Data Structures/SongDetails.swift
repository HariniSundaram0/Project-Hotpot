//
//  SongDetails.swift
//  Project-Hotpot
//
//  Created by Harini Sundaram on 7/27/22.
//

import Foundation
//chose not to wrap it within a class to prevent unneccessary decoding/encoding
struct SongDetails: Codable, Hashable {
    var uri: String
    var id: String
    var acousticness: Double
    var danceability: Double
    var energy: Double
    var instrumentalness: Double
    var liveness: Double
    var loudness: Double
    var speechiness: Double
    var tempo: Double
    var key: Double
    var valence: Double
}
