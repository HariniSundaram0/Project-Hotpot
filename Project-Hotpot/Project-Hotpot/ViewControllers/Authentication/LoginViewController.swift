//
//  LoginViewController.swift
//  Project-Hotpot
//
//  Created by Harini Sundaram on 7/12/22.
//

import UIKit
import Parse

class LoginViewController: HotpotViewController, UITextFieldDelegate {
    
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var usernameField: UITextField!
    override func viewDidLoad() {
        self.passwordField.delegate = self
        self.usernameField.delegate = self
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        NSLog("in view did appear")
        if SpotifyManager.shared().appRemote.isConnected{
            NSLog("appear check")
            if (PFUser.current() != nil) {
                self.displayNextViewController()
            }
        }
    }
    
    @IBAction func didTapRegister(_ sender: Any) {
        registerUser()
    }
    
    @IBAction func didTapLogin(_ sender: Any) {
        loginUser()
    }
    
    func registerUser() {
        // initialize a user object
        let newUser = PFUser()
        // set user properties
        newUser.username = usernameField.text
        newUser.password = passwordField.text
        //save base user
        newUser.signUpInBackground { (success: Bool, error: Error?) in
            if let error = error {
                NSLog("there was an error registering")
                self.presentAlert(title: "Error Registering", message: error.localizedDescription, buttonTitle: "Try Again")
            } else {
                NSLog("base user object Registered successfully")
                self.displayNextViewController()
            }
        }
    }
    
    func loginUser() {
        //extract username and password fields
        let username = usernameField.text ?? ""
        let password = passwordField.text ?? ""
        //send to server in background thread
        PFUser.logInWithUsername(inBackground: username, password: password) { (user: PFUser?, error: Error?) in
            if let error = error {
                self.presentAlert(title: "Error Logging in", message: error.localizedDescription, buttonTitle: "Try Again")
            } else {
                NSLog("User logged in successfully")
                // display view controller that needs to shown after successful login
                self.displayNextViewController()
            }
        }
    }
    func displayNextViewController() {
        //first clear all text fields
        self.usernameField.text = ""
        self.passwordField.text = ""
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "ConnectViewController") as UIViewController
        self.view.window?.rootViewController = nextViewController
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}
