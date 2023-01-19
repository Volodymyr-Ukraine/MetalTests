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
    private let contrast: Contrast
    private let saturation: Saturation
    
    private let device: MTLDevice
    
    
    init(library: MTLLibrary, device: MTLDevice, defaultValues: [Filter]) throws {
        adjustments = try Adjustments(library: library)
        bwFilter = try BWFilter(library: library)
        contrast = try Contrast(library: library)
        saturation = try Saturation(library: library)
        
        self.device = device
        filters = Dictionary(uniqueKeysWithValues: defaultValues.map{
            ($0.id, $0)
        })
    }
    
    public func add(_ filter: Filter) {
        filters[filter.id] = filter
    }
    
    public func encode(source: MTLTexture,
                destination: MTLTexture,
                in commandBuffer: MTLCommandBuffer) {
        adjustments.refresh(filters)
        let temporary1Source = cloneTexture(source)
        adjustments.encode(source: source, destination: temporary1Source, in: commandBuffer)
        
        let temporary2Source = cloneTexture(source)
        contrast.refresh(filters)
        contrast.encode(source: temporary1Source, destination: temporary2Source, in: commandBuffer)
        
        let temporary3Source = cloneTexture(source)
        saturation.refresh(filters)
        saturation.encode(source: temporary2Source, destination: temporary3Source, in: commandBuffer)
        
        bwFilter.refresh(filters)
        bwFilter.encode(source: temporary3Source,  destination: destination, in: commandBuffer)
        
        
    }
    
    private func cloneTexture(_ texture: MTLTexture) -> MTLTexture {
        let matchingDescriptor = MTLTextureDescriptor()
        matchingDescriptor.width = texture.width
        matchingDescriptor.height = texture.height
        matchingDescriptor.usage = texture.usage
        matchingDescriptor.pixelFormat = texture.pixelFormat
        matchingDescriptor.storageMode = texture.storageMode

        guard let matchingTexture = device.makeTexture(descriptor: matchingDescriptor)
        else { fatalError("wrong texture") }

        return matchingTexture
    }
}

