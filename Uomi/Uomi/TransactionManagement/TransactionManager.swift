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
    
    func createTransaction(event: Event, completion: @escaping ((Transaction?, Error?) -> ()) ) {
        
        // Validate transaction
        var updates: [String:Any] = [:]
        
        let key = ref.childByAutoId().key
        
        // Add link to event reference
        updates["/\(eventsChild)/\(event.getUid())/\(transactionsChild)/\(key)"] = true
        
        // FIXME Create the transaction as a map, store that instead and return the ref. Disregard the actual types for now..
        let transaction = Transaction(ref: ref.child(key))
        
        updates["\(transactionsChild)/\(key)"] = transform(transaction: transaction)
        
        ref.updateChildValues(updates) { (error, scope) in
//            completion(scope.child("\(transactionsChild)\(key)"), error)
        }
    }
    
    func editTransaction(transactionId: String, completion: @escaping ((DatabaseReference) -> ()) ) {
        completion(ref.child(transactionId))
    }
    
    func deleteTransaction(transaction: Transaction, inEvent event: Event, failure: ((Error) -> ())? ) {
        ref.child("\(eventsChild)/\(event.getUid())/\(transactionsChild)/\(transaction.getUid())").removeValue()
    }
    
    private func transform(transaction: Transaction) -> [String:Any] {
        var transactPayload: [String:Any] = [:]
        // TODO Add current user to participants
        //        transactPayload["participants/\(AccountManager.currentAccount)"]
        
        transactPayload["total"] = transaction.total
        transactPayload["description"] = transaction.description
        transactPayload["payer"] = transaction.payer
        transactPayload["splitMode"] = transaction.splitMode.rawValue
        transactPayload["date"] = transaction.date.timeIntervalSince1970
        
        return transactPayload
    }
    
    private func transform(contributions: [Contribution]) -> [[String:Any]] {
        // Map contributions to dictionaries
        return contributions.map { (contrib) -> [String : Any] in
            return transform(contribution: contrib)
        }
    }
    
    private func transform(contribution: Contribution) -> [String:Any] {
        var contribPayload: [String:Any] = [:]
        
        contribPayload["contributor"] = contribution.member?.getUid()
        if let contrib = contribution as? PercentContribution {
            contribPayload["percent"] = contrib.percent
        }
        else if let contrib = contribution as? LineItemContribution {
            contribPayload["description"] = contrib.description
        }
        
        return contribPayload
    }
}
