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

let owingsChild = "owings"
let eventsChild = "events"
let transactionsChild = "transactions"

enum OwingsKeys : String {
    case payer
    case owers
}

enum TransactionKeys : String {
    case payer
    case total
    case date
    case description
    case splitMode
    case contributions
    case recipient
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
    
    func loadTransaction(id eventId: String, id transactionId: String, completion: @escaping ((Transaction?, Error?) -> ())) {
        self.ref.child("/transactions").child(eventId).child(transactionId).observeSingleEvent(of: .value) { (snapshot) in
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
    
    fileprivate func updateSavedTransaction(_ transactionsPath: String, _ uid: String, _ payload: [String : Any], _ transaction: Transaction, _ eventId: String, _ success: @escaping ((Bool) -> ())) {
        var updates: [String:Any] = [:]
        
        // Update existing transaction
        updates["\(transactionsPath)/\(uid)"] = payload
        
        // Update owings for the transaction
        let owingsPayload = self.getOwingsPayload(transaction: transaction)
        updates["\(owingsChild)/\(eventId)/\(uid)"] = owingsPayload
        
        self.ref.updateChildValues(updates) { (error, scope) in
            success(error == nil)
        }
        
        if let transaction = transaction as? ExpenseTransaction, let imageData = transaction.imageData {
            self.uploadImage(image: imageData, eventId: eventId, transactionId: uid) { (didSave) in
                if !didSave {
                    print("Failed to save image")
                }
            }
        }
    }
    
    fileprivate func saveNewTransaction(_ transactionsPath: String, _ eventId: String, _ payload: [String : Any], _ transaction: Transaction, _ success: @escaping ((Bool) -> ())) {
        // Save new transaction
        
        var updates: [String:Any] = [:]
        
        let key = ref.child(transactionsPath).childByAutoId().key
        
        // Add link to event reference
        let eventTransactionsPath = "/\(eventsChild)/\(eventId)/\(transactionsChild)/\(key)"
        updates[eventTransactionsPath] = true
        
        // Update main transaction payload
        updates["\(transactionsPath)/\(key)"] = payload
        
        // Update owings for the transaction
        let owingsPayload = self.getOwingsPayload(transaction: transaction)
        updates["\(owingsChild)/\(eventId)/\(key)"] = owingsPayload
        
        self.ref.updateChildValues(updates) { (error, scope) in
            success(error == nil)
        }
        
        if let transaction = transaction as? ExpenseTransaction, let imageData = transaction.imageData {
            self.uploadImage(image: imageData, eventId: eventId, transactionId: key) { (didSave) in
                if !didSave {
                    print("Failed to save new transaction image")
                }
            }
        }
    }
    
    func saveTransaction(event eventId: String, transaction: Transaction, success: @escaping ((Bool) -> ()) ) {
        
        let payload = transform(transaction: transaction)
        let transactionsPath = "\(transactionsChild)/\(eventId)"
        
        if let uid = transaction.uid {
            updateSavedTransaction(transactionsPath, uid, payload, transaction, eventId, success)
        }
        else {
            saveNewTransaction(transactionsPath, eventId, payload, transaction, success)
            EventManager.sharedInstance.updateEventTime(eventId: eventId, date: transaction.date) { (res) in
                print("Time updated: \(res)")
            }
        }
        
    }
    
    func uploadImage(image: UIImage, eventId: String, transactionId: String, completionHandler: @escaping ((Bool) -> ())) {
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
        
        transactPayload[TransactionKeys.total.rawValue] = transaction.total
        transactPayload[TransactionKeys.payer.rawValue] = transaction.payer
        transactPayload[TransactionKeys.date.rawValue] = transaction.date.timeIntervalSince1970
        
        if let transaction = transaction as? ExpenseTransaction {
            transactPayload[TransactionKeys.contributions.rawValue] = transform(contributions: transaction.contributions)
            transactPayload[TransactionKeys.description.rawValue] = transaction.transDescription
            transactPayload[TransactionKeys.splitMode.rawValue] = transaction.splitMode.rawValue
        }
        else if let transaction = transaction as? SettlementTransaction {
            transactPayload[TransactionKeys.recipient.rawValue] = transaction.recipient
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
        
        let totalValue: Int = data[TransactionKeys.total.rawValue] as! Int
        let payer: String = data[TransactionKeys.payer.rawValue] as! String
        let date = Date(timeIntervalSince1970: data[TransactionKeys.date.rawValue] as! TimeInterval)

        if let splitMode = data[TransactionKeys.splitMode.rawValue] as? String {
            let eventTransaction = ExpenseTransaction(uid: id)
            eventTransaction.payer = payer
            eventTransaction.total = totalValue
            
            eventTransaction.date = date
            eventTransaction.transDescription = data[TransactionKeys.description.rawValue] as? String
            eventTransaction.splitMode = SplitMode(rawValue: splitMode)!
            
            if let contributions = data[TransactionKeys.contributions.rawValue] as? [[String:Any]] {
                parseContributions(for: eventTransaction, withData: contributions)
            }
            
            transaction = eventTransaction
        }
        else {
            //  Create settlement transaction
            let settlementTransaction = SettlementTransaction()
            settlementTransaction.recipient = data[TransactionKeys.recipient.rawValue] as! String
            settlementTransaction.payer = payer
            settlementTransaction.date = date
            settlementTransaction.total = totalValue
            
            transaction = settlementTransaction
        }
        
        return transaction
    }
    
    private func parseContributions(for transaction: ExpenseTransaction, withData data: [[String:Any]]){
        if transaction.splitMode == .percent {
            for contribData in data {
                let contribution = PercentContribution(transaction: transaction)
                contribution.member = contribData[ContributionKeys.contributor.rawValue] as? String
                contribution.percent = contribData[ContributionKeys.percent.rawValue] as! Int
                
                transaction.percentContributions.append(contribution)
            }
        }
        else {
            for contribData in data {
                // TODO Instantiate a line-item contribution
                let contribution = LineItemContribution()
                contribution.member = contribData[ContributionKeys.contributor.rawValue] as? String
                contribution.description = contribData[ContributionKeys.description.rawValue] as? String
                
                transaction.lineItemContributions.append(contribution)
            }
        }
    }
    
    private func getOwingsPayload(transaction: Transaction) -> [String:Any] {
        var owingsPayload: [String:Any] = [:]
        owingsPayload[OwingsKeys.payer.rawValue] = transaction.payer
        if let transaction = transaction as? ExpenseTransaction {
            owingsPayload[OwingsKeys.owers.rawValue] = transaction.contributions.filter({ (contribution) -> Bool in
                return contribution.member != transaction.payer
            }).map({ (contribution) -> [String:Int] in
                return [contribution.member! : contribution.getContributionAmount()]
            }).reduce([:], { (current, pair) -> [String:Int] in
                current.merging(pair, uniquingKeysWith: { (current, added) -> Int in
                    current + added
                })
            })
        }
        else if let transaction = transaction as? SettlementTransaction {
            owingsPayload[OwingsKeys.owers.rawValue] = [transaction.recipient : transaction.total]
        }
        else {
            print("Unknown transaction type, can't save owings")
        }
        
        return owingsPayload
    }
    
}
