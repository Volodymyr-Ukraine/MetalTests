//
//  Contrast.swift
//  Image Editor Demo
//
//  Created by Volodymyr Shynkarenko on 13.01.2023.
//

import Metal

final class Contrast: AbstractShader {
    private var contrast: Float = .zero
    
    private var deviceSupportsNonuniformThreadgroups: Bool
    let pipelineState: MTLComputePipelineState
    
    init(library: MTLLibrary) throws {
        self.deviceSupportsNonuniformThreadgroups = library.device.supportsFeatureSet(.iOS_GPUFamily4_v1)
        let constantValues = MTLFunctionConstantValues()
        constantValues.setConstantValue(&self.deviceSupportsNonuniformThreadgroups,
                                        type: .bool,
                                        index: 0)
        let function = try library.makeFunction(name: "adjustContrast",
                                                constantValues: constantValues)
        self.pipelineState = try library.device.makeComputePipelineState(function: function)
    }
    
    func refresh(_ values: [String: Filter]) {
        contrast = values[Filter.contrast(0.0).id]?.floatValue ?? 0.0
    }
    
    func encode(source: MTLTexture,
                destination: MTLTexture,
                in commandBuffer: MTLCommandBuffer) {
        guard (contrast != 0.0) else {
            let encoder = commandBuffer.makeBlitCommandEncoder()
            encoder?.copy(from: source, to: destination)
            encoder?.endEncoding()
            return
        }
        
        guard let encoder = commandBuffer.makeComputeCommandEncoder()
        else { return }
        encoder.setTexture(source,
                           index: 0)
        encoder.setTexture(destination,
                           index: 1)
        encoder.setBytes(&self.contrast,
                         length: MemoryLayout<Float>.stride,
                         index: 0)
        self.addDispatchThreads(into: encoder, for: source, self.deviceSupportsNonuniformThreadgroups)
        encoder.endEncoding()
    }
}
