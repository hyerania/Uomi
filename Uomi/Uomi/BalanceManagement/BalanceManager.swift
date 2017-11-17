//
//  BalanceManager.swift
//  Uomi
//
//  Created by Yerania Yuni Hernandez on 11/15/17.
//  Copyright © 2017 Eric Gonzalez. All rights reserved.
//

import Foundation
import FirebaseDatabase

//private var initials: String
//private var name: String
//private var uid: String
//private var eventuid: String
//private var totalBalance: String
//private var balance: String

class BalanceManager{
    var ref: DatabaseReference!
    
    
    func loadBalanceList(userId: String, eventId: String, completionHandler: @escaping([Balance]) -> ()){
        var userBalanceList = [Balance]()
        
        EventManager.sharedInstance.loadEvent(id: eventId){event in
            guard let event = event else{
                print("Error getting event.")
                return
            }

            var count = 0
            for id in event.getContributors(){
                if(id == userId){
                    continue
                }
                AccountManager.sharedInstance.load(id: id){otherUser in
                    guard let validUser = otherUser else{
                        return
                    }
                    let validUserId = validUser.getUid()
                    self.loadBalance(userId: userId, otherId: validUserId, eventId: eventId){ balance in
                        count = count + 1
                        if (balance != nil){
                            userBalanceList.append(balance!)
                        }
                        if(count == event.getContributors().count-1){
                            completionHandler(userBalanceList)
                        }
                    }
                }
            }
        }
    }
    
    func loadBalance(userId: String, otherId: String, eventId: String, completionHandler: @escaping(Balance?) -> ()){
        EventManager.sharedInstance.loadEvent(id: eventId){event in
            guard let event = event else{
                print("Error getting event.")
                return
            }

            AccountManager.sharedInstance.load(id: otherId){otherUser in
                guard let validUser = otherUser else{
                    return
                }
                let name = validUser.getName()
                let initials = self.findInitials(fullname: name)

                
                
                let balance = Balance(initials: initials, name: name, uid: otherId, eventuid: eventId, totalBalance: "0", balance: "0")
                completionHandler(balance)
            }

            
        }
    }
    
    func findInitials(fullname: String) -> String{
        let delimiter = " "
        var token = fullname.components(separatedBy: delimiter)
        var initials = ""
        
        if(token.count == 1){
            let firstName = token[0]
            let firstIndex = firstName.index(firstName.startIndex, offsetBy: 1)
            initials = String(firstName.prefix(upTo: firstIndex))
            return initials
        }
        else if(token.count == 2){
            let firstName = token[0]
            let lastName = token[1]
            
            let firstIndex = firstName.index(firstName.startIndex, offsetBy: 1)
            let lastIndex = lastName.index(lastName.startIndex, offsetBy: 1)
            
            initials = String(firstName.prefix(upTo: firstIndex)) + String(lastName.prefix(upTo: lastIndex))
            return initials
        }
        else if (token.count == 3){
            let firstName = token[0]
            let middleName = token[1]
            let lastName = token[2]
            
            let firstIndex = firstName.index(firstName.startIndex, offsetBy: 1)
            let middleIndex = middleName.index(middleName.startIndex, offsetBy: 1)
            let lastIndex = lastName.index(lastName.startIndex, offsetBy: 1)
            
            initials = String(firstName.prefix(upTo: firstIndex)) +                 String(middleName.prefix(upTo: middleIndex)) +
                String(lastName.prefix(upTo: lastIndex))
            return initials
        }
        else{
            initials = "Uomi"
            return initials
        }
    }
    
    private init() {
        print("Balance mananger constructor called...")
        ref = Database.database().reference()
    }
    
    static let sharedInstance = BalanceManager()
}
