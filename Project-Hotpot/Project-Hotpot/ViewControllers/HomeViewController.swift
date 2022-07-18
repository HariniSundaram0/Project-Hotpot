//
//  HomeViewController.swift
//  Project-Hotpot
//
//  Created by Harini Sundaram on 7/6/22.
//

import UIKit

class HomeViewController: UIViewController {
    var api_instance = SpotifyManager.shared()
    var currPlaylistName: String = ""
    @IBOutlet weak var card: UIView!
    
    let pauseButtonImage = UIImage(systemName: "pause.circle.fill")
    let playButtomImage = UIImage(systemName: "play.circle.fill")
    
    @IBOutlet weak var playButton: UIButton!
    
    @IBOutlet weak var songTitleLabel: UILabel!
    override func viewDidLoad() {
        self.resetSong()
        self.resetCard()
    }
    
    // MARK: - Actions
    
    @IBAction func didTapButton(_ sender: UIButton) {
        
        if (api_instance.lastPlayerState?.isPaused == true){
            //if already paused, play the song
            playSong()
        }
        else{
            //if already playing, pause the song
            pauseSong()
        }
    }
    
    func presentAlert(title: String, message: String, buttonTitle: String) {
        DispatchQueue.main.async {
            let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let action = UIAlertAction(title: buttonTitle, style: .default, handler: nil)
            controller.addAction(action)
            self.present(controller, animated: true)
        }
    }
    
    @IBAction func panCard(_ sender: UIPanGestureRecognizer) {
        let card = sender.view!
        let point = sender.translation(in: view)
        card.center = CGPoint(x:view.center.x + point.x, y:view.center.y + point.y)
        let width = view.frame.width
        
        if sender.state == UIGestureRecognizer.State.ended{
            
            if card.center.x < 75{
                // move off to left
                NSLog("moving to left")
                UIView.animate(withDuration: 1.0, animations:{
                    card.center = CGPoint(x: card.center.x - width/2, y: card.center.y)
                    
                })
                //TODO: CONSIDER STRUCTURE OF CODE, you repeate these 3 methods in both clauses of if statement
                self.saveCurrentSong()
                self.resetSong()
                self.resetCard()
                return
            }
            else if card.center.x > (width - 75){
                self.addToPlaylist()
                presentAlert(title: "Liked Song", message: "Added to Playlist: \(currPlaylistName)", buttonTitle: "Ok")
                UIView.animate(withDuration: 1.0, animations:{
                    card.center = CGPoint(x: card.center.x + width/2, y: card.center.y)
                })
                UIView.animate(withDuration: 0.2, delay: 2.0) {
                    self.resetSong()
                    self.resetCard()
                }
                return
            }
            self.resetCard()
        }
    }
    
    // MARK: - helper functions
    func addToPlaylist(){
        //extract pfsong object
        //TODO: consider using optional completion blocks maybe to avoid using repeat code?
        //TODO: Ask Toby for style advice on this function especially -> nested functions with completion handlers?
        if let curr_song = self.api_instance.lastPlayerState?.track{
            //add it to the database
            PFPlaylist.getPlaylistInBackground { currPlaylist, playlistError in
                if playlistError == nil, let currPlaylist = currPlaylist {
                    // extracted PFPlaylist object successfully
                    PFSong.saveSongInBackground(song: curr_song) {songObject, error in
                        if error == nil, let songObject = songObject{
                            //extracted PFSong Object successfully
                            PFPlaylist.addSongToPlaylistInBackground(song: songObject, playlist: currPlaylist) {success, error in
                                if (error == nil){
                                    //TODO: Fix weird optional wrapping text when printed
                                    NSLog("add to playlist: \(currPlaylist.name) successful")
                                    self.currPlaylistName = currPlaylist.name ?? "playlist_name"
                                }
                                else{
                                    NSLog("failed adding to playlist")
                                }
                            }
                        }
                        else{
                            NSLog("song wasn't saved properly")
                        }
                    }
                }
                else{
                    NSLog("playlist not fetched properly")
                }
            }
        }
    }
    
    func resetCard() {
        NSLog("resetting")
        UIView.animate(withDuration: 0.2, animations: {
            self.card.center = self.view.center
            self.songTitleLabel.text = self.api_instance.curr_song_label
        })
    }
    
    func playSong() {
        //resume the audio
        api_instance.appRemote.playerAPI?.resume()
        //change the button image
        self.playButton.setImage(pauseButtonImage, for:.normal)
    }
    
    func pauseSong() {
        //pause the audio
        api_instance.appRemote.playerAPI?.pause()
        //change the button image
        self.playButton.setImage(playButtomImage, for:.normal)
        
    }
    
    func saveCurrentSong(){
        if let curr_song = self.api_instance.lastPlayerState?.track{
            //add it to the database
            PFSong.saveSongInBackground(song: curr_song) {_, error in
                if error == nil {
                    NSLog("song saved ")
                }
                else{
                    NSLog("song wasn't saved properly")
                }
            }
        }
    }
    
    func resetSong() {
        // get URI from algorithm
        let alg_instance = SongAlgorithm()
        alg_instance.getRandomSong {uri, error in
            if error == nil, let uri = uri as? String?{
                let songURI = uri
                NSLog(uri ?? "nil uri call")
                self.api_instance.appRemote.contentAPI?.fetchContentItem(forURI: songURI!, callback: {songContent, error in
                    if (error != nil) {
                        NSLog(error?.localizedDescription ?? "error fetching song")
                    }
                    else if let songContent = songContent as? SPTAppRemoteContentItem
                    {
                        //play if no errors
                        self.api_instance.appRemote.playerAPI?.play(songContent)                    }
                })
            }
            else{
                NSLog("parse failed")
            }
        }
        //TODO: add completion block to resetcard -> have to manually move card a little to re-reset card.
        self.resetCard()
    }
}
