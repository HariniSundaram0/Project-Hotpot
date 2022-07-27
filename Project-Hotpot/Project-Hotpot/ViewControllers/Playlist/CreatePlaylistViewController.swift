//
//  CreatePlaylistViewController.swift
//  Project-Hotpot
//
//  Created by Harini Sundaram on 7/20/22.
//

import UIKit

class CreatePlaylistViewController: ViewController {
    
    @IBOutlet weak var playlistNameField: UITextField!
    
    @IBAction func didTapCreate(_ sender: Any) {
        if (playlistNameField.hasText == false){
            presentAlert(title: "Oops!", message: "Add a name for your playlist", buttonTitle: "Ok")
            return
        }
        guard let user = PFUser.current(),
              let playlistName = playlistNameField.text else {
            return
        }
        
        PFPlaylist.createPlaylistInBackground(user: user, name: playlistName) { result in
            switch result {
            case .success(_):
                self.dismiss(animated: true)
            case .failure(let error):
                NSLog(error.localizedDescription)
            }
        }
    }
    
    @IBAction func didTapClose(_ sender: Any) {
        self.dismiss(animated: true)
    }
}
