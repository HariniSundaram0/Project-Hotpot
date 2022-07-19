//
//  LoginViewController.swift
//  Project-Hotpot
//
//  Created by Harini Sundaram on 7/12/22.
//

import UIKit
import Parse

class LoginViewController: UIViewController {
    
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var usernameField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
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
                NSLog(error.localizedDescription)
            } else {
                NSLog("base user object Registered successfully")
                //create history 'playlist' object to keep track of all listened to songs
                self.initializeNewHistoryQueue(newUser: newUser)
            }
        }
    }
    //wrapper function for intialize history playlist object of a new user
    func initializeNewHistoryQueue(newUser: PFUser){
        PFPlaylist.createPlaylistInBackground(user: newUser, name: "history", completion: {playlist in
            if let playlist = playlist{
                //store playlist object in new user (1 to 1 cardinality)
                newUser.setObject(playlist, forKey: "history")
                //saveInBackground
                newUser.saveInBackground { isSaved, error in
                    if let error = error {
                        NSLog("unable to save history object \(error)")
                    }
                    else{
                        self.displayNextViewController()
                    }
                }
            }
            else{
                NSLog("new user history creation failed")
            }
        })
    }
    func loginUser() {
        //extract username and password fields
        let username = usernameField.text ?? ""
        let password = passwordField.text ?? ""
        //send to server in background thread
        PFUser.logInWithUsername(inBackground: username, password: password) { (user: PFUser?, error: Error?) in
            if let error = error {
                NSLog("User log in failed: \(error.localizedDescription)")
            } else {
                NSLog("User logged in successfully")
                self.displayNextViewController()
                // display view controller that needs to shown after successful login
            }
        }
    }
    func displayNextViewController(){
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "tabBarController") as UIViewController
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
