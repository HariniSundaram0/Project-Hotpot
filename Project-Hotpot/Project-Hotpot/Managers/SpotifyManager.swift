//
//  SpotifyManager.swift
//  Project-Hotpot
//
//  Created by Harini Sundaram on 7/11/22.
//

import Foundation
import UIKit

class SpotifyManager: NSObject {
    //MARK: - Variables
    var currentSongLabel:String?
    var originalGenreSeeds: [String]
    var lastPlayerState: SPTAppRemotePlayerState?
    // MARK: - Spotify Authorization & Configuration
    var responseCode: String? {
        didSet {
            fetchAccessToken { result in
                switch result {
                case .success(let dictionary):
                    guard let accessToken = dictionary["access_token"] as? String else {
                        return
                    }
                    DispatchQueue.main.async {
                        self.appRemote.connectionParameters.accessToken = accessToken
                        self.appRemote.connect()
                    }
                    
                case .failure(let error):
                    NSLog("Fetching token request error \(error)")
                    return
                }
            }
        }
    }
    
    lazy var appRemote: SPTAppRemote = {
        let appRemote = SPTAppRemote(configuration: configuration, logLevel: .debug)
        appRemote.connectionParameters.accessToken = self.accessToken
        appRemote.delegate = self
        return appRemote
    }()
    
    var accessToken = UserDefaults.standard.string(forKey: accessTokenKey) {
        didSet {
            let defaults = UserDefaults.standard
            defaults.set(accessToken, forKey: accessTokenKey)
        }
    }
    
    lazy var configuration: SPTConfiguration = {
        let configuration = SPTConfiguration(clientID: spotifyClientId, redirectURL: redirectUri)
        // Set the playURI to a non-nil value so that Spotify plays music after authenticating
        // otherwise another app switch will be required, currently plays a 'silent track'
        configuration.playURI = "spotify:track:7p5bQJB4XsZJEEn6Tb7EaL"
        // Set these url's to your backend which contains the secret to exchange for an access token
        // You can use the provided ruby script spotify_token_swap.rb for testing purposes
        configuration.tokenSwapURL = URL(string: "http://localhost:1234/swap")
        configuration.tokenRefreshURL = URL(string: "http://localhost:1234/refresh")
        return configuration
    }()
    lazy var sessionManager: SPTSessionManager? = {
        let manager = SPTSessionManager(configuration: configuration, delegate: self)
        return manager
    }()
    
    private static var sharedSpotifyManager: SpotifyManager = {
        let SpotifyManager = SpotifyManager()
        return SpotifyManager
    }()
    
    // MARK: - Initializers
    //doing this way so that only 1 instance can be created
    override private init() {
        self.originalGenreSeeds = []
        NSLog("API Manager Initialized")
    }
    
    // MARK: - Accessors
    class func shared() -> SpotifyManager {
        return sharedSpotifyManager
    }
    
    // MARK: - Properties
    func update(playerState: SPTAppRemotePlayerState) {
        self.lastPlayerState = playerState
        self.currentSongLabel = playerState.track.name
    }
}

// MARK: - SPTAppRemoteDelegate
extension SpotifyManager: SPTAppRemoteDelegate {
    func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
        appRemote.playerAPI?.delegate = self
        appRemote.playerAPI?.subscribe(toPlayerState: { (success, error) in
            if let error = error {
                NSLog("Error subscribing to player state:" + error.localizedDescription)
            }
            //initialize genre list, once accessToken has been validated
            self.fetchGenreSeeds { result in
                switch result{
                case .success(let genreArray):
                    if let newGenreArray = genreArray["genres"] as? [String]{
                        self.originalGenreSeeds = newGenreArray
                    }
                case .failure(let error):
                    NSLog(error.localizedDescription)
                }
            }
        })
        fetchPlayerState()
    }
    
    func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: Error?) {
        lastPlayerState = nil
    }
    
    func appRemote(_ appRemote: SPTAppRemote, didFailConnectionAttemptWithError error: Error?) {
        lastPlayerState = nil
    }
}

// MARK: - SPTAppRemotePlayerAPIDelegate
extension SpotifyManager: SPTAppRemotePlayerStateDelegate {
    func playerStateDidChange(_ playerState: SPTAppRemotePlayerState) {
        debugPrint("Spotify Track name: %@", playerState.track.name)
        update(playerState: playerState)
    }
}

// MARK: - SPTSessionManagerDelegate
extension SpotifyManager: SPTSessionManagerDelegate {
    func sessionManager(manager: SPTSessionManager, didFailWith error: Error) {
        if error.localizedDescription == "The operation couldn’t be completed. (com.spotify.sdk.login error 1.)" {
            NSLog("AUTHENTICATE with WEBAPI")
        }
    }
    
    func sessionManager(manager: SPTSessionManager, didRenew session: SPTSession) {}
    
    func sessionManager(manager: SPTSessionManager, didInitiate session: SPTSession) {
        appRemote.connectionParameters.accessToken = session.accessToken
        appRemote.connect()
        NSLog("session connected")
    }
}

