//
//  VerticalBlur.swift
//  Image Editor Demo
//
//  Created by Volodymyr Shynkarenko on 30.01.2023.
//

import Metal

final class VerticalBlur: AbstractShader {
    
    private var sigma: Float = 0.0
    
    private var gausCoefficients: [Float] = []
    private var radius: Int = 0
    private var gausNormalizer: Float = 0.0
    
    private var deviceSupportsNonuniformThreadgroups: Bool
    let pipelineState: MTLComputePipelineState
    
    let device: MTLDevice
    
    init(library: MTLLibrary) throws {
        self.deviceSupportsNonuniformThreadgroups = library.device.supportsFeatureSet(.iOS_GPUFamily4_v1)
        self.device = library.device
        let constantValues = MTLFunctionConstantValues()
        constantValues.setConstantValue(&self.deviceSupportsNonuniformThreadgroups,
                                        type: .bool,
                                        index: 0)
        let function = try library.makeFunction(name: "verticalBlur",
                                                constantValues: constantValues)
        self.pipelineState = try library.device.makeComputePipelineState(function: function)
    }
    
    func refresh(_ values: [String: Filter]) {
        sigma = values[Filter.blur(0.0).id]?.floatValue ?? 0.0
    }
    
    func encode(source: MTLTexture,
                destination: MTLTexture,
                in commandBuffer: MTLCommandBuffer) {
        guard sigma > 0.5 else {
            let encoder = commandBuffer.makeBlitCommandEncoder()
            encoder?.copy(from: source, to: destination)
            encoder?.endEncoding()
            return
        }
        guard let encoder = commandBuffer.makeComputeCommandEncoder()
        else { return }
        let blur = GausBlurCoefficients(sigma: sigma)
        self.gausCoefficients = blur.gausCoefficients
        self.radius = blur.radius
        self.gausNormalizer = blur.gausNormalizer
        print("V-Sigma: \(self.sigma)")
        print("coefs: \(self.gausCoefficients), r: \(radius), normalizer: \(gausNormalizer)")
        encoder.setTexture(source,
                           index: 0)
        encoder.setTexture(destination,
                           index: 1)
        encoder.setBytes(&self.gausCoefficients,
                         length: MemoryLayout<Float>.stride * self.gausCoefficients.count,
                         index: 0)
        encoder.setBytes(&self.radius,
                         length: MemoryLayout<Int>.stride,
                         index: 1)
        encoder.setBytes(&self.gausNormalizer,
                         length: MemoryLayout<Float>.stride,
                         index: 2)
        self.addDispatchThreads(into: encoder, for: source, self.deviceSupportsNonuniformThreadgroups)
        encoder.endEncoding()
    }
}


