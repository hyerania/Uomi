//
//  NewAccountViewController.swift
//  Uomi
//
//  Created by Eric Gonzalez on 10/31/17.
//  Copyright © 2017 Team Uomi. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class NewAccountViewController: UIViewController {

    @IBOutlet weak var fullNameLabel: UITextField!
    @IBOutlet weak var emailLabel: UITextField!
    @IBOutlet weak var passwordLabel: UITextField!
    @IBOutlet weak var confirmPasswordLabel: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        self.registerButton.layer.cornerRadius = 8
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    func register(email: String, password: String) {
//        Auth.auth().createUser(withEmail: "", password: <#T##String#>, completion: <#T##AuthResultCallback?##AuthResultCallback?##(User?, Error?) -> Void#>)
    }
    
    @IBAction func registerUser(_ sender: UIButton) {
        
        let email = self.emailLabel.text!
        let password = self.passwordLabel.text!
        let confirmPassword = self.confirmPasswordLabel.text!
        let name = self.fullNameLabel.text!
        
        if (email.count == 0 || password.count == 0 || confirmPassword.count == 0 || name.count == 0) {
            
        }
        if (self.passwordLabel.text! != self.confirmPasswordLabel.text!) {
            self.createAlert(title: "Unable to register", message: "Passwords do not match.")
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { (user: User?, error) in
            
            if let error = error, let errCode = AuthErrorCode(rawValue: error._code) {
                
                switch errCode {
                case .emailAlreadyInUse:
                    self.createAlert(title: "Unable to register", message: "Email already in use.")
                case .invalidEmail:
                    let alert = UIAlertController(title: "Unable to register", message: "Invalid email. Please try again.", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                default:
                    print("Create User Error: \(error)")
                }
            } else {
                self.ref.child("accounts/" + user!.uid).setValue([
                    "name": self.fullNameLabel.text!,
                    "email": self.emailLabel.text!,
                    ])
                self.performSegue(withIdentifier: "goToEvents", sender: self)
            }
            // ...
        }
    }
    
    func createAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
