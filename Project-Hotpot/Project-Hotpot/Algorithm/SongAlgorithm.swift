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
    
func getRandomSong() -> String{
    
    fetchSong { (dictionary, error) in
        if let error = error {
            print("Fetching token request error \(error)")
            return
        }
        else{
            NSLog("success :)")
            //for now printing dictionary for sake of testing, in next commit will swap out to access the track uri and return that instead of hardcoding
            print(dictionary)
            
        }
    }
    return "spotify:track:20I6sIOMTCkB6w7ryavxtO"
}

//TODO: SPLIT INTO SMALLER HELPER FUNCTIONS FOR SAKE OF REUSE. CONSIDER MOVING PARTS OF THIS INTO API MANAGER
func fetchSong(completion: @escaping ([String: Any]?, Error?) -> Void) {
    let api_instance = APIManager.shared()
//    I in the future will switch out this endpoint to access different search features
    let url = URL(string: "https://api.spotify.com/v1/me/tracks")!
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    if api_instance.appRemote.connectionParameters.accessToken == nil {
        NSLog("access token is nil")
    }
    //using force unwrap because I am sure that the accesstoken is not nil, otherwise this function wouldn't be called
    var new_string = "Bearer " + api_instance.appRemote.connectionParameters.accessToken!
    request.allHTTPHeaderFields = ["Authorization": new_string,
                                   "Content-Type": "application/json"]
    //create task
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        guard let data = data,                              // is there data
              let response = response as? HTTPURLResponse,  // is there HTTP response
              (200 ..< 300) ~= response.statusCode,         // is statusCode 2XX
              error == nil else {                           // was there no error, otherwise ...
                  print("Error fetching token \(error?.localizedDescription ?? "")")
                  return completion(nil, error)
              }
        let responseObject = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
        completion(responseObject, nil)
    }
    task.resume()
}

//this is a testing function, to make sure that I can query like I want to going forward

func getPreviousSongs () -> [PFSong] {
    var result: [PFSong] = []
    let query = PFQuery(className:PFSong.parseClassName())
    //we only want data from the current user
    query.whereKey("user", equalTo: PFUser.current())
    query.findObjectsInBackground { (objects: [PFObject]?, error: Error?) -> Void in
        if error != nil {
            print(error?.localizedDescription ?? "error happened while fetching from parse")
        } else if let objects = objects as? [PFSong]{
            result = objects
            NSLog("found %i number of queries", objects.count)
        }
    }
    return result
}
func print_songs(songs: [PFSong]) -> Void{
    NSLog("printing now")
    for song in songs{
        NSLog(song.name)
    }
    }
}

