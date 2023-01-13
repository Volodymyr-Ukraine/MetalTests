//
//  Shaders.metal
//  Image Editor Demo
//
//  Created by Volodymyr Shynkarenko on 29.12.2022.
//

#include <metal_stdlib>
#include "ColorConversion.h"

using namespace metal;

constant bool deviceSupportsNonuniformThreadgroups [[ function_constant(0) ]];

kernel void adjustments(texture2d<float, access::read> source [[ texture(0) ]],
                        texture2d<float, access::write> destination [[ texture(1) ]],
                        constant float& temperature [[ buffer(0) ]],
                        constant float& tint [[ buffer(1) ]],
                        constant float& brightness [[ buffer(2) ]],
//                        constant bool& bwTransition [[ buffer(3) ]],
                        uint2 position [[thread_position_in_grid]]) {
    const auto textureSize = ushort2(destination.get_width(),
                                     destination.get_height());
    
    if (!deviceSupportsNonuniformThreadgroups) {
        if (position.x >= textureSize.x || position.y >= textureSize.y) {
            return;
        }
    }

    const auto sourceValue = source.read(position);
    auto labValue = rgb2lab(sourceValue.rgb);
//    if (bwTransition) { // bw filter is on
//            const auto resultValue = float4(labValue.xxx, sourceValue.a);
//            destination.write(resultValue, position);
//    } else { // bw filter is off so we use other filters
        labValue = denormalizeLab(labValue);
        
        labValue.b += temperature * 10.0f;
        labValue.g += tint * 10.0f;
        labValue.r += brightness * 1.0f;
        
        labValue = clipLab(labValue);
        labValue = normalizeLab(labValue);
        const auto resultValue = float4(lab2rgb(labValue), sourceValue.a);
        destination.write(resultValue, position);
//    }
}

kernel void addBwFilter(texture2d<float, access::read> source [[ texture(0) ]],
                     texture2d<float, access::write> destination [[ texture(1) ]],
                     uint2 position [[thread_position_in_grid]]) {
    const auto textureSize = ushort2(destination.get_width(),
                                     destination.get_height());
    
    if (!deviceSupportsNonuniformThreadgroups) {
        if (position.x >= textureSize.x || position.y >= textureSize.y) {
            return;
        }
    }
    const auto sourceValue = source.read(position);
    auto labValue = rgb2lab(sourceValue.rgb);
    const auto resultValue = float4(labValue.xxx, sourceValue.a);
    destination.write(resultValue, position);
}
