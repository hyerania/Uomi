//
//  EventManager.swift
//  Uomi
//
//  Created by Eric Gonzalez on 11/14/17.
//  Copyright © 2017 Eric Gonzalez. All rights reserved.
//

import Foundation

protocol EventManager {
    
    func createEvent(owner: User, event: Event) -> (Event, Bool)
    
    func loadEvents(user: User) -> [Event]
    
}
