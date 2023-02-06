//
//  UintSize.swift
//  Image Editor Demo
//
//  Created by Volodymyr Shynkarenko on 06.02.2023.
//

import Foundation

public struct UintSize {
    var x: UInt
    var y: UInt
    
    var width: UInt
    var height: UInt
    
    init(x: UInt, y: UInt, width: UInt, height: UInt) {
        self.x = x
        self.y = y
        self.width = width
        self.height = height
    }
    
    init() {
        self.init(x: 0, y: 0, width: 0, height: 0)
    }
}
