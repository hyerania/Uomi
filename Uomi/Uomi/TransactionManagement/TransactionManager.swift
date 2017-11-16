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
    
    static let sharedInstance = TransactionManager()    
    
    init() {
        ref = Database.database().reference()
    }
    
    func createTransaction(event: Event, completion: @escaping ((Transaction?, Error?) -> ()) ) {
        
        // Validate transaction
        var updates: [String:Any] = [:]
        
        let key = ref.childByAutoId().key
        
        // Add link to event reference
        updates["/\(eventsChild)/\(event.getUid())/\(transactionsChild)/\(key)"] = true
        
        let transaction: Transaction = Transaction(uid: key)
        updates["\(transactionsChild)/\(key)"] = transform(transaction: transaction)
        
        ref.updateChildValues(updates) { (error, scope) in
            completion(error == nil ? transaction : nil, error)
        }
    }
    
    func loadTransactions(eventId: String, completion: @escaping (([Transaction]?) -> ()) ) {
        ref.child("\(eventsChild)/\(eventId)/\(transactionsChild)").observeSingleEvent(of: .value) { (snapshot) in
            if let snapshot = snapshot.value as? [String: Bool] {
                
                // FIXME Instead, return a lightweight object of transaction identifiers to be rendered. The full objects can be queried for using loadTransaction(id:completion:)
                var transactions: [Transaction] = [Transaction](repeating: nil, count: snapshot.count)
                
                snapshot.forEach({ (transId, _) in
                    self.ref.child("\(transactionsChild)/\(transId)").observeSingleEvent(of: .value, with: { (transSnapshot) in
                        let transaction = self.parseTransaction(id: transId, data: transSnapshot.value as! [String:Any])
                        
                    })
                })
            }
            else {
                completion(nil)
            }
        }
    }
    
    func loadTransaction(id transactionId: String, completion: @escaping ((Transaction?, Error?) -> ())) {
        self.ref.child(transactionId).observeSingleEvent(of: .value) { (snapshot) in
            if let transData = snapshot.value as? [String:Any] {
                let transaction = self.parseTransaction(id: transactionId, data: transData)
                completion(transaction, nil)
            }
            else {
                completion(nil, UomiErrors.retrievalError)
            }
        }
    }
    
    func saveTransaction(transaction: Transaction, success: @escaping ((Bool) -> ()) ) {
        
        let payload = transform(transaction: transaction)
        
        self.ref.child(transactionsChild).updateChildValues([transaction.uid : payload]) { (error, transRef) in
            success(error == nil)
        }
    }
    
    func deleteTransaction(transaction: Transaction, inEvent event: Event, failure: ((Error) -> ())? ) {
        ref.child("\(eventsChild)/\(event.getUid())/\(transactionsChild)/\(transaction.getUid())").removeValue()
    }
    
    
    //MARK: - Transforms
    
    private func transform(transaction: Transaction) -> [String:Any] {
        var transactPayload: [String:Any] = [:]
        // TODO Add current user to participants
        //        transactPayload["participants/\(AccountManager.currentAccount)"]
        
        transactPayload["total"] = transaction.total
        transactPayload["contributions"] = transform(contributions: transaction.contributions)
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
    
    private func parseTransaction(id: String, data: [String:Any]) -> Transaction {
        let transaction = Transaction(uid: id)
        transaction.payer = data[TransactionKeys.payer.rawValue] as? String
        transaction.total = data[TransactionKeys.total.rawValue] as! Float
        transaction.date = data[TransactionKeys.date.rawValue] as! Date
        transaction.description = data[TransactionKeys.description.rawValue] as? String
        transaction.splitMode = SplitMode(rawValue: data[TransactionKeys.splitMode.rawValue] as! String)!
        transaction.contributions = parseContributions(withData: data[TransactionKeys.contributions.rawValue] as? [String:Any])
        
        return transaction
    }
    
    private func parseContributions(withData: [String:Any]?) -> [Contribution] {
        return []
    }
    
}
