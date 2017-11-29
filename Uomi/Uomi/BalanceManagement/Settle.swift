//
//  Settle.swift
//  Uomi
//
//  Created by Yerania Yuni Hernandez on 11/29/17.
//  Copyright © 2017 Eric Gonzalez. All rights reserved.
//

import Foundation

class Settle {
    private var transactionId: String
    private var transactionName: String
    private var transactionDate: Date
    private var transactionTotal: Double
    private var balanceOweTo: Double
    private var balanceOweMe: Double
    
    init(transactionId: String, transactionName: String, transactionDate: Date, transactionTotal: Double, balanceOweTo: Double, balanceOweMe: Double){
        self.transactionId = transactionId
        self.transactionName = transactionName
        self.transactionDate = transactionDate
        self.transactionTotal = transactionTotal
        self.balanceOweTo = balanceOweTo
        self.balanceOweMe = balanceOweMe
    }
    
    func getTransactionId() -> String{
        return self.transactionId
    }
    func getTransactionName() -> String{
        return self.transactionName
    }
    func getTransactionDate() -> Date{
        return self.transactionDate
    }
    func getTransactionTotal() -> Double{
        return self.transactionTotal
    }
    func getBalanaceOweTo() -> Double{
        return self.balanceOweTo
    }
    func getBalanceOweMe() -> Double {
        return self.balanceOweMe
    }
    
}

