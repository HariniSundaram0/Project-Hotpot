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
    var danceability: Float
    var energy: Float
    var tempo: Float
    var key: Float
}
