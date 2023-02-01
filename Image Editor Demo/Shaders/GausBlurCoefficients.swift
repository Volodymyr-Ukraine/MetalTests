//
//  GausBlurCoefficients.swift
//  Image Editor Demo
//
//  Created by Volodymyr Shynkarenko on 30.01.2023.
//

import Foundation

struct GausBlurCoefficients {
    let sigma: Float
    
    var radius: Int {
        return gausCoefficients.count - 1
    }
    
    var gausCoefficients: [Float] {
        return (0...10).compactMap{ radius in
            let coeficient = exp(-pow(Float(radius), 2) / (2*pow(sigma, 2)))
            return coeficient > 0.003 ? coeficient : nil
        }
    }
    
    var gausNormalizer: Float {
        return (gausCoefficients + gausCoefficients.dropFirst()).reduce(0.0, +)
    }

    
}
