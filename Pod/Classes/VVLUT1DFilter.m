//
//  VVLUT1DFilter.m
//  VVLUT1DFilter
//
//  Created by Greg Cotten on 7/4/14.
//  Copyright (c) 2014 Video Village. All rights reserved.
//

#import "VVLUT1DFilter.h"
#import "VVLUT1DFilterKernel.h"

@implementation VVLUT1DFilter{
    CIImage   *inputImage;
    NSData *inputData;
    NSNumber *inputSize;
}

static CIKernel *lut1DKernel = nil;

+ (void)load{
    [self registerFilter];
}

+ (void)registerFilter {
    NSDictionary *attributes = @{ kCIAttributeFilterDisplayName : @"LUT1D",
                                  kCIAttributeFilterCategories : @[kCICategoryVideo, kCICategoryStillImage] };
    [CIFilter registerFilterName:@"VVLUT1DFilter" constructor:(id <CIFilterConstructor>)self classAttributes:attributes];
}

+ (CIFilter *)filterWithName:(NSString *)name {
    return [[self alloc] init];
}

- (id)init
{
    self = [super init];
    
    if (self) {
        
        if (lut1DKernel == nil)
        {
            lut1DKernel = [VVLUT1DFilterKernel kernel];
        }
    }
    
    return self;
}


- (CIImage *)outputImage {
    NSUInteger expectedByteSize = sizeof(float)*4*VVLUT1DFILTER_TEX_MAX_WIDTH*(int)ceil(inputSize.doubleValue/(double)VVLUT1DFILTER_TEX_MAX_WIDTH);

    if (inputData.length != expectedByteSize) {
        NSMutableData *newData = [NSMutableData dataWithData:inputData];
        [newData setLength:expectedByteSize];
        inputData = [NSData dataWithData:newData];
    }
    CIImage *lutImage = [CIImage imageWithBitmapData:inputData
                                         bytesPerRow:sizeof(float)*4*VVLUT1DFILTER_TEX_MAX_WIDTH
                                                size:CGSizeMake(VVLUT1DFILTER_TEX_MAX_WIDTH, (int)ceil(inputSize.doubleValue/(double)VVLUT1DFILTER_TEX_MAX_WIDTH))
                                              format:kCIFormatRGBAf
                                          colorSpace:nil];
    
    CISampler *inputSampler = [CISampler samplerWithImage: inputImage];
    CISampler *lutSampler = [CISampler samplerWithImage: lutImage options:@{kCISamplerFilterMode: kCISamplerFilterNearest,
                                                                            kCISamplerWrapMode: kCISamplerWrapClamp}];
    [lut1DKernel setROISelector:@selector(regionOf:destRect:)];
    
    NSArray * outputExtent = @[@(inputImage.extent.origin.x),
                               @(inputImage.extent.origin.y),
                               @(inputImage.extent.size.width),
                               @(inputImage.extent.size.height)];
    
    return [self apply:lut1DKernel, inputSampler, lutSampler, inputSize, kCIApplyOptionExtent, outputExtent, nil];
}

+ (double)remapValue:(double)value
            inputLow:(double)inputLow
           inputHigh:(double)inputHigh
           outputLow:(double)outputLow
          outputHigh:(double)outputHigh{
    return outputLow + ((value - inputLow)*(outputHigh - outputLow))/(inputHigh - inputLow);
}

+ (NSData *)identityLUTDataOfSize:(int)size{
    size_t dataSize = sizeof(float)*4*size;
    float* lutArray = (float *)malloc(dataSize);
    for (int i = 0; i < size; i++) {
        float identityValue = [self.class remapValue:i
                                            inputLow:0
                                           inputHigh:size-1
                                           outputLow:0.0
                                          outputHigh:1.0];
        lutArray[i*4] = identityValue;
        lutArray[i*4+1] = identityValue;
        lutArray[i*4+2] = identityValue;
        lutArray[i*4+3] = 1.0;
    }
    
    return [NSData dataWithBytesNoCopy:lutArray length:dataSize];
}

- (void)setDefaults{
    inputData = [self.class identityLUTDataOfSize:100];
    inputSize = @100;
}


- (CGRect)regionOf:(int)samplerIndex destRect:(CGRect)r
{
    if (samplerIndex == 0) {
        return r;
    }
    return NSMakeRect(0, 0, VVLUT1DFILTER_TEX_MAX_WIDTH, (int)ceil(inputSize.doubleValue/(double)VVLUT1DFILTER_TEX_MAX_WIDTH));
}

- (NSDictionary *)customAttributes
{
    NSDictionary *sizeDictionary = @{
                                      kCIAttributeType : kCIAttributeTypeInteger
                                      };
    
    NSDictionary *lutDataDictionary = @{
                                      kCIAttributeDefault : [self.class identityLUTDataOfSize:100]
                                      };
    
    return @{
             @"inputSize" : sizeDictionary,
             @"inputData": lutDataDictionary,
             // This is needed because the filter is registered under a different name than the class.
             kCIAttributeFilterName : @"VVLUT1DFilter"
             };
}

@end
