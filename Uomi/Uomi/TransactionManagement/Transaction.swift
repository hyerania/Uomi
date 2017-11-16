//
//  TransactionBuilder.swift
//  Uomi
//
//  Created by Eric Gonzalez on 11/14/17.
//  Copyright © 2017 Eric Gonzalez. All rights reserved.
//

import Foundation
import Firebase

enum TransactionKeys : String {
    case payer
    case total
    case date
    case description
    case splitMode
    case contributions
}

enum SplitMode: String {
    case percent
    case lineItem
}

class Transaction {
    
    let ref: DatabaseReference
    
    var uid: String { get { return ref.key } }
    var payer: String?  { didSet { ref.updateChildValues([TransactionKeys.payer : payer!]) } }
    var total: Float? { didSet { ref.updateChildValues([TransactionKeys.total : total]) } }
    var date: Date? { didSet { ref.updateChildValues([TransactionKeys.date : date]) } }
    var description: String? { didSet { ref.updateChildValues([TransactionKeys.description : description!]) } }
    var splitMode: SplitMode = .percent { didSet { ref.updateChildValues([TransactionKeys.splitMode : splitMode]) } }
    private var contributions: DatabaseReference!
    
    init(ref: DatabaseReference) {
        self.ref = ref
        
        ref.observe(.value) { (snapshot) in
            
        }
        
        self.contributions = ref.child(TransactionKeys.contributions.rawValue)
    }
    
    func getUid() -> String {
        return ref.key
    }
    
}
