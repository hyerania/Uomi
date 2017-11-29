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
    private var balanceOweTo: Double
    private var balanceOweMe: Double
    
    init(transactionId: String, balanceOweTo: Double, balanceOweMe: Double){
        self.transactionId = transactionId
        self.balanceOweTo = balanceOweTo
        self.balanceOweMe = balanceOweMe
    }
    
    func getTransactionId() -> String{
        return self.transactionId
    }
    func getBalanaceOweTo() -> Double{
        return self.balanceOweTo
    }
    func getBalanceOweMe() -> Double {
        return self.balanceOweMe
    }
    
}

