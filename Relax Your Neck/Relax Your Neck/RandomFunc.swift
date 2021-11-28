//
//  RandomFunc.swift
//  Relax Your Neck
//
//  Created by xuan zhai on 11/27/21.
//

import Foundation
import CoreGraphics


public extension CGFloat{
    
    static func random() -> CGFloat{
        return CGFloat(Float(arc4random()) / Float(0xFFFFFFFF))
    }
    
    static func random(min : CGFloat, max : CGFloat) -> CGFloat{
        return CGFloat.random() * (max - min) + min     // A extened function for generate a number between min and max
    }
}

