//
//  Genre.swift
//  Project-Hotpot
//
//  Created by Harini Sundaram on 7/26/22.
//

import Foundation
//node object for Genre Queue implementation
class Genre: Equatable {
    static func == (lhs: Genre, rhs: Genre) -> Bool {
        lhs.name == rhs.name
    }
    
    var name: String
    var next: Genre?
    
    init (genreName: String, nextNode: Genre?) {
        self.name = genreName
        self.next = nextNode
    }
    
}
