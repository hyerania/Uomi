//
//  TransactionBuilder.swift
//  Uomi
//
//  Created by Eric Gonzalez on 11/14/17.
//  Copyright © 2017 Eric Gonzalez. All rights reserved.
//

import Foundation

enum SplitMode: String {
    case percent
    case lineItem
}

class Transaction {
    
    var payer: String // FIXME should use account object
    var total: Float = 0.0
    var date: Date = Date()
    var description: String?
    var splitMode: SplitMode = .percent
    var contributions: [Contribution] = []
    
    init() {
        payer = AccountManager.currentUser().uid
    }
    
}
