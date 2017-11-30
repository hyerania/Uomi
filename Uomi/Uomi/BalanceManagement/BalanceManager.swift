//
//  BalanceManager.swift
//  Uomi
//
//  Created by Yerania Yuni Hernandez on 11/15/17.
//  Copyright © 2017 Eric Gonzalez. All rights reserved.
//

import Foundation
import FirebaseDatabase

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
        AccountManager.sharedInstance.load(id: otherId){otherUser in
            guard let validUser = otherUser else{
                return
            }
            let name = validUser.getName()
            let initials = self.findInitials(fullname: name)
            EventManager.sharedInstance.fetchAmountOwed(by: otherId, event: eventId) { (amount) in
                var balanceAmount = 0.00
                if (amount != nil) {
                    balanceAmount = amount!
                }
                EventManager.sharedInstance.fetchAmountOwed(to: otherId, event: eventId) { (toAmount) in
                    var subtractAmount = 0.00
                    if (toAmount != nil) {
                        subtractAmount = toAmount!
                    }
                    let balance = Balance(initials: initials, name: name, uid: otherId, eventuid: eventId, totalBalance: "$" + "0", balance: balanceAmount - subtractAmount)
                    completionHandler(balance)
                }
                
            }
            
            
        }
    }
    
    // MARK: - Settle
    func loadSettleList(userId: String, eventId: String, otherUserId: String, completionHandler: @escaping([Settle]) -> ()){
        var userSettleList = [Settle]()
        
        self.ref.child("/owings").child(eventId).observeSingleEvent(of: .value, with: { (snapshot) in
            guard let owingTransactiosn = snapshot.value as? NSDictionary else {
                print("Error with getting object from owings.")
                completionHandler(userSettleList)
                return
            }

            for transactionObj in owingTransactiosn {
                guard
                    let transactionId = transactionObj.key as? String,
                    let transaction = transactionObj.value as? NSDictionary,
                    let payer = transaction["payer"] as? String,
                    let owers = transaction["owers"] as? NSDictionary
                    else {
                        print("Invalid data for this transaction. Moving on to the next one.")
                        continue
                }
                
                var balanceOweMe: Double = 0.00
                var balanceOweTo: Double = 0.00
                
                if (payer == userId) {
                    
                    for ower in owers {
                        guard let owerId = ower.key as? String, let amount = ower.value as? Double else {
                            print("Invalid data for this transaction. Moving on to the next one.")
                            continue
                        }
                        if (owerId == otherUserId) {
                            balanceOweMe = amount
                        }
                    }
                    
                }
                if (payer == otherUserId){
                    for ower in owers {
                        guard let owerId = ower.key as? String, let amount = ower.value as? Double else {
                            print("Invalid data for this transaction. Moving on to the next one.")
                            continue
                        }
                        if (owerId == userId) {
                            balanceOweTo = amount
                        }
                    }
                    
                }
                let settle = Settle(transactionId: transactionId, balanceOweTo: balanceOweTo, balanceOweMe: balanceOweMe)
                userSettleList.append(settle)
                
            
            }
            completionHandler(userSettleList)
        })
        
    }
    
    // MARK: - Helper Functions
    func totalBalance(userId: String, otherId: String, eventId: String) -> String{
        //Must get total of each transaction
        var totalBalance = 0.00;
        
        
        return " "
    }
    
    func balance(userId: String, otherId: String, eventId: String) -> String{
        var balanceOweTo = 0.00
        
        var balanceOweMe = 0.00
        
        return " "
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
    
    func getOwingBalances(user userId: String, event eventId: String, completion: @escaping ((Int, Int) -> ())) {
            loadBalanceList(userId: userId, eventId: eventId) { (balances) in
                var owed = 0
                var isOwed = 0
                
                for balance in balances {
                    if (balance.getBalance() > 0.00) {
                        isOwed += balance.getBalance()
                    } else {
                        owed += balance.getBalance()
                    }
                }
                
                completion(owed, isOwed)
        }
    }
}
