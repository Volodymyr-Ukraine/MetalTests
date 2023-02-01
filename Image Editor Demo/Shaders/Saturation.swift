//
//  Saturation.swift
//  Image Editor Demo
//
//  Created by Volodymyr Shynkarenko on 19.01.2023.
//

import Metal

final class Saturation: AbstractShader {
    private var saturation: Float = .zero
    
    private var deviceSupportsNonuniformThreadgroups: Bool
    let pipelineState: MTLComputePipelineState
    
    init(library: MTLLibrary) throws {
        self.deviceSupportsNonuniformThreadgroups = library.device.supportsFeatureSet(.iOS_GPUFamily4_v1)
        let constantValues = MTLFunctionConstantValues()
        constantValues.setConstantValue(&self.deviceSupportsNonuniformThreadgroups,
                                        type: .bool,
                                        index: 0)
        let function = try library.makeFunction(name: "adjustHsl",
                                                constantValues: constantValues)
        self.pipelineState = try library.device.makeComputePipelineState(function: function)
    }
    
    func refresh(_ values: [String: Filter]) {
        saturation = values[Filter.saturation(0.0).id]?.floatValue ?? 0.0
    }
    
    func encode(source: MTLTexture,
                destination: MTLTexture,
                in commandBuffer: MTLCommandBuffer) {
        guard (saturation != 0.0) else {
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
        encoder.setBytes(&self.saturation,
                         length: MemoryLayout<Float>.stride,
                         index: 0)
        self.addDispatchThreads(into: encoder, for: source, self.deviceSupportsNonuniformThreadgroups)
        encoder.endEncoding()
    }
}
