//
//  HomeViewController.swift
//  Project-Hotpot
//
//  Created by Harini Sundaram on 7/6/22.
//

import UIKit

class HomeViewController: MediaViewController {
    enum swipe{
        case left
        case right
    }
    let songManager = SongManager()
    @IBOutlet weak var thumbsImage: UIImageView!
    @IBOutlet weak var card: UIView!
    @IBOutlet weak var songImage: UIImageView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var songTitleLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    
    override func viewDidLoad() {
        //set up notifation reveiver
        NotificationCenter.default.addObserver(forName: Notification.Name("HotpotSongUpdateIdentifier"), object: nil, queue: .main) { notif in
            guard let state = notif.object as? SPTAppRemotePlayerState else {
                NSLog("couldn't cast notification message")
                return
            }
            //if song has changed, update the UI View
            self.updateCard(track: state.track)
        }
        self.resetSong()
    }
    
    // MARK: - Actions
    @IBAction func didTapButton(_sender: UIButton) {
        self.didTapMediaPlayButton(button: _sender)
    }
    
    @IBAction func panCard(_ sender: UIPanGestureRecognizer) {
        guard let card = sender.view else {
            return
        }
        let point = sender.translation(in: view)
        card.center = CGPoint(x:view.center.x + point.x, y:view.center.y + point.y)
        let width = view.frame.width
        let xFromCenter = card.center.x - view.center.x
        //create 45 degree angle once swiped
        let DIVISOR: CGFloat = (view.frame.width / 2) / (0.33)
        card.transform = CGAffineTransform(rotationAngle: xFromCenter / DIVISOR)
        //when swiped, tranform the thumbsUp/down image
        if xFromCenter > 0 {
            self.thumbsImage.image = UIImage(named: "ThumbsUp")
            self.thumbsImage.tintColor = UIColor.green
        }
        else{
            self.thumbsImage.image = UIImage(named: "ThumbsDown")
            self.thumbsImage.tintColor = UIColor.red
        }
        //the more extreme the swipe, the more visible the icon
        thumbsImage.alpha = abs(xFromCenter) / view.center.x
        
        if sender.state == UIGestureRecognizer.State.ended{
            if card.center.x < 75{
                // move off to left
                UIView.animate(withDuration: 0.3, animations:{
                    card.center = CGPoint(x: card.center.x - width/2, y: card.center.y + 50)
                    card.alpha = 0
                })
                refreshSong(direction: swipe.left)
                self.resetSong()
                return
            }
            else if card.center.x > (width - 75) {
                //add to history, get PFObject that was created
                UIView.animate(withDuration: 0.3, animations:{
                    card.center = CGPoint(x: card.center.x + width/2, y: card.center.y + 50)
                    card.alpha = 0
                })
                refreshSong(direction: swipe.right)
                self.resetSong()
                //TODO: presenting the alert causes animation for right swipe to be weird.
                return
            }
            self.resetCard()
        }
    }
    
    // an attempt to limit repetitive code
    func refreshSong(direction: swipe){
        guard let track = apiInstance.lastPlayerState?.track else {
            NSLog("Spotify is not playing any songs?")
            return
        }
        songManager.addSpotifySongToHistory(spotifySong: track) { result in
            switch result {
            case .success(let song):
                NSLog("added to history")
                switch direction {
                case .left:
                    return
                case .right:
                    PFPlaylist.addPFSongToLastPlaylist(song: song)
                }
            case .failure(let error):
                NSLog("error occured: \(error)")
            }
        }
    }
    
    // MARK: - helper functions
    func updateCard(track : SPTAppRemoteTrack) {
        self.apiInstance.fetchArtwork(for: track) { result in
            switch result {
            case .failure(let error):
                NSLog("failed resetting card")
                NSLog(error.localizedDescription)
                self.resetCard()
            case .success(let image):
                self.resetCard()
                self.songImage.image = image
            }
        }
    }
    
    func resetCard() {
        DispatchQueue.main.async{
            self.thumbsImage.alpha = 0
            UIView.animate(withDuration: 0.2, animations: {
                self.card.transform = CGAffineTransform.identity
                self.card.center = self.view.center
                self.songTitleLabel.text = self.apiInstance.lastPlayerState?.track.name
                self.artistNameLabel.text = self.apiInstance.lastPlayerState?.track.artist.name
                self.card.alpha = 1
            })
        }
    }
    
    func resetSong() {
        let algInstance = SongAlgorithm()
        algInstance.getAlgorithmSong { result in
            switch result {
            case .success(let uri):
                self.playNewSong(uri: uri, button: self.playButton)
            case .failure(let error):
                NSLog("\(error)")
                self.resetCard()
            }
        }
    }
}
