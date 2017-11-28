//
//  Contribution.swift
//  Uomi
//
//  Created by Eric Gonzalez on 11/14/17.
//  Copyright © 2017 Eric Gonzalez. All rights reserved.
//

import Foundation

let descriptionParseRegex = "^\\s*(\\d*\\.?\\d*)?.*@(\\d*\\.?\\d*)"

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
    var description: String?
    
    func getContributionAmount() -> Int {
        
        if let description = description {
            do {
                let regex = try NSRegularExpression(pattern: descriptionParseRegex)
                if let match = regex.firstMatch(in: description, options: [], range: NSRange(description.startIndex..., in: description)),
                    let costRange = Range(match.range(at: 2), in: description),
                    let cost = Float(description[costRange])
                {
                    var units: Float = 1.0
                    if let unitRange = Range(match.range(at: 1), in: description),
                        let parsedUnits = Float(description[unitRange]) {
                        units = parsedUnits
                    }
                    
                    return Int(round(units * cost * 100))
                }
            }
            catch {
                print("Exception!")
            }
        }
        
        return 0
        
    }
    
}
