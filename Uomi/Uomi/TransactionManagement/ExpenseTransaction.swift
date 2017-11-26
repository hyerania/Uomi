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

class ExpenseTransaction : Transaction {
    
    let uid: String?
    var payer: String = "" // FIXME should use account object
    var total: Int = 0
    var date: Date = Date()
    var transDescription: String?
    var splitMode: SplitMode = .percent
    var contributions: [Contribution] = []
    var percentContributions: [Contribution] {
        get {
            return contributions.filter({ (contrib) -> Bool in
                return contrib is PercentContribution
            })
        }
    }
    var lineItemContributions: [Contribution] {
        get {
            return contributions.filter({ (contrib) -> Bool in
                return contrib is LineItemContribution
            })
        }
    }
    
    init(uid: String? = nil) {
        self.uid = uid
    }
    
}
