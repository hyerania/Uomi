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
//protocol AccountManager {
//    func register(user: String, name: String, password: String) -> (User, Bool)
//
//    func login(email: String, password: String)
//
//    // clear cache
//    func logout()
//
//    func userExists(email: String) -> Bool
//
//    func load(id: String) -> User
//
//    func users(forEvent: Event) -> [User]
//}

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
