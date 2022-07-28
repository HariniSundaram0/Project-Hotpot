//
//  ViewController.swift
//  Project-Hotpot
//
//  Created by Harini Sundaram on 7/26/22.
//

import UIKit
//for keeping general functions to be accessed by all view controllers
class ViewController: UIViewController {
    func presentAlert(title: String, message: String, buttonTitle: String) {
        DispatchQueue.main.async {
            let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let action = UIAlertAction(title: buttonTitle, style: .default, handler: nil)
            controller.addAction(action)
            self.present(controller, animated: true)
        }
    }

}
