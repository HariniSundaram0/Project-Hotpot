//
//  randomSong.swift
//  Project-Hotpot
//
//  Created by Harini Sundaram on 7/11/22.
//

import Foundation
import Parse
import AFNetworking

class SongAlgorithm{
    var api_instance = SpotifyManager.shared()
    
    //TODO: CRASHES WHEN TOO MANY SONG REQUESTS, FOUND STACKOVERFLOW ALREADY
    func getRandomSong(completion: @escaping(Any?, Error?) -> Void){
        fetchSong { (dictionary, error) in
            if let error = error {
                NSLog("Fetching token request error \(error)")
                return completion(nil, error)
            }
            else{
                //beginning of series of conditional downcasting to parse
                guard let tracks = dictionary?["tracks"] as? [String:Any]?,
                      let items = tracks?["items"] as? [[String:Any]?],
                      let randomSong = items.randomElement(),
                      let randomURI = randomSong?["uri"]
                else{
                    NSLog("failed parsing random song dictionary response")
                    return completion(nil, error)
                }
                return completion(randomURI, error)
            }
        }
    }
    
    func getRandomGenre() -> String? {
        let genre = api_instance.genreSeedArray.randomElement()
        return genre
    }
    
    //TODO: SPLIT INTO SMALLER HELPER FUNCTIONS FOR SAKE OF REUSE. CONSIDER MOVING PARTS OF THIS INTO API MANAGER
    func fetchSong(completion: @escaping ([String: Any]?, Error?) -> Void) {
        //    I in the future will switch out this endpoint to access different search features
        // currently queries 50 songs from a random genre
        
        let randomOffset = String(Int.random(in: 1..<800))
        NSLog("randomOffset: \(randomOffset)")
        
        guard let genre = getRandomGenre(),
              let url = URL(string: "https://api.spotify.com/v1/search?q=" + "genre:" + genre + "&type=track&limit=50&offset=" + randomOffset),
              let accessToken = api_instance.appRemote.connectionParameters.accessToken
        else { return }
        NSLog("genre: \(genre)")
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let authorizationValue = "Bearer " + accessToken
        request.allHTTPHeaderFields = ["Authorization": authorizationValue,
                                       "Content-Type": "application/json",
                                       "Accept": "application/json"]
        //create task
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data,                              // is there data
                  let response = response as? HTTPURLResponse,  // is there HTTP response
                  (200 ..< 300) ~= response.statusCode,         // is statusCode 2XX
                  error == nil else {                           // was there no error, otherwise ...
                NSLog("Error fetching song \(error?.localizedDescription ?? "")")
                return completion(nil, error)
            }
            let responseObject = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
            completion(responseObject, nil)
        }
        task.resume()
    }
}

