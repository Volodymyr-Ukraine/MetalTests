//
//  CropShader.swift
//  Image Editor Demo
//
//  Created by Volodymyr Shynkarenko on 06.02.2023.
//

import Metal

final class CropShader: AbstractShader {
    
    private var x0: Float = 0.0
    private var y0: Float = 0.0
    
    private var frame: UintSize = UintSize()
    
    private var deviceSupportsNonuniformThreadgroups: Bool
    let pipelineState: MTLComputePipelineState
    
    init(library: MTLLibrary) throws {
        self.deviceSupportsNonuniformThreadgroups = library.device.supportsFeatureSet(.iOS_GPUFamily4_v1)
        let constantValues = MTLFunctionConstantValues()
        constantValues.setConstantValue(&self.deviceSupportsNonuniformThreadgroups,
                                        type: .bool,
                                        index: 0)
        let function = try library.makeFunction(name: "crop",
                                                constantValues: constantValues)
        self.pipelineState = try library.device.makeComputePipelineState(function: function)
    }
    
    func refresh(_ values: [String: Filter]) {
        x0 = values[Filter.cropX(0.0).id]?.floatValue ?? 0.0
        y0 = values[Filter.cropY(0.0).id]?.floatValue ?? 0.0
    }
    
    func encode(source: MTLTexture,
                destination: MTLTexture,
                in commandBuffer: MTLCommandBuffer) {
        guard x0 < 1.0 || y0 < 1.0 else {
            let encoder = commandBuffer.makeBlitCommandEncoder()
            encoder?.copy(from: source, to: destination)
            encoder?.endEncoding()
            return
        }
        let x0UInt = UInt(x0 * Float(source.width))
        let width = UInt(destination.width)
        let y0UInt = UInt(y0 * Float(source.height))
        let height = UInt(destination.height)
        frame = UintSize(x: x0UInt, y: y0UInt, width: width, height: height)
        
        guard let encoder = commandBuffer.makeComputeCommandEncoder()
        else { return }
        encoder.setTexture(source,
                           index: 0)
        encoder.setTexture(destination,
                           index: 1)
        encoder.setBytes(&self.frame.x,
                         length: MemoryLayout<UInt>.stride,
                         index: 0)
        encoder.setBytes(&self.frame.y, length: MemoryLayout<UInt>.stride, index: 1)
        encoder.setBytes(&self.frame.width, length: MemoryLayout<UInt>.stride, index: 2)
        encoder.setBytes(&self.frame.height, length: MemoryLayout<UInt>.stride, index: 3)
        self.addDispatchThreads(into: encoder, for: source, self.deviceSupportsNonuniformThreadgroups)
        encoder.endEncoding()
    }
}
