//
//  C7Color2GBRA.metal
//  ATMetalBand
//
//  Created by Condy on 2022/2/15.
//

#include <metal_stdlib>
using namespace metal;

kernel void C7Color2GBRA(texture2d<half, access::write> outputTexture [[texture(0)]],
                         texture2d<half, access::read> inputTexture [[texture(1)]],
                         uint2 grid [[thread_position_in_grid]]) {
    const half4 inColor = inputTexture.read(grid);
    
    const half4 outColor(inColor.gbr, inColor.a);
    
    outputTexture.write(outColor, grid);
}