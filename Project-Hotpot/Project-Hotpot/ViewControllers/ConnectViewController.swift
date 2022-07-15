//
//  ConnectViewController.swift
//  Project-Hotpot
//
//  Created by Harini Sundaram on 7/8/22.
//

import UIKit
//import "APIManager.swift"

class ConnectViewController: UIViewController {

   // MARK: - Subviews
   let stackView = UIStackView()
   let connectLabel = UILabel()
   let connectButton = UIButton(type: .system)

   var api_instance = APIManager.shared()
    
   // MARK: App Life Cycle
   override func viewDidLoad() {
       //initialize APIManager Object
       
       super.viewDidLoad()
       style()
       layout()
   }
    
    @objc func didTapConnect(_ button: UIButton) {
        guard let sessionManager = api_instance.sessionManager else { return }
        sessionManager.initiateSession(with: scopes, options: .clientOnly)
        
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "LoginViewController")
        self.view.window?.rootViewController = nextViewController
        
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
