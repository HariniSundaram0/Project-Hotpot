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
    let songManager = SongManager.shared()
    var currentGenre: String?
    @IBOutlet weak var currentPlaylistButton: UIButton!
    var currentPlaylist: PFPlaylist?
    var exploreMode : Bool = true
    let formatter = DateComponentsFormatter()
    @IBOutlet weak var thumbsImage: UIImageView!
    @IBOutlet weak var card: UIView!
    @IBOutlet weak var songImage: UIImageView!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var findSimilarSongButton: UIButton!
    @IBOutlet weak var songTitleLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    
    override func viewDidLoad() {
        self.formatter.allowedUnits = [.hour, .minute, .second]
        //set up notifation reveiver
        NotificationCenter.default.addObserver(forName: Notification.Name("HotpotSongUpdateIdentifier"), object: nil, queue: .main) { notif in
            guard let state = notif.object as? SPTAppRemotePlayerState else {
                NSLog("couldn't cast notification message")
                return
            }
            //if song has changed, update the UI View
            self.updateCard(track: state.track)
        }
        resetSong()
        self.scheduledTimerWithTimeInterval()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.exploreMode = true
    }
    // MARK: - Actions
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
                    card.center = CGPoint(x: card.center.x - width/2, y: card.center.y)
                    card.alpha = 0
                })
                refreshSong(direction: swipe.left)
                resetSong()
                return
            }
            else if card.center.x > (width - 75) {
                //add to history, get PFObject that was created
                UIView.animate(withDuration: 0.3, animations:{
                    card.center = CGPoint(x: card.center.x + width/2, y: card.center.y)
                    card.alpha = 0
                })
                refreshSong(direction: swipe.right)
                resetSong()
                //TODO: presenting the alert causes animation for right swipe to be weird.
                return
            }
            self.resetCard()
        }
    }
    
    // an attempt to limit repetitive code
    func refreshSong(direction: swipe) {
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
                    if let currentPlaylist = self.currentPlaylist {
                        PFPlaylist.addPFSongToPlaylist(song: song, currPlaylist: currentPlaylist)
                    }
                    else {
                        PFPlaylist.addPFSongToLastPlaylist(song: song)
                    }
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
            case .success(let image):
                DispatchQueue.main.async {
                    self.songImage.image = image
                    self.updateInfo()
                }
            }
        }
    }
    
    //WRAP ONTO MAIN QUEUE!
    func updateInfo() {
        self.songTitleLabel.text = self.apiInstance.lastPlayerState?.track.name
        NSLog("updated song with \(self.apiInstance.lastPlayerState?.track.name)")
        self.artistNameLabel.text = self.apiInstance.lastPlayerState?.track.artist.name
        self.genreLabel.text = self.currentGenre
        //duration is extracted in milliseconds
        let duration = Int(self.apiInstance.lastPlayerState?.track.duration ?? 1)
        let formattedString = self.formatter.string(from: TimeInterval(duration/1000))
        self.durationLabel.text = formattedString
    }
    
    func resetCard() {
        DispatchQueue.main.async{
            self.updateInfo()
            self.thumbsImage.alpha = 0
            UIView.animate(withDuration: 0.4, animations: {
                self.card.transform = CGAffineTransform.identity
                self.card.center = self.view.center
                self.card.alpha = 1
            })
        }
    }
    
    func resetSong() {
        let algInstance = SongAlgorithm()
        let completion: (Result<(String, String), Error>) -> Void = { result in
            switch result {
            case .success(let (uri, genre)):
                self.playNewSong(uri: uri)
                self.currentGenre = genre
                self.resetCard()
                
            case .failure(let error):
                NSLog("\(error)")
                self.resetCard()
            }
        }
        algInstance.getAlgorithmSong(completion: completion)
    }
    
    @IBAction func didTapActionSheet(_ sender: Any) {
        
        let actionSheet = UIAlertController.init(title: "Playlists: ", message: "Choose a Playlist to add liked Songs To", preferredStyle: .actionSheet)
        
        PFPlaylist.getLastNPlaylistsInBackground(limit: nil) { result in
            switch result {
            case .success(let playlists):
                for playlist in playlists {
                    let newAction = UIAlertAction(title: playlist.name, style: .destructive) { action in
                        self.currentPlaylist = playlist
                        DispatchQueue.main.async {
                            let name = playlist.name
                            self.currentPlaylistButton.setTitle(name, for: .normal)
                        }
                    }
                    actionSheet.addAction(newAction)
                }
            case .failure(let error):
                NSLog(error.localizedDescription)
                //we don't want to show an empty action sheet
                return
            }
        }
        self.present(actionSheet, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let radioController = segue.destination as? RadioModeViewController else {
            return
        }
        //prevents genre from switching (bug fix)
        radioController.genre = self.currentGenre
    }
}
