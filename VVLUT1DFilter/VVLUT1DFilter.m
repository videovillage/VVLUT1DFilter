//
//  VVLUT1DFilter.m
//  VVLUT1DFilter
//
//  Created by Greg Cotten on 7/4/14.
//  Copyright (c) 2014 Video Village. All rights reserved.
//

#import "VVLUT1DFilter.h"
#import "VVLUT1DFilterMathHelper.h"

@interface VVLUT1DFilter ()

@end

@implementation VVLUT1DFilter{
    CIImage   *inputImage;
    NSData *inputData;
    NSNumber *inputSize;
}

static CIKernel *lut1DKernel = nil;

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
            // Load the haze removal kernel.
            NSBundle *bundle = [NSBundle bundleForClass: [self class]];
            NSURL *kernelURL = [bundle URLForResource:@"VVLUT1DKernel" withExtension:@"cikernel"];
            
            NSError *error;
            NSString *kernelCode = [NSString stringWithContentsOfURL:kernelURL encoding:NSUTF8StringEncoding error:&error];
            if (kernelCode == nil) {
                NSLog(@"Error loading kernel code string in %@\n%@", NSStringFromSelector(_cmd), [error localizedDescription]);
                abort();
            }
            
            NSArray *kernels = [CIKernel kernelsWithString:kernelCode];
            lut1DKernel = [kernels objectAtIndex:0];
        }
    }
    
    return self;
}


- (CIImage *)outputImage {
    CIImage *lutImage = [CIImage imageWithBitmapData:inputData
                                         bytesPerRow:sizeof(float)*4*inputSize.integerValue
                                                size:CGSizeMake(inputSize.integerValue, 1)
                                              format:kCIFormatRGBAf
                                          colorSpace:nil];
    
    CISampler *inputSampler = [CISampler samplerWithImage: inputImage];
    CISampler *lutSampler = [CISampler samplerWithImage: lutImage options:@{kCISamplerFilterMode: kCISamplerFilterLinear,
                                                                            kCISamplerWrapMode: kCISamplerWrapClamp}];
    [lut1DKernel setROISelector:@selector(regionOf:destRect:)];
    return [self apply:lut1DKernel, inputSampler, lutSampler, nil];
}

+ (NSData *)identityLUTDataOfSize:(int)size{
    size_t dataSize = sizeof(float)*4*size;
    float* lutArray = (float *)malloc(dataSize);
    for (int i = 0; i < size; i++) {
        float identityValue = remap(i, 0, size-1, 0, 1);
        lutArray[i*4] = identityValue;
        lutArray[i*4+1] = identityValue;
        lutArray[i*4+2] = identityValue;
        lutArray[i*4+3] = 1.0;
    }
    
    return [NSData dataWithBytes:lutArray length:dataSize];
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
    return NSMakeRect(0, 0, inputSize.integerValue, 1);
}

- (NSDictionary *)customAttributes
{
    NSDictionary *sizeDictionary = @{
                                      kCIAttributeMin : @100,
                                      kCIAttributeMax : @1024,
                                      kCIAttributeDefault : @100,
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
