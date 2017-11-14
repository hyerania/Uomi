//
//  AccountManager.swift
//  Uomi
//
//  Created by Eric Gonzalez on 11/14/17.
//  Copyright © 2017 Eric Gonzalez. All rights reserved.
//

import Foundation

protocol AccountManager {
    func register(user: String, name: String, password: String) -> (User, Bool)
    
    func login(email: String, password: String)
    
    // clear cache
    func logout()
    
    func userExists(email: String) -> Bool
    
    func load(id: String) -> User
    
    func users(forEvent: Event) -> [User]
}
