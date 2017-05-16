//
//  Helper.swift
//  Jundo
//
//  Created by TA on 30/04/2017.
//  Copyright © 2017 Splynter Inc. All rights reserved.
//

import Foundation

enum gemColour: String {
    case white = "White"
    case red = "Red"
};

class Asset {
    
    let gem = "Gem"
    let lock = "Lock"
  
    func lock(level: Int) -> String {
        return "Lock\(level)"
    }
    
    func gem(_ colour: gemColour, icon: Bool = true) -> String {
        return "\(gem)\(icon ? "Icon" : "")\(colour.rawValue)"
    }
    
};
