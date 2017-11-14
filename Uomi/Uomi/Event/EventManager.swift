//
//  EventManager.swift
//  Uomi
//
//  Created by Eric Gonzalez on 11/14/17.
//  Copyright © 2017 Eric Gonzalez. All rights reserved.
//

import Foundation
import FirebaseDatabase

//protocol EventManager {
//
//    func createEvent(owner: User, event: Event) -> (Event, Bool)
//
//    func loadEvents(user: User) -> [Event]
//
//}

class EventManager {
    private var ref: DatabaseReference!
    
    func createEvent(event: [String: Any], comepletionHandler: @escaping([Event?]) -> ()) {
        
        let key = ref.child("events").childByAutoId().key
        var updatedEvent = event
        var postParticipants =  [String: Bool]()
        for participant in event["participants"] as! [String] {
            postParticipants[participant] = true
        }
        updatedEvent["participants" ] = postParticipants
        let childUpdates = ["/events/\(key)": updatedEvent]

        ref.updateChildValues(childUpdates)
        
        
    }
    
    private init() {
        print("Event mananger constructor called...")
        ref = Database.database().reference()
    }
    
    static let sharedInstance = EventManager()
}
