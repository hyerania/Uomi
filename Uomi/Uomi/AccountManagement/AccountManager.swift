//
//  AccountManager.swift
//  Uomi
//
//  Created by Eric Gonzalez on 11/14/17.
//  Copyright © 2017 Eric Gonzalez. All rights reserved.
//

import Foundation
import FirebaseDatabase
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
    
    private init() {
        print("Account mananger constructor called...")
        ref = Database.database().reference()
    }
    
    static let sharedInstance = AccountManager()
    
}
