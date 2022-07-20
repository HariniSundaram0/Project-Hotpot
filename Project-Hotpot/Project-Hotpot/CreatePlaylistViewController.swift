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
        PFPlaylist.createPlaylistInBackground(user: PFUser.current()!, name: playlistNameField.text ?? "test123") {playlist in
            if let playlist = playlist {
                NSLog("success")
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
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
