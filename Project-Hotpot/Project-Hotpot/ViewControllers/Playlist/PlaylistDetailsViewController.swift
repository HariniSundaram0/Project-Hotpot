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
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.playlistName.text = currentPlaylist?.name
        
        guard let currentPlaylist = currentPlaylist else {
            NSLog("current playlist is nil")
            return
        }
        PFPlaylist.getAllSongsFromPlaylist(playlist: currentPlaylist) { result in
            switch result {
            case .failure(let error):
                NSLog("error fetching songs: \(error.localizedDescription)")
            case .success(let songArray):
                self.songArray = songArray
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
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
