//
//  NewEventViewController.swift
//  Uomi
//
//  Created by Eric Gonzalez on 10/31/17.
//  Copyright © 2017 Eric Gonzalez. All rights reserved.
//

import UIKit

class EventEditorViewController: UIViewController, UITextFieldDelegate, UIGestureRecognizerDelegate {

    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var participantsTextView: UITextView!
    @IBOutlet weak var participantsTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    
    private var participants = [String]()
    var eventId: String?
    
    private let activitiyViewController = ActivityViewController(message: "Creating...")
    private let updateViewController = ActivityViewController(message: "Updating...")

    
    // MARK: - Controller Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        descriptionTextView.layer.borderWidth = 1
        descriptionTextView.layer.borderColor = UIColor.black.cgColor
        plusButton.layer.borderWidth = 1
        plusButton.layer.borderColor = UIColor.black.cgColor
        plusButton.isEnabled = false
        participantsTextView.layer.borderWidth = 1
        participantsTextView.layer.borderColor = UIColor.black.cgColor
        participantsTextField.delegate = self
        participantsTextField.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
        
        // Add tap gesture recognizer to Text View
        let tap = UITapGestureRecognizer(target: self, action: #selector(participantsTap(_:)))
        tap.delegate = self
        participantsTextView.addGestureRecognizer(tap)
        
        self.populateFields()
        self.rebuildParticipantsView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Button Actions
    @IBAction func hitPlusButton(_ sender: UIButton) {
        
        self.addParticipant(email: self.participantsTextField.text!)
        self.rebuildParticipantsView()
        
        self.plusButton.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
        self.plusButton.isEnabled = false;
    }
    
    @IBAction func hitDoneButton(_ sender: UIBarButtonItem) {
        
        let name = self.nameTextField.text!
        if (name.count == 0) {
            self.createAlert(title: "Unable to create event.", message: "Invalid name. Please fill in the name field.")
            return
        }
        
        self.present(activitiyViewController, animated: true, completion: nil)
        var participantsIds = [String]()
        AccountManager.sharedInstance.getCurrentUser() { currentUser in
            self.participants.append(currentUser!.getEmail())
            for email in self.participants {
                AccountManager.sharedInstance.load(email: email) { user in
                    if (user != nil) {
                        participantsIds.append(user!.getUid())
                        if (participantsIds.count == self.participants.count) {
                            self.createEvent(participantsId: participantsIds, owner: currentUser!.getUid())
                        }
                    }
                    
                }
            }
        }
    }
    
    @IBAction func doneButton(_ sender: UIBarButtonItem) {
        let name = self.nameTextField.text!
        if (name.count == 0) {
            self.createAlert(title: "Unable to create event.", message: "Invalid name. Please fill in the name field.")
            return
        }
        
        self.present(updateViewController, animated: true, completion: nil)
        var participantsIds = [String]()
        AccountManager.sharedInstance.getCurrentUser() { currentUser in
            self.participants.append(currentUser!.getEmail())
            for email in self.participants {
                AccountManager.sharedInstance.load(email: email) { user in
                    if (user != nil) {
                        participantsIds.append(user!.getUid())
                        if (participantsIds.count == self.participants.count) {
                            self.updateEvent(participantsId: participantsIds, owner: currentUser!.getUid(), key: self.eventId!)
                        }
                    }
                    
                }
            }
        }

    }
    
    
    // MARK: - Selector Actions
    @objc func textFieldDidChange(textField: UITextField){

        AccountManager.sharedInstance.userExists(email: textField.text!) { user in
            
            if (user) {
                AccountManager.sharedInstance.getCurrentUser() { currentUser in
                    if (currentUser != nil) {
                        if (currentUser?.getEmail() != textField.text! && !self.lowerContains(value: textField.text!)) {
                            self.plusButton.backgroundColor = UIColor(red: 122/255, green: 202/255, blue: 78/255, alpha: 1)
                            self.plusButton.isEnabled = true
                            
                        } else {
                            self.plusButton.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
                            self.plusButton.isEnabled = false;
                        }
                    }
                    
                    
                }
            } else {
                self.plusButton.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
                self.plusButton.isEnabled = false;
            }
            

        }
        
    }
    private func lowerContains(value: String) -> Bool {
        
        for email in self.participants {
            if email.lowercased() == value.lowercased() {
                return true
            }
        }
        return false
    }
    @objc func participantsTap(_ sender: UITapGestureRecognizer) {
        
        let myTextView = sender.view as! UITextView
        let layoutManager = myTextView.layoutManager
        
        // location of tap in myTextView coordinates and taking the inset into account
        var location = sender.location(in: myTextView)
        location.x -= myTextView.textContainerInset.left;
        location.y -= myTextView.textContainerInset.top;
        
        // character index at tap location
        let characterIndex = layoutManager.characterIndex(for: location, in: myTextView.textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        
        // if index is valid then do something.
        if characterIndex < myTextView.textStorage.length {
            
            // check if the tap location has a certain attribute
            let attributeName = "Email"
            let attributeValue = myTextView.attributedText.attribute(NSAttributedStringKey(rawValue: attributeName), at: characterIndex, effectiveRange: nil) as? String
            if let value = attributeValue {
                self.removeParticipant(email: value)
                self.rebuildParticipantsView()
            }
            
        }
    }
    
    // MARK: - Helper Functions
    
    private func populateFields() {
        guard let eventId = self.eventId else {
            return
        }
        
        EventManager.sharedInstance.loadEvent(id: eventId) { event in
            
            guard let event = event else {
                print("Error getting event.")
                return
            }
            
            self.nameTextField.text = event.getName()
            self.descriptionTextView.text = event.getDescription()
            
            AccountManager.sharedInstance.getCurrentUser() { user in
                guard let user = user else {
                    print("Error. User not logged in.")
                    return
                }
                
                let uid = user.getUid()
                
                for id in event.getContributors() {
                    
                    if (id == uid) {
                        continue
                    }
                    
                    AccountManager.sharedInstance.load(id: id) { otherUser in
                        
                        guard let validUser = otherUser else {
                            return
                        }
                        
                        self.participants.append(validUser.getEmail())
                        
                        if (self.participants.count == event.getContributors().count - 1) {
                            self.rebuildParticipantsView()
                        }
                    }
                    
                }
            }
        }
        
        
        
    }
    
    private func addParticipant(email: String) {
        if (!participants.contains(email)) {
            participants.append(email)
        }
    }
    
    private func removeParticipant(email: String) {
        participants = participants.filter(){ $0 != email}
        if eventId != nil {
            AccountManager.sharedInstance.remove(email: email, eventId: eventId!)
        }
        AccountManager.sharedInstance.userExists(email: email) { user in
            if (user && !self.participants.contains(email)) {
                self.plusButton.backgroundColor = UIColor(red: 122/255, green: 202/255, blue: 78/255, alpha: 1)
                self.plusButton.isEnabled = true
                
            } else {
                self.plusButton.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
                self.plusButton.isEnabled = false;
            }
        }
    }
    
    private func rebuildParticipantsView() {
        
        let text = NSMutableAttributedString()
        
        AccountManager.sharedInstance.getCurrentUser() { user in
            
            guard let user = user else {
                return
            }
            
            
            let sizeAtr: [NSAttributedStringKey: Any] = [ NSAttributedStringKey.font: UIFont(name: "Helvetica Neue", size: 16.0)!]
            let ownerMutableStr = NSMutableAttributedString(string: "\(user.getEmail()) (owner)\n")
            ownerMutableStr.addAttributes(sizeAtr, range: NSRange(location: 0, length: ownerMutableStr.length))
            text.append(ownerMutableStr)
            
            for participant in self.participants {
                let cancelAtrStr = NSMutableAttributedString(string: "Remove")
                let cancelRange = NSRange(location: 0, length: 6)
                let cancelCustAtr: [NSAttributedStringKey : Any] = [ NSAttributedStringKey(rawValue: "Email"): participant, NSAttributedStringKey.foregroundColor: UIColor.blue, NSAttributedStringKey.font: UIFont(name: "Helvetica Neue", size: 16.0)!]
                cancelAtrStr.addAttributes(cancelCustAtr, range: cancelRange)
                let emailMutableStr = NSMutableAttributedString(string: participant + " (")
                emailMutableStr.addAttributes(sizeAtr, range: NSRange(location: 0, length: emailMutableStr.length))
                text.append(emailMutableStr)
                text.append(cancelAtrStr)
                
                let endMutableStr = NSMutableAttributedString(string: ")\n")
                endMutableStr.addAttributes(sizeAtr, range: NSRange(location: 0, length: endMutableStr.length))
                text.append(endMutableStr)
            }
            self.participantsTextView.attributedText = text

        }
        
        

    }
    
    private func createEvent(participantsId: [String], owner: String) {
        
        guard
            let name = self.nameTextField.text,
            let description = self.self.descriptionTextView.text
        else {
            print("Invalid event creation.")
            return
        }
        
        let event: [String: Any] = ["name": name, "description": description, "owner": owner, "participants": participantsId]
        EventManager.sharedInstance.createEvent(event: event) { event in
            if event != nil {
                print("Successfully created event")
                self.performSegue(withIdentifier: "unwindToEvents", sender: self)
            } else {
                self.createAlert(title: "Error", message: "There was an issue creating your event. Please try again.")
            }
        }
        self.activitiyViewController.dismiss(animated: true)
        
    }
    
    private func updateEvent(participantsId: [String], owner: String, key: String) {
        guard
            let name = self.nameTextField.text,
            let description = self.self.descriptionTextView.text
            else {
                print("Invalid event creation.")
                return
        }
        
        let event: [String: Any] = ["name": name, "description": description, "owner": owner, "participants": participantsId]
        EventManager.sharedInstance.updateEvent(event: event, key: key) { event in
            if event != nil {
                print("Successfully updated event")
                if let navController = self.navigationController {
                    navController.popViewController(animated: true)
                }
            } else {
                self.createAlert(title: "Error", message: "There was an issue creating your event. Please try again.")
            }
        }
        self.updateViewController.dismiss(animated: true)
    }

    private func createAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    

}
