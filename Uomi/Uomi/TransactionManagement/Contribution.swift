//
//  Contribution.swift
//  Uomi
//
//  Created by Eric Gonzalez on 11/14/17.
//  Copyright © 2017 Eric Gonzalez. All rights reserved.
//

import Foundation

protocol Contribution {
    var member: User? { get set }
    
    func getContributionAmount() -> Float
}

class PercentContribution : Contribution {
    var member: User?
    var percent: Float = 0
    var transaction: Transaction
    
    init(transaction: Transaction) {
        self.transaction = transaction
    }
    
    func getContributionAmount() -> Float {
        return transaction.total * percent
    }
}

class LineItemContribution : Contribution {
    var member: User?
    var units: Float = 1.0
    var cost: Float = 0
    var description: String? {
        didSet {
            parseDescription(description: description)
        }
    }
    
    func parseDescription(description: String?) {
        if let description = description {
            // TODO parse out unit
            // TODO parse out description
            // TODO parse out cost per unit
        }
        else {
            // Reset variables
            units = 1
            cost = 0
            self.description = nil
        }
    }
    
    func getContributionAmount() -> Float {
        return units * cost
    }
    
}
