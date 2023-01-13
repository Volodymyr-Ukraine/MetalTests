//
//  ShaderContext.swift
//  Image Editor Demo
//
//  Created by Volodymyr Shynkarenko on 13.01.2023.
//

//import Foundation
import Metal

final class ShaderContext {
    private var filters: [String: Filter] = [:]
    private let adjustments: Adjustments
    private let bwFilter: BWFilter
    
    
    init(library: MTLLibrary, defaultValues: [Filter]) throws {
        adjustments = try Adjustments(library: library)
        bwFilter = try BWFilter(library: library)
        filters = Dictionary(uniqueKeysWithValues: defaultValues.map{
            ($0.id, $0)
        })
    }
    
    public func add(_ filter: Filter) {
        filters[filter.id] = filter
    }
    
    func encode(source: MTLTexture,
                destination: MTLTexture,
                in commandBuffer: MTLCommandBuffer) {
        adjustments.refresh(filters)
        adjustments.encode(source: source, destination: destination, in: commandBuffer)
        
        bwFilter.refresh(filters)
        bwFilter.encode(source: source,  destination: destination, in: commandBuffer)
    }
}