// MARK: - Networking
extension SpotifyManager {
    func makeSpotifyRequest (request: URLRequest, completion: @escaping (_ result: Result<[String: Any], Error>) -> Void) {
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data,                              // is there data
                  let response = response as? HTTPURLResponse,  // is there HTTP response
                  (200 ..< 300) ~= response.statusCode,         // is statusCode 2XX
                  error == nil
            else {// was there no error, otherwise ...
                if let error = error {
                    NSLog("Error fetching token \(error.localizedDescription)")
                    return completion(.failure(error))
                }
                //if the error is nil, then technically another error could have happened
                return completion(.failure(CustomError.unexpected))
            }
            if let responseObject = try? JSONSerialization.jsonObject(with: data) as? [String: Any]{
                completion(.success(responseObject))
            }
            else {
                completion(.failure(CustomError.nilNetworkResponse))
            }
        }
        task.resume()
    }
    
    func createRequest(url:URL, completion: @escaping (_ result: Result<[String: Any], Error>) -> Void) {
        guard let accessToken = self.appRemote.connectionParameters.accessToken
        else {
            return completion(.failure(CustomError.nilAccessToken))
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let bearer_string = "Bearer " + accessToken
        request.allHTTPHeaderFields = ["Authorization": bearer_string,
                                       "Content-Type": "application/json",
                                       "Accept": "application/json"]
        
        makeSpotifyRequest(request: request, completion: completion)
        
    }
    
    func fetchAudioFeaturesFromTracks (for trackIDs: [String], completion: @escaping (_ result: Result<[String: Any], Error>) -> Void) {
        let trackIdsString = trackIDs.joined(separator: ",")
        guard let url = URL(string: "https://api.spotify.com/v1/audio-features?ids=" + trackIdsString) else {
            return completion(.failure(CustomError.invalidURL))
        }
        createRequest(url: url, completion: completion)
    }
    
    func fetchNSongsFromGenre(limit: Int, genre:String, offset: Int, completion: @escaping (_ result: Result<[String: Any], Error>) -> Void) {
        //TODO: add check to make sure limit <= 50
        guard let url = URL(string: "https://api.spotify.com/v1/search?q=" + "genre:" + genre + "&type=track&limit=" + String(limit) + "&offset=" + String(offset)) else {
            return completion(.failure(CustomError.invalidURL))
        }
        createRequest(url: url, completion: completion)
    }
    
    func fetchGenreSeeds(completion: @escaping (_ result: Result<[String: Any], Error>) -> Void) {
        guard let url = URL(string: "https://api.spotify.com/v1/recommendations/available-genre-seeds") else {
            return completion(.failure(CustomError.invalidURL))
        }
        createRequest(url: url, completion: completion)
    }
    
    func fetchAccessToken(completion: @escaping (_ result: Result<[String: Any], Error>) -> Void) {
        guard let url = URL(string: "https://accounts.spotify.com/api/token")
        else {
            return completion(.failure(CustomError.unexpected))
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let spotifyAuthKey = "Basic \((spotifyClientId + ":" + spotifyClientSecretKey).data(using: .utf8)!.base64EncodedString())"
        request.allHTTPHeaderFields = ["Authorization": spotifyAuthKey,
                                       "Content-Type": "application/x-www-form-urlencoded"]
        
        var requestBodyComponents = URLComponents()
        let scopeAsString = stringScopes.joined(separator: " ")
        
        requestBodyComponents.queryItems = [
            URLQueryItem(name: "client_id", value: spotifyClientId),
            URLQueryItem(name: "grant_type", value: "authorization_code"),
            URLQueryItem(name: "code", value: responseCode!),
            URLQueryItem(name: "redirect_uri", value: redirectUri.absoluteString),
            URLQueryItem(name: "code_verifier", value: ""), // not currently used
            URLQueryItem(name: "scope", value: scopeAsString),
        ]
        
        request.httpBody = requestBodyComponents.query?.data(using: .utf8)
        makeSpotifyRequest(request: request, completion: completion)
    }
    
    func fetchArtwork(for track: SPTAppRemoteTrack, completion: @escaping (_ result: Result<UIImage, Error>) -> Void) {
        appRemote.imageAPI?.fetchImage(forItem: track, with: CGSize.zero, callback: { [weak self] (image, error) in
            if let error = error {
                NSLog("Error fetching track image: " + error.localizedDescription)
                completion(.failure(error))
            }
            else if let image = image as? UIImage {
                completion(.success(image))
            }
        })
    }
    
    
    func fetchPlayerState() {
        appRemote.playerAPI?.getPlayerState({ [weak self] (playerState, error) in
            if let error = error {
                NSLog("Error getting player state:" + error.localizedDescription)
            } else if let playerState = playerState as? SPTAppRemotePlayerState {
                self?.update(playerState: playerState)
                
            }
        })
    }
}


