//
//  TransactionBuilder.swift
//  Uomi
//
//  Created by Eric Gonzalez on 11/14/17.
//  Copyright © 2017 Eric Gonzalez. All rights reserved.
//

import Foundation

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
    
    let uid: String
    var payer: String? // FIXME should use account object
    var total: Float = 0.0
    var date: Date = Date()
    var transDescription: String?
    var splitMode: SplitMode = .percent
    var contributions: [Contribution] = []
    
    init(uid: String) {
       self.uid = uid
    }
    
    func getUid() -> String {
        return uid
    }
    
}
