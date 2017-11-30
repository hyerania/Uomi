//
//  Balance.swift
//  Uomi
//
//  Created by Yerania Yuni Hernandez on 11/16/17.
//  Copyright © 2017 Eric Gonzalez. All rights reserved.
//

import Foundation

class Balance {
    private var initials: String
    private var name: String
    private var uid: String
    private var eventuid: String
    private var totalBalance: String
    private var balance: Int
    
    init(initials: String, name: String, uid: String, eventuid: String, totalBalance: String, balance: Int){
        self.initials = initials
        self.name = name
        self.uid = uid
        self.eventuid = eventuid
        self.totalBalance = totalBalance
        self.balance = balance
    }
    
    func getInitials() -> String{
        return self.initials
    }
    func getName() -> String {
        return self.name
    }
    func getUid() -> String {
        return self.uid
    }
    func getEventuid() -> String {
        return self.eventuid
    }
    func getTotalBalance() -> String {
        return self.totalBalance
    }
    func getBalance() -> Int {
        return self.balance
    }
    func setBalance(newBalance: Int) {
        self.balance = newBalance
    }
    
}
