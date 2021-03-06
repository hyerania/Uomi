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
        self.createEvent(event: event, key: key, completionHandler: completionHandler)
        
    }
    
    func updateEvent(event: [String: Any], key: String, completionHandler: @escaping(Event?) -> ()) {
        self.createEvent(event: event, key: key, completionHandler: completionHandler)
    }
    
    
    func loadEvents(userId: String, completionHandler: @escaping([Event]) -> ()) {
        
        var userEvents = [Event]()
        ref.child("accounts").child(userId).child("events").observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let events = snapshot.value as? NSDictionary else {
                print("No Events")
                completionHandler(userEvents)
                return
            }
            
            var count = 0
            for (key, _) in events {
                guard let key = key as? String else {
                    print("There was an issue getting event key")
                    continue
                }
                self.loadEvent(id: key) { event in
                    count = count + 1
                    if (event != nil) {
                        userEvents.append(event!)
                    }
                    if (count == events.count) {
                        completionHandler(userEvents)
                    }
                }
            }
            
        })
    }
    
    func loadEvent(id: String, completionHanlder: @escaping(Event?) -> ()) {
        ref.child("events").child(id).observeSingleEvent(of: .value, with: { (snapshot) in
            guard
                let eventData = snapshot.value as? NSDictionary,
                let description = eventData["description"] as? String,
                let name = eventData["name"] as? String,
                let owner = eventData["owner"] as? String,
                let participants = eventData["participants"] as? NSDictionary,
                let status = eventData["status"] as? String
            else {
                completionHanlder(nil)
                return
            }
            
            var participantsIds = [String]()
            for (key, _) in participants {
                if let key = key as? String {
                    participantsIds.append(key)
                }
            }
            
            var lastTime: Date = Date()
            if let time = eventData["time"] as? NSDictionary {
                guard let date = time["date"] as? TimeInterval else {
                    return
                }
                
                let time = Date(timeIntervalSince1970: date)
                lastTime = time            }

            let event = Event(owner: owner, name: name, description: description, contributors: participantsIds, uid: id, status: status)
            event.setDate(date: lastTime)
            completionHanlder(event)
        })
    }
    
    private func createEvent(event: [String: Any], key: String, completionHandler: @escaping(Event?) -> ()) {
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
        
        let newEvent = Event(owner: addEvent["owner"] as! String, name: addEvent["name"] as! String, description: addEvent["description"] as! String, contributors: event["participants"] as! [String], uid: key, status: "active")
        completionHandler(newEvent)
    }
    
    
    func updateEventTime(eventId: String, date: Date, completionHandler: @escaping(Bool) -> ()) {
        let timeEvent = ["date" : date.timeIntervalSince1970]
        var childUpdates = ["/events/\(eventId)/time": timeEvent]
        self.ref.updateChildValues(childUpdates)
    }
    
    // MARK: - Active Event
    fileprivate var activeEvent: String?
    
    func setActiveEvent(eventId: String?) {
        activeEvent = eventId
    }
    
    func getActiveEvent() -> String? {
        return activeEvent
    }
    
    
    private init() {
        print("Event mananger constructor called...")
        ref = Database.database().reference()
    }
    
    static let sharedInstance = EventManager()
    
}
