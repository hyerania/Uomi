//
//  Event.swift
//  Uomi
//
//  Created by Eric Gonzalez on 11/14/17.
//  Copyright © 2017 Eric Gonzalez. All rights reserved.
//

import Foundation

class Event {
    
    private var name: String
    private var description: String
    private var contributors: [String]
    private var uid: String
    
    init(name: String, description: String, contributors: [String], uid: String) {
        self.name = name
        self.description = description
        self.contributors = contributors
        self.uid = uid
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
}
