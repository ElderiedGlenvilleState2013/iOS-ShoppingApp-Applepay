//
//  Modal.swift
//  ShoppingApp
//
//  Created by Thiago dos Reis on 12/12/16.
//  Copyright © 2016 Thiago dos Reis. All rights reserved.
//

import Foundation


func convertToUSD (originalValue: String) -> String {
    let index = originalValue.index(originalValue.startIndex, offsetBy: 1)
    return "$\(originalValue.substring(from: index))"
}
