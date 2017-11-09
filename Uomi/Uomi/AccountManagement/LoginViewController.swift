//
//  LoginViewController.swift
//  Uomi
//
//  Created by Eric Gonzalez on 10/31/17.
//  Copyright © 2017 Team Uomi. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {

    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    
    @IBOutlet weak var usernameLabel: UITextField!
    @IBOutlet weak var passwordLabel: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.loginButton.layer.cornerRadius = 8
        self.registerButton.layer.cornerRadius = 8
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Hide the navigation bar on the this view controller
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Show the navigation bar on other view controllers
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func hitLogin(_ sender: Any) {
        let email = self.usernameLabel.text!
        let password = self.passwordLabel.text!
        
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            
            if (user != nil) {
                self.performSegue(withIdentifier: "doLogin", sender: nil)
            }
            
            if (error != nil) {
                let alert = UIAlertController(title: "Unable to login", message: "The login credentials provided are invalid. Please try again.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            
        }
    }
    
}
