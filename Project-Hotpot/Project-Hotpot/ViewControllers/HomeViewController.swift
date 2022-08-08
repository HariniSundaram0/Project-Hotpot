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
    var playRandomSongs : Bool = true
    var timer = Timer()
    let formatter = DateComponentsFormatter()
    @IBOutlet weak var thumbsImage: UIImageView!
    @IBOutlet weak var card: UIView!
    @IBOutlet weak var songImage: UIImageView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var findSimilarSongButton: UIButton!
    @IBOutlet weak var songTitleLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var progressBar: UIProgressView!
    
    override func viewDidLoad() {
        playRandomSongs = true
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
        self.resetSong()
        self.scheduledTimerWithTimeInterval()
    }
    
    
    // MARK: - Actions
    @IBAction func didTapButton(_sender: UIButton) {
        self.didTapMediaPlayButton(button: _sender)
    }
    
    @IBAction func didTapSimilarSongButton(_ sender: UIButton) {
        NSLog("tapped")
        if self.playRandomSongs{
            self.playRandomSongs = false
            self.findSimilarSongButton.setTitle("Return to Explore Mode", for: .normal)
        }
        else {
            self.playRandomSongs = true
            self.findSimilarSongButton.setTitle("Enter Radio Mode", for: .normal)
        }
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
                //duration is extracted in milliseconds
                let duration = Int(self.apiInstance.lastPlayerState?.track.duration ?? 1)
                let formattedString = self.formatter.string(from: TimeInterval(duration/1000))
                
                self.durationLabel.text = formattedString
                self.card.alpha = 1
                self.genreLabel.text = self.currentGenre
            })
        }
    }
    
    func resetSong() {
        let algInstance = SongAlgorithm()
        let completion: (Result<(String, String), Error>) -> Void = { result in
            switch result {
            case .success(let (uri, genre)):
                self.playNewSong(uri: uri, button: self.playButton)
                self.currentGenre = genre

            case .failure(let error):
                NSLog("\(error)")
                self.resetCard()
            }
        }
        if self.playRandomSongs{
            NSLog("random alg called")
            algInstance.getAlgorithmSong(completion: completion)
        }
        else if let currentGenre = self.currentGenre {
            NSLog("radio alg called")
            algInstance.getSimilarSong(genre: currentGenre, completion: completion)
        }
    }
    
    //MARK: Progress Bar
    @objc func updateProgressBar() {
        apiInstance.fetchPlayerState()
        guard let duration = apiInstance.lastPlayerState?.track.duration,
              let playbackPosition = apiInstance.lastPlayerState?.playbackPosition
        else {
            NSLog("failed to retreive time stamps")
            return
        }
        let newValue = Float(playbackPosition) / Float(duration)
        self.progressBar.setProgress(newValue, animated: true)
    }
    
    func scheduledTimerWithTimeInterval() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateProgressBar), userInfo: nil, repeats: true)
       
    }
}
