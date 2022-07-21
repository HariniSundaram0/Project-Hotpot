//
//  CreatePlaylistViewController.swift
//  Project-Hotpot
//
//  Created by Harini Sundaram on 7/20/22.
//

import UIKit

class CreatePlaylistViewController: UIViewController {
    
    @IBOutlet weak var playlistNameField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func didTapCreate(_ sender: Any) {
        //TODO: create edge case checks: empty text fields, etc.
        guard let user = PFUser.current(),
              let playlistName = playlistNameField.text
        else { return }
        PFPlaylist.createPlaylistInBackground(user: user, name: playlistName) { playlist in
            if let playlist = playlist {
                NSLog("created new playlist")
                //close popup
                self.dismiss(animated: true)
            }
            else{
                NSLog("playlist creation failed")
            }
        }
    }
    
    @IBAction func didTapClose(_ sender: Any) {
        self.dismiss(animated: true)
    }
}
