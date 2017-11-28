//
//  Contribution.swift
//  Uomi
//
//  Created by Eric Gonzalez on 11/14/17.
//  Copyright © 2017 Eric Gonzalez. All rights reserved.
//

import Foundation

enum ContributionKeys: String {
    case member
    case percent
    case description
}

protocol Contribution {
    var member: String? { get set }
    
    func getContributionAmount() -> Int
}

class PercentContribution : Contribution {
    static func ==(lhs: PercentContribution, rhs: PercentContribution) -> Bool {
        return lhs.member == rhs.member
    }
    
    var member: String?
    var percent: Int = 0
    var transaction: ExpenseTransaction
    
    init(transaction: ExpenseTransaction) {
        self.transaction = transaction
    }
    
    func getContributionAmount() -> Int {
        return transaction.total * percent
    }
    
    
}

class LineItemContribution : Contribution {
    var member: String?
    var units: Float = 1.0
    var cost: Int = 0
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
    
    func getContributionAmount() -> Int {
        return Int(round(units * Float(cost)))
    }
    
}
