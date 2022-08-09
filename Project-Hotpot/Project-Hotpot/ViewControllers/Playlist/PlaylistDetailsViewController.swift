//
//  PlaylistDetailsViewController.swift
//  Project-Hotpot
//
//  Created by Harini Sundaram on 7/21/22.
//

import UIKit

class PlaylistDetailsViewController: MediaViewController, UITableViewDelegate, UITableViewDataSource {
    var currentPlaylist: PFPlaylist?
    var songArray: [PFSong]?
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var playlistName: UILabel!
    @IBOutlet weak var tableView: UITableView!
    var refreshControl: UIRefreshControl?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.refreshControl = UIRefreshControl()
        self.tableView.refreshControl = self.refreshControl
        self.refreshControl?.addTarget(self, action:
                                        #selector(self.retreiveSongs),
                                       for: .valueChanged)
        self.playlistName.text = currentPlaylist?.name
        self.retreiveSongs()
        self.scheduledTimerWithTimeInterval()
    }
    
    @objc func retreiveSongs() {
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
                    self.refreshControl?.endRefreshing()
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let currentSong = songArray?[indexPath.row] else {
            NSLog("failed accessing song from indexPath")
            return
        }
        let uri = currentSong.uri
        self.playNewSong(uri: uri, button: self.playButton)
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
    
    @IBAction func didTapPlayButton(_sender: UIButton) {
        self.didTapMediaPlayButton(button: _sender)
    }
}
