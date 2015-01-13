//
//  VVLUT1DFilterWithColorSpace.m
//  Pods
//
//  Created by Greg Cotten on 7/28/14.
//
//

#import "VVLUT1DFilterWithColorSpace.h"
#import "VVLUT1DFilterKernel.h"

@implementation VVLUT1DFilterWithColorSpace{
    CIImage   *inputImage;
    NSData *inputData;
    NSNumber *inputSize;
    id inputColorSpace;
}

static CIKernel *lut1DKernel = nil;

+ (void)load{
    [self registerFilter];
}

+ (void)registerFilter {
    NSDictionary *attributes = @{ kCIAttributeFilterDisplayName : @"LUT1DWithColorSpace",
                                  kCIAttributeFilterCategories : @[kCICategoryVideo, kCICategoryStillImage] };
    [CIFilter registerFilterName:@"VVLUT1DFilterWithColorSpace" constructor:(id <CIFilterConstructor>)self classAttributes:attributes];
}

+ (CIFilter *)filterWithName:(NSString *)name {
    return [[self alloc] init];
}

+ (NSBundle *)kernelBundle{
    static NSBundle *kernelBundle = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        kernelBundle = [NSBundle bundleWithURL:[[NSBundle mainBundle] URLForResource:@"VVLUT1DFilterKernel" withExtension:@"bundle"]];
    });

    return kernelBundle;
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

- (id)init
{
    self = [super init];

    if (self) {
        if (lut1DKernel == nil)
        {
//            NSURL *kernelURL = [[self.class kernelBundle] URLForResource:@"VVLUT1DKernel" withExtension:@"cikernel"];
//
//            NSError *error;
//            NSString *kernelCode = [NSString stringWithContentsOfURL:kernelURL encoding:NSUTF8StringEncoding error:&error];
//            if (kernelCode == nil) {
//                NSLog(@"Error loading kernel code string in %@\n%@", NSStringFromSelector(_cmd), [error localizedDescription]);
//                abort();
//            }

            NSArray *kernels = [CIKernel kernelsWithString:[VVLUT1DFilterKernel kernelString]];
            lut1DKernel = [kernels objectAtIndex:0];
        }
    }

    return self;
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

    NSDictionary *colorspaceDictionary = @{
                                           kCIAttributeDefault : (__bridge id)CGColorSpaceCreateDeviceRGB()
                                           };

    return @{
             @"inputSize" : sizeDictionary,
             @"inputData": lutDataDictionary,
             @"inputColorSpace": colorspaceDictionary,
             // This is needed because the filter is registered under a different name than the class.
             kCIAttributeFilterName : @"VVLUT1DFilterWithColorSpace"
             };
}

- (void)setDefaults{
    inputData = [self.class identityLUTDataOfSize:100];
    inputSize = @100;
    inputColorSpace = (__bridge id)CGColorSpaceCreateDeviceRGB();
}

- (CGRect)regionOf:(int)samplerIndex destRect:(CGRect)r
{
    if (samplerIndex == 0) {
        return r;
    }
    return NSMakeRect(0, 0, inputSize.integerValue, 1);
}

- (CIImage *)outputImage {
    CIImage *lutImage = [CIImage imageWithBitmapData:inputData
                                         bytesPerRow:sizeof(float)*4*inputSize.integerValue
                                                size:CGSizeMake(inputSize.integerValue, 1)
                                              format:kCIFormatRGBAf
                                          colorSpace:nil];

    CISampler *inputSampler = [CISampler samplerWithImage: inputImage options:@{kCISamplerColorSpace: inputColorSpace}];
    CISampler *lutSampler = [CISampler samplerWithImage: lutImage options:@{kCISamplerFilterMode: kCISamplerFilterLinear,
                                                                            kCISamplerWrapMode: kCISamplerWrapClamp}];
    [lut1DKernel setROISelector:@selector(regionOf:destRect:)];

    NSArray * outputExtent = @[@(inputImage.extent.origin.x),
                               @(inputImage.extent.origin.y),
                               @(inputImage.extent.size.width),
                               @(inputImage.extent.size.height)];

    return [self apply:lut1DKernel, inputSampler, lutSampler, kCIApplyOptionExtent, outputExtent, kCIApplyOptionColorSpace, inputColorSpace, nil];
}

@end
