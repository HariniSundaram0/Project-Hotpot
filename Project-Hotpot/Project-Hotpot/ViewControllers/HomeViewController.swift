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
    
    let api_instance = SpotifyManager.shared()
    let songManager = SongManager()
    @IBOutlet weak var card: UIView!
    @IBOutlet weak var songImage: UIImageView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var songTitleLabel: UILabel!
    
    override func viewDidLoad() {
        self.didSwipe(direction: swipe.left, completion: self.createClosure())
    }
    override func viewDidAppear(_ animated: Bool) {
        self.resetCard()
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
        
        if sender.state == UIGestureRecognizer.State.ended{
            if card.center.x < 75{
                // move off to left
                didSwipe(direction: swipe.left, completion: self.createClosure())
                UIView.animate(withDuration: 1.0, animations:{
                    card.center = CGPoint(x: card.center.x - width/2, y: card.center.y)
                })
                return
            }
            else if card.center.x > (width - 75) {
                //add to history, get PFObject that was created
                didSwipe(direction: swipe.right, completion: self.createClosure())
                presentAlert(title: "Liked Song", message: "Added to Playlist", buttonTitle: "Ok")
                UIView.animate(withDuration: 1.0, animations:{
                    card.center = CGPoint(x: card.center.x + width/2, y: card.center.y)
                })
                return
            }
            self.resetCard()
        }
    }
    
    func createClosure() -> ((Result<Void, Error>) -> Void) {
        let resetSongAndCard: (Result<Void, Error>) -> Void = { result in
            self.resetSong { result in
                switch result {
                case .success(_):
                    self.resetCard()
                case.failure(let error):
                    NSLog("error: \(error)")
                    //I want it to keep showing despite error
                    self.resetCard()
                }
            }
        }
        return resetSongAndCard
    }
    // an attempt to limit repetitive code
    func didSwipe(direction: swipe, completion: @escaping (_ result: Result<Void, Error>) -> Void){
        guard let track = api_instance.lastPlayerState?.track else {
            NSLog("Spotify is not playing any songs?")
            return completion(.failure(CustomError.nilSpotifyState))
        }
        songManager.addSpotifySongToHistory(spotifySong: track) { result in
            switch result {
            case .success(let song):
                NSLog("added to history")
                switch direction {
                case .left:
                    completion(.success(()))
                case .right:
                    PFPlaylist.addPFSongToLastPlaylist(song: song)
                    completion(.success(()))
                }
            case .failure(let error):
                NSLog("error occured: \(error)")
                completion(.failure(error))
            }
        }
    }
    // MARK: - helper functions
    func resetCard() {
        NSLog("resetting")
        DispatchQueue.main.async{
            UIView.animate(withDuration: 0.2, animations: {
                self.card.center = self.view.center
                self.songTitleLabel.text = self.api_instance.currentSongLabel
                if let track = self.api_instance.lastPlayerState?.track{
                    self.api_instance.fetchArtwork(for: track) { result in
                        switch result {
                        case .failure(let error):
                            NSLog(error.localizedDescription)
                            
                        case .success(let image):
                            DispatchQueue.main.async {
                                self.songImage.image = image
                            }
                        }
                    }
                }
            })
        }
    }
    
    //TODO: add completion block -> have to manually move card a little to re-reset card.
    func resetSong(completion: @escaping (_ result: Result<Void, Error>) -> Void) {
        let algInstance = SongAlgorithm()
        algInstance.getAlgorithmSong { result in
            switch result {
            case .success(let uri):
                self.playNewSong(uri: uri, button: self.playButton)
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }}
    }
}
