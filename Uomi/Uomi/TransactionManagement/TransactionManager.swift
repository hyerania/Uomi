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
    
    func createTransaction(event: Event, transaction: Transaction, completion: ((Bool, Error?) -> ())? ) throws {
        
        // Validate transaction
        guard transaction.category != nil else {
            throw UomiErrors.invalidArgument(reason: "Category is required")
        }
        guard transaction.payer != nil else {
            throw UomiErrors.invalidArgument(reason: "Payer is required")
        }
        
        var updates: [String:Any] = [:]
        
        let key = ref.childByAutoId().key
        
        // Add link to event reference
        updates["/\(eventsChild)/\(event.uid)/\(transactionsChild)/\(key)"] = true
        updates["\(transactionsChild)/\(key)"] = transform(transaction: transaction)
        
        ref.updateChildValues(updates) { (error, scope) in
            if let completion = completion {
                completion(error == nil, error)
            }
        }
    }
    
    private func transform(transaction: Transaction) -> [String:Any] {
        var transactPayload: [String:Any] = [:]
        // TODO Add current user to participants
        //        transactPayload["participants/\(AccountManager.currentAccount)"]
        
        transactPayload["total"] = transaction.total
        transactPayload["category"] = transaction.category!
        transactPayload["contributions"] = transform(contributions: transaction.contributions)
        transactPayload["description"] = transaction.description
        transactPayload["payer"] = transaction.payer!.uid
        transactPayload["splitMode"] = transaction.splitMode.rawValue
        transactPayload["date"] = transaction.date.timeIntervalSince1970
        // TODO Set a default name?
        // TODO Add linkage to contributions
     
        return transactPayload
    }
    
    private func transform(contributions: [Contribution]) -> [[String:Any]] {
    
    }
}
