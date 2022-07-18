//
//  PlaylistViewController.swift
//  Project-Hotpot
//
//  Created by Harini Sundaram on 7/18/22.
//

import UIKit

class PlaylistViewController: UIViewController {
    
    @IBOutlet weak var playlistNameField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func didTapCreate(_ sender: Any) {
        //TODO: create edge case checks: empty text fields, etc.
        PFPlaylist.createPlaylistInBackground(name: playlistNameField.text ?? "test123") {createdPlaylist in
            if (createdPlaylist == true){
                NSLog("success")
            }
            else{
                NSLog("playlist creation failed")
            }
        }
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
