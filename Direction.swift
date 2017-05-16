//
//  Direction.swift
//  Jundo
//
//  Created by TA on 02/05/2017.
//  Copyright © 2017 Splynter Inc. All rights reserved.
//

enum directions: Int {
    
    case up = 1, down = 2, left = 4, right = 8
    
    func opposite() -> directions {
        switch self{
        case .up: return .down
        case .down: return .up
        case .left: return .right
        case .right: return .left
        }
    }
    
    func toString() -> String {
        switch self {
        case .up: return "up"
        case .down: return "down"
        case .left: return "left"
        case .right: return "right"
        }
    }
    
}
