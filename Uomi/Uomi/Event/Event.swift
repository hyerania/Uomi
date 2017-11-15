//
//  Event.swift
//  Uomi
//
//  Created by Eric Gonzalez on 11/14/17.
//  Copyright © 2017 Eric Gonzalez. All rights reserved.
//

import Foundation

class Event {
    
    private var owner: String
    private var name: String
    private var description: String
    private var contributors: [String]
    private var uid: String
    private var status: String
    
    init(owner: String, name: String, description: String, contributors: [String], uid: String, status: String) {
        self.owner = owner
        self.name = name
        self.description = description
        self.contributors = contributors
        self.uid = uid
        self.status = status
    }
    
    func getOwner() -> String {
        return self.owner
    }
    
    func getName() -> String {
        return self.name
    }
    
    func getDescription() -> String {
        return self.description
    }
    
    func getContributors() -> [String] {
        return self.contributors
    }
    
    func getUid() -> String {
        return self.uid
    }
    
    func getStatus() -> String {
        return self.status
    }
}
