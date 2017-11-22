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

enum TransactionKeys : String {
    case payer
    case total
    case date
    case description
    case splitMode
    case contributions
}

protocol Transaction {
    var total: Float { get set }
    var payer: String { get set }
    var date: Date { get set }
    var uid: String? { get }
}

class TransactionManager {
    private var ref: DatabaseReference!
    
    static let sharedInstance = TransactionManager()    
    
    init() {
        ref = Database.database().reference()
    }
    
    
    //MARK: Fetching transactions
    
    func loadTransactions(eventId: String, completion: @escaping (([Transaction]?) -> ()) ) {
        ref.child("\(transactionsChild)/\(eventId)/").observeSingleEvent(of: .value) { (snapshot) in
            if let snapshot = snapshot.value as? [String: [String: Any]] {
                let transactions = snapshot.map({ (key, data) -> Transaction in
                    return self.parseTransaction(id: key, data: data)
                })
                
                completion(transactions)
            }
            else {
                completion([])
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
    
    
    // MARK: Storage
    
    func saveTransaction(event eventId: String, transaction: Transaction, success: @escaping ((Bool) -> ()) ) {
        
        let payload = transform(transaction: transaction)
        
        if let uid = transaction.uid {
            self.ref.child(transactionsChild).updateChildValues([uid : payload]) { (error, transRef) in
                success(error == nil)
            }
        }
        else {
            // Save new transaction
            
            // Validate transaction
            var updates: [String:Any] = [:]
            
            let transactionsPath = "\(transactionsChild)/\(eventId)"
            let key = ref.child(transactionsPath).childByAutoId().key
            
            // Add link to event reference
            let eventTransactionsPath = "/\(eventsChild)/\(eventId)/\(transactionsChild)/\(key)"
            updates[eventTransactionsPath] = true
            
            // Prepare initial version of transaction
            updates["\(transactionsPath)/\(key)"] = transform(transaction: transaction)
            
            ref.updateChildValues(updates) { (error, scope) in
                success(error == nil)
            }
        }
    }
    
    func deleteTransaction(transaction: Transaction, inEvent event: Event, failure: ((Error) -> ())? ) {
        
        // Only need to contact Firebase in event that uid is set; otherwise is temporary location
        if let uid = transaction.uid {
            ref.child("\(eventsChild)/\(event.getUid())/\(transactionsChild)/\(uid)").removeValue()
        }
    }
    
    
    //MARK: - Transforms
    
    private func transform(transaction: Transaction) -> [String:Any] {
        var transactPayload: [String:Any] = [:]
        // TODO Add current user to participants
        //        transactPayload["participants/\(AccountManager.currentAccount)"]
        
        transactPayload["total"] = transaction.total
        transactPayload["payer"] = transaction.payer
        transactPayload["date"] = transaction.date.timeIntervalSince1970
        
        if let transaction = transaction as? EventTransaction {
            transactPayload["contributions"] = transform(contributions: transaction.contributions)
            transactPayload["description"] = transaction.transDescription
            transactPayload["splitMode"] = transaction.splitMode.rawValue
        }
        
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
        var transaction: Transaction
        
        if let contributions = data[TransactionKeys.splitMode.rawValue] as? String {
            let eventTransaction = EventTransaction(uid: id)
            eventTransaction.payer = data[TransactionKeys.payer.rawValue] as! String
            eventTransaction.total = data[TransactionKeys.total.rawValue] as! Float
            if let time = data[TransactionKeys.date.rawValue] as? TimeInterval {
                eventTransaction.date = Date(timeIntervalSince1970: time)
            }
            eventTransaction.transDescription = data[TransactionKeys.description.rawValue] as? String
            eventTransaction.splitMode = SplitMode(rawValue: data[TransactionKeys.splitMode.rawValue] as! String)!
            eventTransaction.contributions = parseContributions(withData: data[TransactionKeys.contributions.rawValue] as? [String:Any])
            
            transaction = eventTransaction
        }
        else {
            // FIXME Create settlement transaction
            transaction = EventTransaction()
        }
        
        return transaction
    }
    
    private func parseContributions(withData: [String:Any]?) -> [Contribution] {
        return []
    }
    
}
