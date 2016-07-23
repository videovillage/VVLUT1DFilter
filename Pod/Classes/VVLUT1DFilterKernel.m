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
    int y = int(index)/int(VVLUT1DFILTER_TEX_MAX_WIDTH);
    return vec2(x, y);
}
                                                           
float redValueAtLUTIndex(int index, sampler lut){
    return sample(lut, indexToLUTCoordinate(index)).r;
}
                                                           
float greenValueAtLUTIndex(int index, sampler lut){
   return sample(lut, indexToLUTCoordinate(index)).g;
}

float blueValueAtLUTIndex(int index, sampler lut){
    return sample(lut, indexToLUTCoordinate(index)).b;
}

kernel vec4 lut1DKernel(sampler src, sampler lut, float lutSize){
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
    
    int x = 0;
    int y = 0;
    vec2 coordinate = vec2(0,0);
    
    x = int(mod(float(redBottomIndex),float(VVLUT1DFILTER_TEX_MAX_WIDTH)));
    y = int(redBottomIndex)/int(VVLUT1DFILTER_TEX_MAX_WIDTH);
    coordinate = vec2(x, y);
    
    float redBottomIndexValue = sample(lut, coordinate).r;
    
    x = int(mod(float(redTopIndex),float(VVLUT1DFILTER_TEX_MAX_WIDTH)));
    y = int(redTopIndex)/int(VVLUT1DFILTER_TEX_MAX_WIDTH);
    coordinate = vec2(x, y);
    
    float redTopIndexValue = sample(lut, coordinate).r;
    
    float interpolatedRedValue = lerp1d(redBottomIndexValue, redTopIndexValue, redPoint - float(redBottomIndex));
    
    x = int(mod(float(greenBottomIndex),float(VVLUT1DFILTER_TEX_MAX_WIDTH)));
    y = int(greenBottomIndex)/int(VVLUT1DFILTER_TEX_MAX_WIDTH);
    coordinate = vec2(x, y);
    
    float greenBottomIndexValue = sample(lut, coordinate).r;
    
    x = int(mod(float(greenTopIndex),float(VVLUT1DFILTER_TEX_MAX_WIDTH)));
    y = int(greenTopIndex)/int(VVLUT1DFILTER_TEX_MAX_WIDTH);
    coordinate = vec2(x, y);
    
    float greenTopIndexValue = sample(lut, coordinate).r;
    
    float interpolatedGreenValue = lerp1d(greenBottomIndexValue, greenTopIndexValue, greenPoint - float(greenBottomIndex));
    
    
    x = int(mod(float(blueBottomIndex),float(VVLUT1DFILTER_TEX_MAX_WIDTH)));
    y = int(blueBottomIndex)/int(VVLUT1DFILTER_TEX_MAX_WIDTH);
    coordinate = vec2(x, y);
    
    float blueBottomIndexValue = sample(lut, coordinate).r;
    
    x = int(mod(float(blueTopIndex),float(VVLUT1DFILTER_TEX_MAX_WIDTH)));
    y = int(blueTopIndex)/int(VVLUT1DFILTER_TEX_MAX_WIDTH);
    coordinate = vec2(x, y);
    
    float blueTopIndexValue = sample(lut, coordinate).r;
    
    float interpolatedBlueValue = lerp1d(blueBottomIndexValue, blueTopIndexValue, bluePoint - float(blueBottomIndex));
    
    
//    float interpolatedRedValue = lerp1d(redValueAtLUTIndex(redBottomIndex, lut), redValueAtLUTIndex(redTopIndex, lut), redPoint - float(redBottomIndex));
//    float interpolatedGreenValue = lerp1d(greenValueAtLUTIndex(greenBottomIndex, lut), greenValueAtLUTIndex(greenTopIndex, lut), greenPoint - float(greenBottomIndex));
//    float interpolatedBlueValue = lerp1d(blueValueAtLUTIndex(blueBottomIndex, lut), blueValueAtLUTIndex(blueTopIndex, lut), bluePoint - float(blueBottomIndex));
    

    return vec4(interpolatedRedValue, interpolatedGreenValue, interpolatedBlueValue, inputColor.a);
}


);

@implementation VVLUT1DFilterKernel

+ (CIKernel *)kernel{
    
    return [CIKernel kernelsWithString:kVVLUT1DFilterKernelString].firstObject;
}

@end
