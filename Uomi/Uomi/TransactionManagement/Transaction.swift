//
//  TransactionBuilder.swift
//  Uomi
//
//  Created by Eric Gonzalez on 11/14/17.
//  Copyright © 2017 Eric Gonzalez. All rights reserved.
//

import Foundation

enum TransactionCategory {
    case dining
    case gas
}

enum SplitMode: String {
    case percent
    case lineItem
}

class Transaction {
    
    var payer: User? // FIXME should use account object
    var total: Float = 0.0
    var date: Date = Date()
    var category: TransactionCategory?
    var description: String?
    var splitMode: SplitMode = .percent
    var contributions: [Contribution] = []
    
    init() {
        
    }
    
}
