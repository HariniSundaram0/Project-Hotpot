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

        // Do any additional setup after loading the view.
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
        
        // call sign up function on the object
        newUser.signUpInBackground { (success: Bool, error: Error?) in
            if let error = error {
                NSLog("fuck there was an error registering")
                print(error.localizedDescription)
            } else {
                print("User Registered successfully")
                self.display_view()
                
            }
        }
    }
    func loginUser() {

       let username = usernameField.text ?? ""
       let password = passwordField.text ?? ""

       PFUser.logInWithUsername(inBackground: username, password: password) { (user: PFUser?, error: Error?) in
            if let error = error {
              print("User log in failed: \(error.localizedDescription)")
            } else {
              print("User logged in successfully")
                self.display_view()
              // display view controller that needs to shown after successful login
            }
         }
    }
    func display_view(){
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
         let nextViewController = storyBoard.instantiateViewController(withIdentifier: "HomeViewController") as! UIViewController
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
