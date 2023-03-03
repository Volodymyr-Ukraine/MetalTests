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
    private let cropShader: CropShader
    
    private var blures: [AbstractShader] {
        [
            horizontalBlur,
            verticalBlur
        ]
    }
    
    private let device: MTLDevice
    var lineShaders: [AbstractShader] {
        [
//            adjustments,
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
        cropShader = try CropShader(library: library)
        
        self.device = device
        filters = Dictionary(uniqueKeysWithValues: defaultValues.map{
            ($0.id, $0)
        })
        
    }
    
    public func add(_ filter: Filter) {
        filters[filter.id] = filter
    }
    
    public func readFloat(_ filter: Filter) -> Float? {
        return filters[filter.id]?.floatValue
    }
    
    public func encode(source: MTLTexture,
                destination: MTLTexture,
                in commandBuffer: MTLCommandBuffer,
                helper textureManager: TextureManager,
                completion: @escaping MTLCommandBufferHandler
    ) {
        (lineShaders + blures + [cropShader, adjustments]).forEach{
            $0.refresh(filters)
        }
        triggerProgrammaticCapture()
        cropShader.encode(source: source, destination: destination, in: commandBuffer)
        
        guard let tempDestination = try? textureManager.matchingTexture(to: destination),
              let tempDestination2 = try? textureManager.matchingTexture(to: destination) else { return }
        
        horizontalBlur.encode(source: destination, destination: tempDestination2, in: commandBuffer)
//        verticalBlur.encode(source: tempDestination, destination: tempDestination2, in: commandBuffer)
        
        adjustments.encode(source: tempDestination2, destination: destination, in: commandBuffer)
        lineShaders.forEach{
            $0.encode(source: destination, destination: destination, in: commandBuffer)
        }
        
        commandBuffer.addCompletedHandler(completion)
        commandBuffer.commit()
        runMetalCommands()
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
    
    private func makeTextureBased(on texture: MTLTexture, width: Int? = nil, height: Int? = nil) -> MTLTexture {
        let matchingDescriptor = MTLTextureDescriptor()
        matchingDescriptor.width = width ?? texture.width
        matchingDescriptor.height = height ?? texture.height
        matchingDescriptor.usage = texture.usage
        matchingDescriptor.pixelFormat = texture.pixelFormat
        matchingDescriptor.storageMode = texture.storageMode

        guard let matchingTexture = device.makeTexture(descriptor: matchingDescriptor)
        else { fatalError("wrong texture") }

        return matchingTexture
    }
    
    private func runMetalCommands() {
        let captureManager = MTLCaptureManager.shared()
        captureManager.stopCapture()
    }
    
    private func triggerProgrammaticCapture() {
        let captureManager = MTLCaptureManager.shared()
            let captureDescriptor = MTLCaptureDescriptor()
            captureDescriptor.captureObject = self.device
            do {
                try captureManager.startCapture(with: captureDescriptor)
            }
            catch
            {
                fatalError("error when trying to capture: \(error)")
            }
    }
}

