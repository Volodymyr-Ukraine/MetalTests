//
//  Adjustment.swift
//  Image Editor Demo
//
//  Created by Volodymyr Shynkarenko on 30.12.2022.
//

//import Foundation
import Metal

final class Adjustments: AbstractShader {
    var temperature: Float = .zero
    var tint: Float = .zero
    var brightness: Float = .zero
//    var bwTransition: Bool = false
    
    private var deviceSupportsNonuniformThreadgroups: Bool
    let pipelineState: MTLComputePipelineState
    
    init(library: MTLLibrary) throws {
        self.deviceSupportsNonuniformThreadgroups = library.device.supportsFeatureSet(.iOS_GPUFamily4_v1)
        let constantValues = MTLFunctionConstantValues()
        constantValues.setConstantValue(&self.deviceSupportsNonuniformThreadgroups,
                                        type: .bool,
                                        index: 0)
        let function = try library.makeFunction(name: "adjustments",
                                                constantValues: constantValues)
        self.pipelineState = try library.device.makeComputePipelineState(function: function)
    }
    
    func refresh(_ values: [String: Filter]) {
        temperature = values[Filter.temperature(0).id]?.floatValue ?? .zero
        tint = values[Filter.tint(0).id]?.floatValue ?? .zero
        brightness = values[Filter.brightness(0).id]?.floatValue ?? .zero
    }
    
    func encode(source: MTLTexture,
                destination: MTLTexture,
                in commandBuffer: MTLCommandBuffer) {
        guard let encoder = commandBuffer.makeComputeCommandEncoder()
        else { return }
        encoder.setTexture(source,
                           index: 0)
        encoder.setTexture(destination,
                           index: 1)
        encoder.setBytes(&self.temperature,
                         length: MemoryLayout<Float>.stride,
                         index: 0)
        encoder.setBytes(&self.tint,
                         length: MemoryLayout<Float>.stride,
                         index: 1)
        encoder.setBytes(&self.brightness, length: MemoryLayout<Float>.stride, index: 2)
        self.addDispatchThreads(into: encoder, for: source, self.deviceSupportsNonuniformThreadgroups)
        encoder.endEncoding()
    }
}
