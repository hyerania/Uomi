//
//  SettlementTransaction.swift
//  Uomi
//
//  Created by Eric Gonzalez on 11/21/17.
//  Copyright © 2017 Eric Gonzalez. All rights reserved.
//

import Foundation

class SettlementTransaction : Transaction {

    let uid: String?
    var payer: String = "" // FIXME should use account object
    var total: Int = 0
    var date: Date = Date()
    var recipient: String = ""
    
    init(uid: String? = nil) {
        self.uid = uid
    }
    

}
