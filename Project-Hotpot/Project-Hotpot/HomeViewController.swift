//
//  HomeViewController.swift
//  Project-Hotpot
//
//  Created by Harini Sundaram on 7/6/22.
//

import UIKit

class HomeViewController: UIViewController {
    var api_instance = APIManager.shared()
    @IBOutlet weak var card: UIView!
    
    @IBOutlet weak var playButton: UIButton!
    
    @IBOutlet weak var songTitleLabel: UILabel!
    override func viewDidLoad() {
        // currently hardcoding a song to play on opening of the app
        let songURI = getRandomSong()
        _ = self.api_instance.appRemote.contentAPI?.fetchContentItem(forURI: songURI, callback: {success, error in
            
            if ((success) != nil){
                self.api_instance.appRemote.playerAPI?.play(success as! SPTAppRemoteContentItem)
                self.playSong()
                self.songTitleLabel.text = self.api_instance.curr_song_label
            }
        })
    }
    
//    func addToParseQueue(){
//
//    }
    
    @IBAction func didTapButton(_ sender: UIButton) {
        
        if (api_instance.lastPlayerState?.isPaused == true){
            //if already paused, play the song
            playSong()
        }
        else{
            //if already playinh, pause the song
            pauseSong()
        }
    }
    

    func playSong(){
        //resume the audio
        api_instance.appRemote.playerAPI?.resume()
        //change the button image
        let newIcon = UIImage(systemName: "pause.circle.fill")
        self.playButton.setImage(newIcon, for:.normal)
    }
    
    func pauseSong(){
        //pause the audio
        api_instance.appRemote.playerAPI?.pause()
        //change the button image
        let newIcon = UIImage(systemName: "play.circle.fill")
        self.playButton.setImage(newIcon, for:.normal)
        
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
                self.resetCard()
//                resetCard().delay
                return
            }
            else if card.center.x > (width - 75){
                NSLog("moving to right")
                UIView.animate(withDuration: 1.0, animations:{
                    card.center = CGPoint(x: card.center.x + width/2, y: card.center.y)
                    
                })
//
                UIView.animate(withDuration: 0.2, delay: 2.0) {
                    self.resetCard()
                }

                return
                //move off to right
            }
            
            resetCard()
            
            
        }
    }
    
    func resetCard(){
        NSLog("resetting")
        UIView.animate(withDuration: 0.2, animations: {
            self.card.center = self.view.center
//            self.ca
            
        })
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
