//
//  GenreQueue.swift
//  Project-Hotpot
//
//  Created by Harini Sundaram on 7/26/22.
//

import Foundation
//implemented via singly linked array for O(1) enqueue and dequeue
public struct GenreQueue {
    var head: Genre?
    var rear: Genre?
        
    var isEmpty: Bool {
        return head == nil
    }
}

extension GenreQueue{
    mutating private func push (_ genreName: String){
        head = Genre(genreName: genreName, nextNode: head)
        if rear == nil {
            rear = head
        }
    }
    mutating func enqueue (_ genreName: String){
        if isEmpty{
            self.push(genreName)
            return
        }
        rear?.next = Genre(genreName: genreName, nextNode: head)
        rear = rear?.next
    }
    
    mutating func dequeue() -> Genre? {
        head = head?.next
        if isEmpty{
            rear = nil
        }
        return head
    }
    
     mutating func enqueueFromList(genres: [String]){
        for genre in genres {
            enqueue(genre)
        }
    }
    
    //used for debuging
    func printQueue() {
        var currentNode = head
        while (currentNode?.next != rear) {
            print(currentNode?.name)
            currentNode = currentNode?.next
        }
    }
}




