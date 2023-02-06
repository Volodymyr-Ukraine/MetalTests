//
//  Crop.metal
//  Image Editor Demo
//
//  Created by Volodymyr Shynkarenko on 03.02.2023.
//

#include <metal_stdlib>
using namespace metal;

constant bool deviceSupportsNonuniformThreadgroups [[ function_constant(0) ]];

kernel void crop(texture2d<float, access::read> source [[ texture(0) ]],
                 texture2d<float, access::write> destination [[ texture(1) ]],
                 constant uint& x0 [[buffer(0)]],
                 constant uint& y0 [[ buffer(1) ]],
                 constant uint& width [[buffer(2)]],
                 constant uint& height [[ buffer(3) ]],
                           uint2 position [[thread_position_in_grid]]) {
    const auto textureSize = ushort2(destination.get_width(),
                                     destination.get_height());
    if (!deviceSupportsNonuniformThreadgroups) {
        if (position.x >= textureSize.x || position.y >= textureSize.y) {
            return;
        }
    }
    
    if (((position.x - x0) < 0) || (position.x >= (x0 + textureSize.x)) ||
        ((position.y - y0) < 0) || (position.y >= (y0 + textureSize.y))) {
            return;
        }
    
    const auto resultValue = source.read(uint2(position.x+x0, position.y+y0));
    destination.write(resultValue, position);
}

