//
//  PlaylistViewController.swift
//  Project-Hotpot
//
//  Created by Harini Sundaram on 7/18/22.
//

import UIKit

class PlaylistViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    //used for table view of playlists
    var playlistArray: [PFPlaylist]?
    
    override func viewDidLoad() {
        //TODO: add loading button when getting playlists from database
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.retrievePlaylists()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = self.tableView.dequeueReusableCell(withIdentifier: "PlaylistTableViewCell", for: indexPath) as? PlaylistTableViewCell,
              let playlistArray = playlistArray
        else{
    //TODO: since this function requires a UITableViewCell, should I return a generic table view cell?
            return UITableViewCell()
        }
        let currentPlaylist = playlistArray[indexPath.row]
        cell.playlistName.text = currentPlaylist.name
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playlistArray?.count ?? 0
    }
    
    //retrieve playlist objects from parse
    func retrievePlaylists() {
        PFPlaylist.getAllPlaylistsInBackground {playlistArray, playlistError in
            if playlistError == nil, let playlistArray = playlistArray {
                self.playlistArray = playlistArray
                self.tableView.reloadData()
            }
        }
    }
}
