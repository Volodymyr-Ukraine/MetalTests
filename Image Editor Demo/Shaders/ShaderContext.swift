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
    private let horizontalBlur: HorizontalBlur
    private let verticalBlur: VerticalBlur
    
    private var blures: [AbstractShader] {
        [
            horizontalBlur,
            verticalBlur
        ]
    }
    
    private let device: MTLDevice
    var lineShaders: [AbstractShader] {
        [
            adjustments,
            bwFilter,
            contrast,
            saturation
        ]
    }
    
    init(library: MTLLibrary, device: MTLDevice, defaultValues: [Filter]) throws {
        adjustments = try Adjustments(library: library)
        bwFilter = try BWFilter(library: library)
        contrast = try Contrast(library: library)
        saturation = try Saturation(library: library)
        horizontalBlur = try HorizontalBlur(library: library)
        verticalBlur = try VerticalBlur(library: library)
        
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
                temporaryDestination: MTLTexture,
                in commandBuffer: MTLCommandBuffer) {
        (lineShaders + blures).forEach{
            $0.refresh(filters)
        }
        horizontalBlur.encode(source: source, destination: temporaryDestination, in: commandBuffer)
        verticalBlur.encode(source: temporaryDestination, destination: destination, in: commandBuffer)
        lineShaders.forEach{
            $0.encode(source: destination, destination: destination, in: commandBuffer)
        }
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

