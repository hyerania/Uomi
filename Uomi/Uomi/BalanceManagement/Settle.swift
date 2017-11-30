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
    private var date: Date
    private var total: Int
    private var isSettle: Bool
    private var description: String
    private var payerId: String
    
    init(transactionId: String, balanceOweTo: Double, balanceOweMe: Double){
        self.transactionId = transactionId
        self.balanceOweTo = balanceOweTo
        self.balanceOweMe = balanceOweMe
        self.date = Date()
        self.total = 0
        self.isSettle = true
        self.description = ""
        self.payerId = ""
    }
    
    func getTransactionId() -> String{
        return self.transactionId
    }
    func getBalanceOweTo() -> Double{
        return self.balanceOweTo
    }
    func getBalanceOweMe() -> Double {
        return self.balanceOweMe
    }
    func getDate() -> Date {
        return self.date
    }
    func setDate(date: Date) {
        self.date = date
    }
    func setTotal(total: Int) {
        self.total = total
    }
    func getTotal() -> Int {
        return self.total
    }
    func getIsSettle() -> Bool {
        return self.isSettle
    }
    func setIsSettle(isSettle: Bool) {
        self.isSettle = isSettle
    }
    func getDescription() -> String {
        return self.description
    }
    func setDescription(description: String) {
        self.description = description
    }
    func setPayerId(payerId: String) {
        self.payerId = payerId
    }
    func getPayerId() -> String {
        return self.payerId
    }
}

