//
//  TransactionManager.swift
//  Uomi
//
//  Created by Eric Gonzalez on 11/14/17.
//  Copyright © 2017 Eric Gonzalez. All rights reserved.
//

import Foundation
import Firebase

let eventsChild = "events"
let transactionsChild = "transactions"

class TransactionManager {
    private var ref: DatabaseReference!
    
    private static var sharedTransactionManager: TransactionManager = {
        let transactionManager = TransactionManager()
        
        // Configuration
        // ...
        
        return transactionManager
    }()
    
    class func shared() -> TransactionManager {
        return sharedTransactionManager
    }
    
    
    init() {
        ref = Database.database().reference()
    }
    
    func createTransaction(event: Event, completion: ((DatabaseReference?, Error?) -> ())? ) throws {
        
        // Validate transaction
        var updates: [String:Any] = [:]
        
        let key = ref.childByAutoId().key
        
        // Add link to event reference
        updates["/\(eventsChild)/\(event.uid)/\(transactionsChild)/\(key)"] = true
        updates["\(transactionsChild)/\(key)"] = transform(transaction: Transaction())
        
        ref.updateChildValues(updates) { (error, scope) in
            if let completion = completion {
                completion(scope.child("\(transactionsChild)\(key)"), error)
            }
        }
    }
    
    private func transform(transaction: Transaction) -> [String:Any] {
        var transactPayload: [String:Any] = [:]
        // TODO Add current user to participants
        //        transactPayload["participants/\(AccountManager.currentAccount)"]
        
        transactPayload["total"] = transaction.total
        transactPayload["contributions"] = transform(contributions: transaction.contributions)
        if let description = transaction.description {
            transactPayload["description"] = description
        }
        transactPayload["payer"] = transaction.payer
        transactPayload["splitMode"] = transaction.splitMode.rawValue
        transactPayload["date"] = transaction.date.timeIntervalSince1970
        
        return transactPayload
    }
    
    private func transform(contributions: [Contribution]) -> [[String:Any]] {
        // TODO map contributions to dictionaries
    }
}
