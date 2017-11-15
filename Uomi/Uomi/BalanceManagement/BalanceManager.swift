//
//  BalanceManager.swift
//  Uomi
//
//  Created by Yerania Yuni Hernandez on 11/15/17.
//  Copyright © 2017 Eric Gonzalez. All rights reserved.
//

import Foundation
import FirebaseDatabase

class BalanceManager{
    var ref: DatabaseReference!
    
    
    
    private init() {
        print("Balance mananger constructor called...")
        ref = Database.database().reference()
    }
    
    static let sharedInstance = BalanceManager()
}
