//
//  VVLUT1DFilterKernel.m
//  Pods
//
//  Created by Greg Cotten on 1/12/15.
//
//

#import "VVLUT1DFilterKernel.h"

NSString *const kVVLUT1DFilterKernelString = SHADER_STRING(
float remapFloat(float value, float inputLow, float inputHigh, float outputLow, float outputHigh){
    return outputLow + ((value - inputLow)*(outputHigh - outputLow))/(inputHigh - inputLow);
}

float lerp1d(float beginning, float end, float value01) {
    float range = end - beginning;
    return beginning + range * value01;
}

kernel vec4 lut1DKernel(sampler src, __table sampler lut){
    vec4 inputColor = sample(src, samplerCoord(src));

    float lutSize = samplerSize(lut).x;

    float redRemappedToIndex = remapFloat(inputColor.r, 0.0, 1.0, 0.0, lutSize-1.0);
    float greenRemappedToIndex = remapFloat(inputColor.g, 0.0, 1.0, 0.0, lutSize-1.0);
    float blueRemappedToIndex = remapFloat(inputColor.b, 0.0, 1.0, 0.0, lutSize-1.0);
    //    float alphaRemappedToIndex = remapFloat(inputColor.a, 0.0, 1.0, 0.0, lutSize-1.0);

    float interpRed = sample(lut, vec2(redRemappedToIndex, 0)).r;
    float interpGreen = sample(lut, vec2(greenRemappedToIndex, 0)).g;
    float interpBlue = sample(lut, vec2(blueRemappedToIndex, 0)).b;
    //   float interpAlpha = sample(lut, vec2(alphaRemappedToIndex, 0)).a;

    return vec4(interpRed, interpGreen, interpBlue, 1.0);
}


);

@implementation VVLUT1DFilterKernel

+ (NSString *)kernelString{
    return kVVLUT1DFilterKernelString;
}

@end