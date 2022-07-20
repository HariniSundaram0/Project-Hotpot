//
//  PlaylistViewController.swift
//  Project-Hotpot
//
//  Created by Harini Sundaram on 7/18/22.
//

import UIKit

class PlaylistViewController: UIViewController {
    
    //will be used for table view of playlists
    var playlistArray: [PFPlaylist]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.retrievePlaylists()
    }
    
    //retrieve playlist objects from parse, was used to test playlist and history functions
    func retrievePlaylists() {
        PFPlaylist.getAllPlaylistsInBackground {playlistArray, playlistError in
            if playlistError == nil, let playlistArray = playlistArray {
                self.playlistArray = playlistArray
                // extracted PFPlaylist object successfully
            }
        }
    }
}
