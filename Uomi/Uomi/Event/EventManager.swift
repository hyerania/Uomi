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
    
    func createEvent(event: [String: Any], completionHandler: @escaping(Event?) -> ()) {
        
        let key = ref.child("events").childByAutoId().key
        var addEvent = [String:Any]()
        addEvent["name"] = event["name"]
        addEvent["description"] = event["description"]
        addEvent["owner"] = event["owner"]
        addEvent["status"] = "active"
        var postParticipants =  [String: Bool]()
        for participant in event["participants"] as! [String] {
            postParticipants[participant] = true
        }

        addEvent["participants" ] = postParticipants
        
        var childUpdates = ["/events/\(key)": addEvent]
        for participant in event["participants"] as! [String] {
            // This is wrong. Fix when you wake up.
            childUpdates["/accounts/\(participant)/events/\(key)"] = ["value": true]
        }
        ref.updateChildValues(childUpdates)
        
        let newEvent = Event(owner: addEvent["owner"] as! String, name: addEvent["name"] as! String, description: addEvent["description"] as! String, contributors: event["participants"] as! [String], uid: key)
        completionHandler(newEvent)
        
    }
    
    func loadEvents(userId: String, completionHandler: @escaping([Event]) -> ()) {
        
        var userEvents = [Event]()
        ref.child("accounts").child(userId).child("events").observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let events = snapshot.value as? NSDictionary else {
                print("No Events")
                completionHandler(userEvents)
                return
            }
            
            for (key, _) in events {
                print(key)
            }
            completionHandler(userEvents)
            
        })
    }
    
    private init() {
        print("Event mananger constructor called...")
        ref = Database.database().reference()
    }
    
    static let sharedInstance = EventManager()
}
