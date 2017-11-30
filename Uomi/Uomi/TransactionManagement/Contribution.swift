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
    case contributor
    case percent
    case description
}

protocol Contribution {
    var member: String? { get set }
    
    func getContributionAmount() -> Int
}

class PercentContribution : NSObject, Contribution {
    
    fileprivate let uuid: NSUUID = NSUUID()
    var uid: NSUUID { get { return uuid } }
    
    var member: String?
    fileprivate var percent: Int = 0
    var transaction: ExpenseTransaction
    fileprivate var isLocked: Bool = false
    
    /**
     * Necessary for KVO. DO NOT USE.
     */
    @objc dynamic var autoChanged = Date()
    
    init(transaction: ExpenseTransaction) {
        self.transaction = transaction
    }
    
    func getContributionAmount() -> Int {
        return transaction.total * percent / 100
    }
    
    func getPercent() -> Int {
        return percent
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

class PercentContributionHelper {
    static func updatePercent(contribution: PercentContribution, amount: Int, redistribute: Bool = true, lock: Bool = false) {
        contribution.percent = amount
        contribution.isLocked = lock
        
        guard redistribute else {
            return
        }
        
        // Get the non-locked cotnributions
        var lockedContributions = contribution.transaction.percentContributions.filter { (contribution) -> Bool in
            contribution.isLocked
        }
        var lockedSum = lockedContributions.map({ (contribution) -> Int in
            contribution.percent
        }).reduce(0) { (current, new) -> Int in
            current + new
        }
        
        if lockedSum >= 100 {
            // Can't have over 100%. All other transactions should be unlocked for redistribution
            for lockedContribution in lockedContributions {
                if lockedContribution != contribution {
                    lockedContribution.isLocked = false
                }
            }
            
            lockedContributions.removeAll()
            lockedContributions.append(contribution)
            lockedSum = contribution.percent
        }
        
        let unlockedContributions: [PercentContribution] = Array(Set(contribution.transaction.percentContributions).subtracting(lockedContributions))
        
        let remainingAmount = 100 - lockedSum
        let distributedPercent = remainingAmount / unlockedContributions.count
        for contrib in unlockedContributions {
            contrib.percent = distributedPercent
            contrib.autoChanged = Date()
        }
    }
}
