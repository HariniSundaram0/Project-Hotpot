//
//  Errors.swift
//  Project-Hotpot
//
//  Created by Harini Sundaram on 7/26/22.
//

import Foundation

//MARK: Errors:
public enum CustomError: Error {
    // Throw when an accessToken is nil
    case nilAccessToken
    
    case nilNetworkResponse
    
    case invalidURL
    
    case failedResponseParsing
    
    case invalidCacheKey
    //generic
    case unexpected
    
    case nilSpotifyState
    
    case nilPFUser
    //add more custom errors as seen fit
}
extension CustomError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .nilAccessToken:
            return NSLocalizedString("Access Token is nil", comment: "")
            
        case .unexpected:
            return NSLocalizedString("An unexpected error occurred.", comment: "")
            
        case .nilNetworkResponse:
            return NSLocalizedString("response from network request was nil", comment: "")
            
        case .failedResponseParsing:
            return NSLocalizedString("error occurred while parsing network response", comment: "")
            
        case .invalidURL:
            return NSLocalizedString("couldn't create URL for network request", comment: "")
            
        case .invalidCacheKey:
            return NSLocalizedString("Cache does not contain this key", comment: "")
            
        case .nilSpotifyState:
            return NSLocalizedString("Spotify last state wasn't updated correctly", comment: "")
            
        case .nilPFUser:
            return NSLocalizedString("Unable to access current PFuser", comment: "")
            
        }
    }
}
