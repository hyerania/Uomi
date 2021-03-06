//
//  TransactionBuilder.swift
//  Uomi
//
//  Created by Eric Gonzalez on 11/14/17.
//  Copyright © 2017 Eric Gonzalez. All rights reserved.
//

import Foundation
import UIKit


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
    var percentContributions: [PercentContribution] = []
    var lineItemContributions: [LineItemContribution] = []
    var contributions: [Contribution] {
        get {
            if splitMode == .percent {
                return percentContributions
            }
            else {
                return lineItemContributions
            }
        }
    }
    var receiptImageUID: String?
    var imageData: UIImage?

    init(uid: String? = nil) {
        self.uid = uid
    }
    
}
