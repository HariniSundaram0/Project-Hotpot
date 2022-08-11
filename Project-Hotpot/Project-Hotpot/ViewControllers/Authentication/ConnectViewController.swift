//
//  ConnectViewController.swift
//  Project-Hotpot
//
//  Created by Harini Sundaram on 7/8/22.
//

import UIKit
class ConnectViewController: UIViewController {
    
    //initialize SpotifyManager Object
    var apiInstance = SpotifyManager.shared()
    @IBOutlet weak var connectButton: UIButton!
    
    // MARK: App Life Cycle
    @IBAction func didTapConnect(_ sender: Any) {
        apiInstance.sessionManager?.initiateSession(with: scopes, options: .clientOnly)
    }
    
    override func viewDidLoad() {
        NotificationCenter.default.addObserver(forName: Notification.Name("AppRemoteConnected"), object: nil, queue: .main) { _ in
            self.displayLoginController()
        }
    }
    
    func displayLoginController() {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "LoginViewController")
        self.view.window?.rootViewController = nextViewController
    }
}


