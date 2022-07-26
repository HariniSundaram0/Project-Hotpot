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
    
    override func viewDidAppear(_ animated: Bool) {
        self.retrievePlaylists()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = self.tableView.dequeueReusableCell(withIdentifier: "PlaylistTableViewCell", for: indexPath) as? PlaylistTableViewCell,
              let playlistArray = playlistArray
        else{
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
        PFPlaylist.getNPlaylistsInBackground (limit:nil, completion: {playlistArray, playlistError in
            if playlistError == nil, let playlistArray = playlistArray {
                self.playlistArray = playlistArray
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let newSender = sender as? UITableViewCell,
              let indexPath = self.tableView.indexPath(for: newSender),
              let playlistArray = playlistArray,
              let nextController = segue.destination as? PlaylistDetailsViewController else {
            return
        }
        let playlistToPass = playlistArray[indexPath.row]
        nextController.currentPlaylist = playlistToPass
    }
}
