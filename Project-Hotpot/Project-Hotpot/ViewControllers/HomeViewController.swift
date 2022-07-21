//
//  HomeViewController.swift
//  Project-Hotpot
//
//  Created by Harini Sundaram on 7/6/22.
//

import UIKit

class HomeViewController: UIViewController {
    var api_instance = SpotifyManager.shared()
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
                //add to history
                let currentSpotifySong = api_instance.lastPlayerState?.track
                PFHistory.addSpotifySongToHistory(spotifySong: currentSpotifySong, completion:nil)
                self.resetSong()
                self.resetCard()
                return
            }
            else if card.center.x > (width - 75) {
                //add to history, get PFObject that was created
                PFHistory.addSpotifySongToHistory(spotifySong: api_instance.lastPlayerState?.track) {songObject, error in
                    if let songObject = songObject {
                        PFPlaylist.addPFSongToLastPlaylist(song:songObject)
                    }
                }
                presentAlert(title: "Liked Song", message: "Added to Playlist", buttonTitle: "Ok")
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
