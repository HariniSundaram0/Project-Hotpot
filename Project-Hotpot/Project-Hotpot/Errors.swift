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
    
    case failedResponseParsing
    //generic
    case unexpected
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
        }
    }
}
