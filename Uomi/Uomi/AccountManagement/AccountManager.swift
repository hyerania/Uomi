//
//  AccountManager.swift
//  Uomi
//
//  Created by Eric Gonzalez on 11/14/17.
//  Copyright © 2017 Eric Gonzalez. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth

class AccountManager {
    
    var ref: DatabaseReference!
    private var currentUser: User?
    
    func register(email: String, name: String, password: String, completionHanlder: @escaping(User?, Error?) -> ()) {
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            
            if let error = error {
                completionHanlder(nil, error)
            } else {
                self.ref.child("accounts").child(user!.uid).setValue([
                    "name" : name,
                    "email" : email
                    ])
                let newUser = User(uid: user!.uid, email: email, name: name)
                self.currentUser = newUser
                completionHanlder(newUser, nil)
            }
        }
    }
    
    func login(email: String, password: String, completionHanlder: @escaping(User?) -> ()) {
            Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
    
                if (error != nil) {
                    completionHanlder(nil)
                    return
                }
                
                guard let user = user else {
                    print("Error converting user")
                    return
                }
                
                self.load(id: user.uid) { user in
                    self.currentUser = user
                    completionHanlder(user)
                }
            }
    }
    
    func load(id: String, completionHandler: @escaping(User?) -> ()) {
        ref.child("accounts").child(id).observeSingleEvent(of: .value, with: { (snapshot) in
            guard
                let userData = snapshot.value as? NSDictionary,
                let email = userData["email"] as? String,
                let name = userData["name"] as? String
            else {
                print("Unable to grab user information")
                completionHandler(nil)
                return
            }
            
            let user = User(uid: id, email: email, name: name)
            completionHandler(user)
            
        })
    }
    
    func load(email: String, completionHandler: @escaping(User?) -> ()) {
        ref.child("accounts").observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let accounts = snapshot.value as? NSDictionary else {
                print("Unable to get accounts")
                return
            }
            
            for (key, userInfo) in accounts {
                guard
                    let userData = userInfo as? NSDictionary,
                    let userEmail = userData["email"] as? String,
                    let name = userData["name"] as? String
                    else {
                        print("Invalid data.")
                        continue
                }
                
                if userEmail == email {
                    let user = User(uid: key as! String, email: userEmail, name: name)
                    completionHandler(user)
                    return
                }
                
            }
            completionHandler(nil)
        })
    }
    
    func remove(email: String, eventId: String) {
        
        self.load(email: email) { user in
            
            guard let user = user else {
                print("Error - Invalid user.")
                return
            }
            
            self.ref.child("accounts").child(user.getUid()).child("events").child(eventId).removeValue()
            
        }
    }
    
    func userExists(email: String, completionHandler: @escaping(Bool) -> ()) {
        ref.child("accounts").observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let accounts = snapshot.value as? NSDictionary else {
                print("Unable to get accounts")
                return
            }
            
            for (_, userInfo) in accounts {
                guard
                    let userData = userInfo as? NSDictionary,
                    let userEmail = userData["email"] as? String
                else {
                    print("Invalid data.")
                    continue
                }
                
                if userEmail == email {
                    completionHandler(true)
                    return
                }
            
            }
            completionHandler(false)
        })
    }
    func logout(completionHandler: @escaping(Bool) -> ()) {
        try! Auth.auth().signOut()
        completionHandler(true)
    }
    
    func getCurrentUser(completionHandler: @escaping(User?) -> ()) {
        
        if self.currentUser != nil {
            completionHandler(self.currentUser)
            return
        }
        
        Auth.auth().addStateDidChangeListener { auth, user in
            if let user = user {
                print("Is logged in")
                self.load(id: user.uid) { user in
                    completionHandler(user)
                    return
                }
            } else {
                completionHandler(nil)
                print("not logged in")
                return
            }
        }
        
    }
    
    
    private init() {
        print("Account mananger constructor called...")
        ref = Database.database().reference()
    }
    
    static let sharedInstance = AccountManager()
    
}
