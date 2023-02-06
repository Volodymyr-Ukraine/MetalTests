//
//  AbstractShader.swift
//  Image Editor Demo
//
//  Created by Volodymyr Shynkarenko on 24.01.2023.
//

import Metal
import UIKit

protocol AbstractShader {
    
    var pipelineState: MTLComputePipelineState { get }
    
    init(library: MTLLibrary) throws
    
    func refresh(_: [String: Filter])
    
    func encode(source: MTLTexture,
                destination: MTLTexture,
                in: MTLCommandBuffer)
}

extension AbstractShader {
    public func addDispatchThreads(into encoder: MTLComputeCommandEncoder, for source: MTLTexture, _ deviceSupportsNonuniformThreadgroups: Bool, pipeline: MTLComputePipelineState? = nil) {
        let pipelineState = pipeline ?? self.pipelineState
        let gridSize = MTLSize(width: source.width,
                               height: source.height,
                               depth: 1)
        let threadGroupSize = getThreadGroupSize()
        encoder.setComputePipelineState(pipelineState)
        if deviceSupportsNonuniformThreadgroups {
            encoder.dispatchThreads(gridSize,
                                    threadsPerThreadgroup: threadGroupSize)
        } else {
            let threadGroupCount = MTLSize(width: (gridSize.width + threadGroupSize.width - 1) / threadGroupSize.width,
                                           height: (gridSize.height + threadGroupSize.height - 1) / threadGroupSize.height,
                                           depth: 1)
            encoder.dispatchThreadgroups(threadGroupCount,
                                         threadsPerThreadgroup: threadGroupSize)
        }
    }
    
    private func getThreadGroupSize(pipeline: MTLComputePipelineState? = nil) -> MTLSize {
        var pipelineState = pipeline ?? self.pipelineState
        let threadGroupWidth = pipelineState.threadExecutionWidth
        let threadGroupHeight = pipelineState.maxTotalThreadsPerThreadgroup / threadGroupWidth
        return MTLSize(width: threadGroupWidth,
                                      height: threadGroupHeight,
                                      depth: 1)
    }
}
