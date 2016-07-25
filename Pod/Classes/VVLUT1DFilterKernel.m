//
//  VVLUT1DFilterKernel.m
//  Pods
//
//  Created by Greg Cotten on 1/12/15.
//
//

#import "VVLUT1DFilterKernel.h"

#define STRINGIZE(x) #x
#define STRINGIZE2(x) STRINGIZE(x)
#define SHADER_STRING(text) @ STRINGIZE2(text)

#if true
#undef ceil
#undef floor

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
                                                           
vec2 indexToLUTCoordinate(float index){
    float x = mod(index,float(VVLUT1DFILTER_TEX_MAX_WIDTH));
    float y =  floor(index/float(VVLUT1DFILTER_TEX_MAX_WIDTH));
    return vec2(x, y);
}

kernel vec4 lut1DKernel(sampler src, __table sampler lut, float lutSize){
    vec4 inputColor = sample(src, samplerCoord(src));
    
    float redPoint = inputColor.r*(lutSize-1.0);
    float greenPoint = inputColor.g*(lutSize-1.0);
    float bluePoint = inputColor.b*(lutSize-1.0);
    
    float redBottomIndex = floor(redPoint);
    float redTopIndex = ceil(redPoint);

    float greenBottomIndex = floor(greenPoint);
    float greenTopIndex = ceil(greenPoint);

    float blueBottomIndex = floor(bluePoint);
    float blueTopIndex = ceil(bluePoint);
    
    float redBottomIndexValue = sample(lut, indexToLUTCoordinate(redBottomIndex)).r;
    
    float redTopIndexValue = sample(lut, indexToLUTCoordinate(redTopIndex)).r;
    
    float interpolatedRedValue = lerp1d(redBottomIndexValue, redTopIndexValue, redPoint - float(redBottomIndex));
    
    float greenBottomIndexValue = sample(lut, indexToLUTCoordinate(greenBottomIndex)).g;
    
    float greenTopIndexValue = sample(lut, indexToLUTCoordinate(greenTopIndex)).g;
    
    float interpolatedGreenValue = lerp1d(greenBottomIndexValue, greenTopIndexValue, greenPoint - float(greenBottomIndex));
    
    
    float blueBottomIndexValue = sample(lut, indexToLUTCoordinate(blueBottomIndex)).b;
    
    float blueTopIndexValue = sample(lut, indexToLUTCoordinate(blueTopIndex)).b;
    
    float interpolatedBlueValue = lerp1d(blueBottomIndexValue, blueTopIndexValue, bluePoint - float(blueBottomIndex));
    

    return vec4(interpolatedRedValue, interpolatedGreenValue, interpolatedBlueValue, inputColor.a);
}


);
#endif

@implementation VVLUT1DFilterKernel

+ (CIKernel *)kernel{
    
    return [CIKernel kernelsWithString:kVVLUT1DFilterKernelString].firstObject;
}

@end


