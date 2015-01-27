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
    return beginning + (value01 * (end - beginning));
}
                                                           
//vec3 lerp1d(vec3 beginning, vec3 end, float value01){
//    return vec3(lerp1d(beginning.r, end.r, value01), lerp1d(beginning.g, end.g, value01), lerp1d(beginning.b, end.b, value01));
//}
                                                           
vec2 indexToLUTCoordinate(int index){
    int x = int(mod(float(index),float(VVLUT1DFILTER_TEX_MAX_WIDTH)));
    int y = index/VVLUT1DFILTER_TEX_MAX_WIDTH;
    return vec2(x, y);
}
                                                           
float redValueAtLUTIndex(int index, __table sampler lut){
    return sample(lut, indexToLUTCoordinate(index)).r;
}
                                                           
float greenValueAtLUTIndex(int index, __table sampler lut){
   return sample(lut, indexToLUTCoordinate(index)).g;
}

float blueValueAtLUTIndex(int index, __table sampler lut){
    return sample(lut, indexToLUTCoordinate(index)).b;
}

kernel vec4 lut1DKernel(sampler src, __table sampler lut, float lutSize){
    vec4 inputColor = sample(src, samplerCoord(src));
    
    float redPoint = inputColor.r*(lutSize-1.0);
    float greenPoint = inputColor.g*(lutSize-1.0);
    float bluePoint = inputColor.b*(lutSize-1.0);
    
    int redBottomIndex = int(redPoint);
    int redTopIndex = int(ceil(redPoint));

    int greenBottomIndex = int(greenPoint);
    int greenTopIndex = int(ceil(greenPoint));

    int blueBottomIndex = int(bluePoint);
    int blueTopIndex = int(ceil(bluePoint));
    
    float interpolatedRedValue = lerp1d(redValueAtLUTIndex(redBottomIndex, lut), redValueAtLUTIndex(redTopIndex, lut), redPoint - float(redBottomIndex));
    float interpolatedGreenValue = lerp1d(greenValueAtLUTIndex(greenBottomIndex, lut), greenValueAtLUTIndex(greenTopIndex, lut), greenPoint - float(greenBottomIndex));
    float interpolatedBlueValue = lerp1d(blueValueAtLUTIndex(blueBottomIndex, lut), blueValueAtLUTIndex(blueTopIndex, lut), bluePoint - float(blueBottomIndex));
    

    return vec4(interpolatedRedValue, interpolatedGreenValue, interpolatedBlueValue, inputColor.a);
}


);

@implementation VVLUT1DFilterKernel

+ (CIKernel *)kernel{
    
    return [CIKernel kernelsWithString:kVVLUT1DFilterKernelString].firstObject;
}

@end