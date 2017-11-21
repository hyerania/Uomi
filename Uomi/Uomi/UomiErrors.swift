//
//  UomiErrors.swift
//  Uomi
//
//  Created by Eric Gonzalez on 11/14/17.
//  Copyright © 2017 Eric Gonzalez. All rights reserved.
//

import Foundation

enum UomiErrors : Error {
    case invalidArgument(reason: String)
    case retrievalError
}
