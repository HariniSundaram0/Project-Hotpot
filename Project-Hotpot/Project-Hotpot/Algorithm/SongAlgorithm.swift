//
//  randomSong.swift
//  Project-Hotpot
//
//  Created by Harini Sundaram on 7/11/22.
//

import Foundation
import Parse
import AFNetworking

class songAlgorithm{    
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
                    NSLog("failed parse")
                    return completion(nil, error)
                }
                return completion(randomURI, error)
            }
        }
    }
    
    //TODO: SPLIT INTO SMALLER HELPER FUNCTIONS FOR SAKE OF REUSE. CONSIDER MOVING PARTS OF THIS INTO API MANAGER
    func fetchSong(completion: @escaping ([String: Any]?, Error?) -> Void) {
        let api_instance = SpotifyManager.shared()
        //    I in the future will switch out this endpoint to access different search features
        // currently just gets queries for 50 songs that contain an A
        let url = URL(string: "https://api.spotify.com/v1/search?q=a&type=track&limit=50")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        if api_instance.appRemote.connectionParameters.accessToken == nil {
            NSLog("access token is nil")
        }
        //using force unwrap because function called only when accessToken exists
        var new_string = "Bearer " + api_instance.appRemote.connectionParameters.accessToken!
        request.allHTTPHeaderFields = ["Authorization": new_string,
                                       "Content-Type": "application/json",
                                       "Accept": "application/json"]
        //create task
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data,                              // is there data
                  let response = response as? HTTPURLResponse,  // is there HTTP response
                  (200 ..< 300) ~= response.statusCode,         // is statusCode 2XX
                  error == nil else {                           // was there no error, otherwise ...
                NSLog("Error fetching token \(error?.localizedDescription ?? "")")
                return completion(nil, error)
            }
            let responseObject = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
            completion(responseObject, nil)
        }
        task.resume()
    }
    
    //this is a testing function, to make sure that I can query like I want to going forward
    //use completion function in order to access objects!
    func getPreviousSongs (completion: @escaping([PFSong]?, Error?) -> Void){
        let query = PFQuery(className:PFSong.parseClassName())
        //we only want data from the current user
        query.whereKey("user", equalTo: PFUser.current())
        query.findObjectsInBackground {(objects: [PFObject]?, error: Error?) -> Void in
            if error != nil {
                NSLog(error?.localizedDescription ?? "error happened while fetching from parse")
                completion(nil, error)
            } else if let objects = objects as? [PFSong]{
                NSLog("found %i number of queries", objects.count)
                completion(objects, nil)
            }
        }
    }
}

