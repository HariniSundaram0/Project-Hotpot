//
//  PlaylistDetailsViewController.swift
//  Project-Hotpot
//
//  Created by Harini Sundaram on 7/21/22.
//

import UIKit

class PlaylistDetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var currentPlaylist: PFPlaylist?
    var songArray: [PFSong]?
    @IBOutlet weak var playlistName: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSLog("in details view")
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.playlistName.text = currentPlaylist?.name
        
        guard let currentPlaylist = currentPlaylist else {
            NSLog("current playlist is nil")
            return
        }
        PFPlaylist.getAllSongsFromPlaylist(playlist: currentPlaylist, completion: { songArray, error in
            if let error = error {
                NSLog("error occurred fetching songs: \(error)")
            }
            else{
                //songArray may be empty
                self.songArray = songArray
                self.tableView.reloadData()
                NSLog("length of song Array :\(songArray?.count)")
            }
        })
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = self.tableView.dequeueReusableCell(withIdentifier: "SongTableViewCell", for: indexPath) as? SongTableViewCell,
              let songArray = songArray
        else{
            return UITableViewCell()
        }
        let currentSong = songArray[indexPath.row]
        cell.songTitleLabel.text = currentSong.name
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songArray?.count ?? 0
    }
    
    
}
