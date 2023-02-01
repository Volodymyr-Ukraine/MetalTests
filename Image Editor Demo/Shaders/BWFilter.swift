//
//  BWFilter.swift
//  Image Editor Demo
//
//  Created by Volodymyr Shynkarenko on 13.01.2023.
//

import Metal

final class BWFilter: AbstractShader {
    private var bwTransition: Bool = false
    
    private var deviceSupportsNonuniformThreadgroups: Bool
    let pipelineState: MTLComputePipelineState
    
    init(library: MTLLibrary) throws {
        self.deviceSupportsNonuniformThreadgroups = library.device.supportsFeatureSet(.iOS_GPUFamily4_v1)
        let constantValues = MTLFunctionConstantValues()
        constantValues.setConstantValue(&self.deviceSupportsNonuniformThreadgroups,
                                        type: .bool,
                                        index: 0)
        let function = try library.makeFunction(name: "addBwFilter",
                                                constantValues: constantValues)
        self.pipelineState = try library.device.makeComputePipelineState(function: function)
    }
    
    func refresh(_ values: [String: Filter]) {
        bwTransition = (values[Filter.bw(false).id]?.value as? Bool) ?? false
    }
    
    func encode(source: MTLTexture,
                destination: MTLTexture,
                in commandBuffer: MTLCommandBuffer) {
        guard bwTransition else {
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
        self.addDispatchThreads(into: encoder, for: source, self.deviceSupportsNonuniformThreadgroups)
        encoder.endEncoding()
    }
}

