//
//  Blur.metal
//  Image Editor Demo
//
//  Created by Volodymyr Shynkarenko on 25.01.2023.
//

#include <metal_stdlib>
#include "MatrixConvertion.h"

using namespace metal;

constant bool deviceSupportsNonuniformThreadgroups [[ function_constant(0) ]];

//constant float deviceSupportsNonuniformThreadgroups [[ function_constant(1) ]];

kernel void horisontalBlur(texture2d<float, access::read> source [[ texture(0) ]],
                 texture2d<float, access::write> destination [[ texture(1) ]],
                 constant float *gausCoeficient [[buffer(0)]],
                 constant int& length [[ buffer(1) ]],
                 constant float& gausNormalizer [[ buffer(2) ]],
//                 constant bool& horisontal [[ buffer(3) ]],
                 uint2 position [[thread_position_in_grid]]) {
    const auto textureSize = ushort2(destination.get_width(),
                                     destination.get_height());
    if (!deviceSupportsNonuniformThreadgroups) {
        if (position.x >= textureSize.x || position.y >= textureSize.y) {
            return;
        }
    }
    
//    const auto sourceValue = source.read(position);
    auto totalPixel = float3(0.0f, 0.0f, 0.0f);
    for (int i = -length; length; i++) {
        const auto coord = position.x + i;
        const auto coef = gausCoeficient[abs(i)];
        if (coord <= 0) {
            totalPixel = addPixels(
                                   modify(
                                          source.read(uint2(0, position.y)).xyz, coef, gausNormalizer),
                                   totalPixel
                                   );
        } else if (coord >= textureSize.x) {
            totalPixel = addPixels(
                                   modify(
                                          source.read(uint2(textureSize.x - 1, position.y)).xyz, coef, gausNormalizer),
                                   totalPixel
                                   );
        } else {
            totalPixel = addPixels(
                                   modify(
                                          source.read(uint2(coord, position.y)).xyz, coef, gausNormalizer),
                                   totalPixel
                                   );
        }
    }
    const auto resultValue = float4(totalPixel.rgb, source.read(position).a);
    destination.write(resultValue, position);
}


kernel void verticalBlur(texture2d<float, access::read> source [[ texture(0) ]],
                 texture2d<float, access::write> destination [[ texture(1) ]],
                 constant float *gausCoeficient [[buffer(0)]],
                 constant int& length [[ buffer(1) ]],
                 constant float& gausNormalizer [[ buffer(2) ]],
                 uint2 position [[thread_position_in_grid]]) {
    const auto textureSize = ushort2(destination.get_width(),
                                     destination.get_height());
    if (!deviceSupportsNonuniformThreadgroups) {
        if (position.x >= textureSize.x || position.y >= textureSize.y) {
            return;
        }
    }
    
    auto totalPixel = float3(0.0f, 0.0f, 0.0f);
    for (int i = -length; length; i++) {
        const auto coord = position.y + i;
        const auto coef = gausCoeficient[abs(i)];
        if (coord <= 0) {
            totalPixel = addPixels(
                                   modify(
                                          source.read(uint2(position.x, 0)).xyz, coef, gausNormalizer),
                                   totalPixel
                                   );
        } else if (coord >= textureSize.y) {
            totalPixel = addPixels(
                                   modify(
                                          source.read(uint2(position.x, textureSize.y - 1)).xyz, coef, gausNormalizer),
                                   totalPixel
                                   );
        } else {
            totalPixel = addPixels(
                                   modify(
                                          source.read(uint2(position.x, coord)).xyz, coef, gausNormalizer),
                                   totalPixel
                                   );
        }
    }
    const auto resultValue = float4(totalPixel.rgb, source.read(position).a);
    destination.write(resultValue, position);
}
