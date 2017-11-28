//
//  TransactionManager.swift
//  Uomi
//
//  Created by Eric Gonzalez on 11/14/17.
//  Copyright © 2017 Eric Gonzalez. All rights reserved.
//

import Foundation
import Firebase
import FirebaseStorage
import UIKit

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
    var total: Int { get set }
    var payer: String { get set }
    var date: Date { get set }
    var uid: String? { get }
    var imageData: UIImage? { get set}
}

class TransactionManager {
    private var ref: DatabaseReference!
    private var storageRef: StorageReference!
    static let sharedInstance = TransactionManager()    
    
    init() {
        ref = Database.database().reference()
        storageRef = Storage.storage().reference()
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
//
//    func loadImage(id transactionId: String)
//
    // MARK: Storage
    
    func saveTransaction(event eventId: String, transaction: Transaction, success: @escaping ((Bool) -> ()) ) {
        
        let payload = transform(transaction: transaction)
        let transactionsPath = "\(transactionsChild)/\(eventId)"

        if let uid = transaction.uid {
            var updates: [String:Any] = [:]
            
            // Update existing transaction
            updates["\(transactionsPath)/\(uid)"] = payload
            
            // TODO Update owings for the transaction
            self.uploadImage(image: transaction.imageData, eventId: eventId, transactionId: uid) { (status) in
                
                if (status) {
                    self.ref.updateChildValues(updates) { (error, scope) in
                        success(error == nil)
                    }
                } else {
                    success(false)
                }
            }
            
            
        }
        else {
            // Save new transaction
            
            // TODO Validate transaction
            
            var updates: [String:Any] = [:]
            
            let key = ref.child(transactionsPath).childByAutoId().key
            self.uploadImage(image: transaction.imageData, eventId: eventId, transactionId: key) { (status) in
                
                if (status) {
                    // Add link to event reference
                    let eventTransactionsPath = "/\(eventsChild)/\(eventId)/\(transactionsChild)/\(key)"
                    updates[eventTransactionsPath] = true
                    
                    // Update main transaction payload
                    updates["\(transactionsPath)/\(key)"] = payload
                    
                    // Update owings for the transaction
                    
                    self.ref.updateChildValues(updates) { (error, scope) in
                        success(error == nil)
                    }
                } else {
                    success(false)
                }
            }
            
        }
    }
    
    func uploadImage(image: UIImage?, eventId: String, transactionId: String, completionHandler: @escaping ((Bool) -> ())) {
        if let image = image {
            var data = NSData()
            data = UIImageJPEGRepresentation(image, 0.8)! as NSData
            let filePath = "/receipts/\(eventId)/\(transactionId)"
            let metaData = StorageMetadata()
            metaData.contentType = "image/jpg"
            self.storageRef.child(filePath).putData(data as Data, metadata: metaData) { (metadata, error) in
                if let error = error {
                    print(error.localizedDescription)
                    completionHandler(false)
                    return
                } else {
                    _ = metadata?.downloadURL()?.absoluteString
                    completionHandler(true)
                    print("Image uploaded successfully.")
                }
            }
        } else {
            completionHandler(false)
        }
    }
    
    func fetchImage(eventId: String, transactionId: String, completionHandler: @escaping (UIImage?) -> ()) {
        let filePath = "/receipts/\(eventId)/\(transactionId)"
        self.storageRef.child(filePath).getData(maxSize: 10*1024*1024, completion: { (data, error) in
            
            guard
                let image = data,
                let photo = UIImage(data: image)
            else {
                completionHandler(nil)
                return
            }
            completionHandler(photo)
        })
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
        
        if let transaction = transaction as? ExpenseTransaction {
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
        
        contribPayload["contributor"] = contribution.member!
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
            let eventTransaction = ExpenseTransaction(uid: id)
            eventTransaction.payer = data[TransactionKeys.payer.rawValue] as! String
            eventTransaction.total = data[TransactionKeys.total.rawValue] as! Int
            if let time = data[TransactionKeys.date.rawValue] as? TimeInterval {
                eventTransaction.date = Date(timeIntervalSince1970: time)
            }
            eventTransaction.transDescription = data[TransactionKeys.description.rawValue] as? String
            eventTransaction.splitMode = SplitMode(rawValue: data[TransactionKeys.splitMode.rawValue] as! String)!
            
            // FIXME Uncomment when transactions have been cleaned out
//            parseContributions(for: eventTransaction, withData: data[TransactionKeys.contributions.rawValue] as! [[String:Any]])
            
            transaction = eventTransaction
        }
        else {
            // FIXME Create settlement transaction
            transaction = ExpenseTransaction()
        }
        
        return transaction
    }
    
    private func parseContributions(for transaction: ExpenseTransaction, withData data: [[String:Any]]){
        if transaction.splitMode == .percent {
            for contribData in data {
                let contribution = PercentContribution(transaction: transaction)
                contribution.member = contribData[ContributionKeys.member.rawValue] as? String
                contribution.percent = contribData[ContributionKeys.percent.rawValue] as! Int
                
                transaction.percentContributions.append(contribution)
            }
        }
        else {
            for contribData in data {
                // TODO Instantiate a line-item contribution
            }
        }
    }
    
}
