//
//  PlaylistViewController.swift
//  Project-Hotpot
//
//  Created by Harini Sundaram on 7/18/22.
//

import UIKit

class PlaylistViewController: UIViewController {
    
    @IBOutlet weak var playlistNameField: UITextField!
    //will be used for table view of playlists
    var playlistArray: [PFPlaylist]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.retrievePlaylists()
    }
    
    @IBAction func didTapCreate(_ sender: Any) {
        //TODO: create edge case checks: empty text fields, etc.
        PFPlaylist.createPlaylistInBackground(user: PFUser.current()!, name: playlistNameField.text ?? "test123") {playlist in
            if let playlist = playlist {
                NSLog("success")
            }
            else{
                NSLog("playlist creation failed")
            }
        }
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
