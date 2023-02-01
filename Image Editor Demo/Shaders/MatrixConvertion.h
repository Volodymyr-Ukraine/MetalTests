//
//  MatrixConvertion.h
//  Image Editor Demo
//
//  Created by Volodymyr Shynkarenko on 19.01.2023.
//

#ifndef MatrixConvertion_h
#define MatrixConvertion_h

#if __METAL_MACOS__ || __METAL_IOS__
#include <metal_stdlib>
using namespace metal;
#endif /* __METAL_MACOS__ || __METAL_IOS__ */

#import <simd/simd.h>

// MARK: - LAB & RGB

//template <typename T>
//enable_if_t<is_floating_point_v<T>, vec<T, 3>>
//METAL_FUNC matrixConversion(vec<T, 3> *pixels, vec<T, 3> *coeficients, T normalizer) {
//
//
//    float3 n = float3(c) / float3(95.047f, 100.0f, 108.883f);
//    float3 v;
//    v.x = (n.x > 0.008856f)
//        ? pow(n.x, 1.0f / 3.0f)
//        : (7.787f * n.x ) + ( 16.0f / 116.0f);
//    v.y = (n.y > 0.008856f)
//        ? pow(n.y, 1.0f / 3.0f)
//        : (7.787f * n.y ) + ( 16.0f / 116.0f);
//    v.z = (n.z > 0.008856f)
//        ? pow(n.z, 1.0f / 3.0f)
//        : (7.787f * n.z ) + ( 16.0f / 116.0f);
//    return vec<T, 3>((116.0f * v.y) - 16.0f, 500.0f * (v.x - v.y), 200.0f * (v.y - v.z));
//}
template <typename T>
enable_if_t<is_floating_point_v<T>, vec<T, 3>>
METAL_FUNC multiplyPixels(vec<T, 3> a, vec<T, 3> b, T normalizer) {
    return vec<T, 3>(a.x*b.x / normalizer, a.y*b.y / normalizer, a.z*b.z / normalizer);
}

template <typename T>
enable_if_t<is_floating_point_v<T>, vec<T, 3>>
METAL_FUNC modify(vec<T, 3> a, T b, T normalizer) {
    return vec<T, 3>(a.x*b / normalizer, a.y*b / normalizer, a.z*b / normalizer);
}

template <typename T>
enable_if_t<is_floating_point_v<T>, vec<T, 3>>
METAL_FUNC addPixels(vec<T, 3> a, vec<T, 3> b) {
    return vec<T, 3>(a.x+b.x, a.y+b.y, a.z+b.z);
}

#endif /* MatrixConvertion_h */
