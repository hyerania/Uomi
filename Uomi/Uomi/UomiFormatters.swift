//
//  UomiFormatters.swift
//  Uomi
//
//  Created by Eric Gonzalez on 11/22/17.
//  Copyright © 2017 Eric Gonzalez. All rights reserved.
//

import Foundation

struct UomiFormatters {
    static let dateFormatter = getDateFormatter()
    static let dollarFormatter = getDollarFormatter()
    static let wholeDollarFormatter = getWholeDollarFormatter()
}

func getDollarFormatter() -> NumberFormatter {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    return formatter
}

func getWholeDollarFormatter() -> NumberFormatter {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.maximumFractionDigits = 0
    return formatter
}

func getDateFormatter() -> DateFormatter {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MMMM d"
    return dateFormatter
}
