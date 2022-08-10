//
//  MediaViewController.swift
//  Project-Hotpot
//
//  Created by Harini Sundaram on 8/1/22.
//

import UIKit

class MediaViewController: HotpotViewController {
    let apiInstance = SpotifyManager.shared()
    let pauseButtonImage = UIImage(systemName: "pause.circle.fill")
    let playButtomImage = UIImage(systemName: "play.circle.fill")
    
    @IBOutlet weak var playButton: UIButton!
    var timer:Timer = Timer()
    @IBOutlet weak var progressBar: UIProgressView!
    
    private func resumeSong() {
        //resume the audio
        DispatchQueue.main.async {
            self.apiInstance.appRemote.playerAPI?.resume()
            //change the button image
            self.playButton.setImage(self.pauseButtonImage, for:.normal)
        }
    }
    
    private func pauseSong() {
        //pause the audio
        DispatchQueue.main.async {
            self.apiInstance.appRemote.playerAPI?.pause()
            //change the button image
            self.playButton.setImage(self.playButtomImage, for:.normal)
        }
    }
    
    func playNewSong(uri: String) {
        DispatchQueue.main.async {
            self.apiInstance.appRemote.contentAPI?.fetchContentItem(forURI: uri, callback: { songContent, apiError in
                if let apiError = apiError {
                    NSLog(apiError.localizedDescription)
                }
                else if let songContent = songContent as? SPTAppRemoteContentItem
                {
                    self.apiInstance.appRemote.playerAPI?.play(songContent)
                    
                }
            })
        }
        self.resumeSong()
    }
    
    @IBAction func didTapPlayButton(_ sender: Any) {
        if (apiInstance.lastPlayerState?.isPaused == true){
            //if already paused, play the song
            self.resumeSong()
        }
        else{
            //if already playing, pause the song
            self.pauseSong()
        }
    }
    
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
