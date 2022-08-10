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
    var songIndex: Int?
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
    
    @IBAction func didTapNextSong(_ sender: Any) {
        guard var index = self.songIndex,
              let length = self.songArray?.count else {
            return
        }
        if (index + 1) >= length {
            index = 0
        } else {
            index += 1
        }
        self.songIndex = index
        self.tableView(self.tableView, didSelectRowAt: IndexPath(row: index, section: 0))
    }
    
    @IBAction func didTapPrevSong(_ sender: Any) {
        guard var index = self.songIndex,
              let length = self.songArray?.count else {
            return
        }
        if (index - 1) < 0 {
            index = length - 1
        } else {
            index -= 1
        }
        self.songIndex = index
        self.tableView(self.tableView, didSelectRowAt: IndexPath(row: index, section: 0))
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let currentSong = songArray?[indexPath.row] else {
            NSLog("failed accessing song from indexPath")
            return
        }
        self.tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
        self.songIndex = indexPath.row
        let uri = currentSong.uri
        self.playNewSong(uri: uri)
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
    
    func removeSongFromPlaylist(song: PFSong) {
        guard let currentPlaylist = self.currentPlaylist else {
            return
        }
        PFPlaylist.removeSongFromPlaylistInBackground(song: song, playlist: currentPlaylist) { result in
            switch result{
            case .success(_):
                NSLog("Successfully removed song")
                self.retreiveSongs()
            case .failure(let error):
                NSLog(error.localizedDescription)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        guard let currentSong = self.songArray?[indexPath.row] else {
            NSLog("can't retrieve song")
            return nil
        }
        let action = UIContextualAction(style: .normal,
                                        title: "Remove") { [weak self] (action, view, completionHandler) in
            self?.removeSongFromPlaylist(song: currentSong)
            completionHandler(true)
        }
        action.backgroundColor = .systemRed
        return UISwipeActionsConfiguration(actions: [action])
    }
}
