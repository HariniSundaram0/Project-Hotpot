//
//  ConnectViewController.swift
//  Project-Hotpot
//
//  Created by Harini Sundaram on 7/8/22.
//

import UIKit
class ConnectViewController: UIViewController {
    
    // MARK: - Subviews
    let stackView = UIStackView()
    let connectLabel = UILabel()
    let connectButton = UIButton(type: .system)
    
    var apiInstance = SpotifyManager.shared()
    
    // MARK: App Life Cycle
    override func viewDidLoad() {
        //initialize SpotifyManager Object
        super.viewDidLoad()
        style()
        layout()
    }
    
    @objc func didTapConnect(_ button: UIButton) {
        guard let sessionManager = apiInstance.sessionManager else {
            return
        }
        sessionManager.initiateSession(with: scopes, options: .clientOnly)
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "LoginViewController")
        self.view.window?.rootViewController = nextViewController
        
    }
}
extension ConnectViewController {
    func style() {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.alignment = .center
        
        connectLabel.translatesAutoresizingMaskIntoConstraints = false
        connectLabel.text = "Connect your Spotify account"
        connectLabel.font = UIFont.preferredFont(forTextStyle: .title3)
        connectLabel.textColor = .systemGreen
        
        connectButton.translatesAutoresizingMaskIntoConstraints = false
        connectButton.configuration = .filled()
        connectButton.setTitle("Continue with Spotify", for: [])
        connectButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .title3)
        connectButton.addTarget(self, action: #selector(didTapConnect), for: .primaryActionTriggered)
        
    }
    
    func layout() {
        
        stackView.addArrangedSubview(connectLabel)
        stackView.addArrangedSubview(connectButton)
        
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
    
    func updateViewBasedOnConnected() {
    }
}
