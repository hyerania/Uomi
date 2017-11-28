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
    @IBOutlet weak var scrollView: UIScrollView!
    
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        self.registerButton.layer.cornerRadius = 8
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tap))
        view.addGestureRecognizer(tapGesture)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.registerKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.unregisterKeyboardNotifications()
    }
    
    func registerKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow(notification:)), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func unregisterKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    @objc func keyboardDidShow(notification: NSNotification) {
        let userInfo: NSDictionary = notification.userInfo! as NSDictionary
        let keyboardInfo = userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue
        let keyboardSize = keyboardInfo.cgRectValue.size
        
        // Get the existing contentInset for the scrollView and set the bottom property to be the height of the keyboard
        var contentInset = self.scrollView.contentInset
        contentInset.bottom = keyboardSize.width
        
        self.scrollView.contentInset = contentInset
        self.scrollView.scrollIndicatorInsets = contentInset
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        var contentInset = self.scrollView.contentInset
        contentInset.bottom = 0
        
        self.scrollView.contentInset = contentInset
        self.scrollView.scrollIndicatorInsets = UIEdgeInsets.zero
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func registerUser(_ sender: UIButton) {
        
        let email = self.emailLabel.text!
        let password = self.passwordLabel.text!
        let confirmPassword = self.confirmPasswordLabel.text!
        let name = self.fullNameLabel.text!
        
        if (email.count == 0 || password.count == 0 || confirmPassword.count == 0 || name.count == 0) {
            self.createAlert(title: "Unable to register", message: "Invalid input.")
        } else if (self.passwordLabel.text! != self.confirmPasswordLabel.text!) {
            self.createAlert(title: "Unable to register", message: "Passwords do not match.")
        } else {
            AccountManager.sharedInstance.register(email: email, name: name, password: password) { user, error in
                if let error = error, let errCode = AuthErrorCode(rawValue: error._code) {
                    switch errCode {
                    case .emailAlreadyInUse:
                        self.createAlert(title: "Unable to register", message: "Email already in use.")
                    case .invalidEmail:
                        self.createAlert(title: "Unable to register", message: "Invalid email. Please try again.")
                    default:
                        print("Create User Error: \(error)")
                    }
                } else {
                    self.performSegue(withIdentifier: "goToEvents", sender: self)
                }
            }
        }
       
    }
    
    func createAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func tap(gesture: UITapGestureRecognizer) {
        fullNameLabel.resignFirstResponder()
        emailLabel.resignFirstResponder()
        passwordLabel.resignFirstResponder()
        confirmPasswordLabel.resignFirstResponder()
    }
    
    
}
