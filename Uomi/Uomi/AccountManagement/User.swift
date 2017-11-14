//
//  User.swift
//  Uomi
//
//  Created by Eric Gonzalez on 11/14/17.
//  Copyright © 2017 Eric Gonzalez. All rights reserved.
//

import Foundation

class User {
    
    private var uid: String
    private var email: String
    private var name: String
    
    init(uid: String, email: String, name: String) {
        self.uid = uid
        self.email = email
        self.name = name
    }
    
    func getUid() -> String {
        return self.uid
    }
    
    func getEmail() -> String {
        return self.email
    }
    
    func getName() -> String {
        return self.name
    }
}
