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
    
    func resumeSong(button: UIButton) {
        //resume the audio
        DispatchQueue.main.async {
        NSLog("trying to resume song")
            self.apiInstance.appRemote.playerAPI?.resume()
        //change the button image
            button.setImage(self.pauseButtonImage, for:.normal)
        }
    }
    
    func pauseSong(button: UIButton) {
        //pause the audio
        DispatchQueue.main.async {
            self.apiInstance.appRemote.playerAPI?.pause()
        //change the button image
            NSLog("paused song")
            button.setImage(self.playButtomImage, for:.normal)
        }
    }
    
    //TODO: add completion handler
    func playNewSong(uri: String, button: UIButton) {
        DispatchQueue.main.async {
            NSLog("tryna play new song from media controller")
            self.apiInstance.appRemote.contentAPI?.fetchContentItem(forURI: uri, callback: { songContent, apiError in
                if let apiError = apiError {
                    NSLog(apiError.localizedDescription)
                }
                else if let songContent = songContent as? SPTAppRemoteContentItem
                {
                    self.apiInstance.appRemote.playerAPI?.play(songContent)
                    button.setImage(self.pauseButtonImage, for:.normal)
                }
            })
        }
    }
    
    func didTapMediaPlayButton(button: UIButton) {
        if (apiInstance.lastPlayerState?.isPaused == true){
            //if already paused, play the song
            resumeSong(button: button)
        }
        else{
            //if already playing, pause the song
            pauseSong(button: button)
        }
    }
}
