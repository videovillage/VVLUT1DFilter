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
    NSData *lutData;
    NSNumber *lutSize;
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
    [self setDefaults];
    CIImage *lutImage = [CIImage imageWithBitmapData:lutData
                                         bytesPerRow:sizeof(float)*4*lutSize.integerValue
                                                size:CGSizeMake(lutSize.integerValue, 1)
                                              format:kCIFormatRGBAf
                                          colorSpace:CGColorSpaceCreateDeviceRGB()];
    
    CISampler *inputSampler = [CISampler samplerWithImage: inputImage];
    CISampler *lutSampler = [CISampler samplerWithImage: lutImage];

    return [self apply:lut1DKernel, inputSampler, lutSampler, nil];
}

+ (NSData *)identityLUTDataOfSize:(int)size{
    size_t dataSize = sizeof(float)*4*size;
    float* lutArray = (float *)malloc(dataSize);
    for (int i = 0; i < size/4; i++) {
        float identityValue = remap(i, 0, (double)size/4.0, 0, 1);
        lutArray[i*4] = identityValue;
        lutArray[i*4+1] = identityValue;
        lutArray[i*4+2] = identityValue;
        lutArray[i*4+3] = 1.0;
    }
    
    return [NSData dataWithBytesNoCopy:lutArray length:dataSize freeWhenDone:YES];
}

- (void)setDefaults{
    [super setDefaults];
    lutData = [self.class identityLUTDataOfSize:10];
    lutSize = @10;
}

- (NSDictionary *)customAttributes
{

    
    
    NSDictionary *sizeDictionary = @{
                                      kCIAttributeMin : @2,
                                      kCIAttributeMax : @65536,
                                      kCIAttributeDefault : @10,
                                      kCIAttributeType : kCIAttributeTypeInteger
                                      };
    
    NSDictionary *lutDataDictionary = @{
                                      kCIAttributeDefault : [self.class identityLUTDataOfSize:10]
                                      };
    
    return @{
             @"lutSize" : sizeDictionary,
             @"lutData": lutDataDictionary,
             // This is needed because the filter is registered under a different name than the class.
             kCIAttributeFilterName : @"VVLUT1DFilter"
             };
}

@end
