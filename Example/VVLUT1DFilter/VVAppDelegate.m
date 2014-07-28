//
//  VVAppDelegate.m
//  VVLUT1DFilter
//
//  Created by Greg Cotten on 7/4/14.
//  Copyright (c) 2014 Video Village. All rights reserved.
//

#import "VVAppDelegate.h"
#import "VVLUT1DFilter.h"
#import "VVLUT1DFilterWithColorSpace.h"

@interface VVAppDelegate ()

@property (strong) CIFilter *lut1DFilter;

@end

@implementation VVAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    self.inputImage = [NSImage imageNamed:@"test.jpg"];
    
//    CIImage *lutImage = [CIImage imageWithBitmapData:[VVLUT1DFilter identityLUTDataOfSize:100]
//                                         bytesPerRow:sizeof(float)*4*100
//                                                size:CGSizeMake(100, 1)
//                                              format:kCIFormatRGBAf
//                                          colorSpace:CGColorSpaceCreateDeviceRGB()];
//    
//    NSCIImageRep *ciiRep = [NSCIImageRep imageRepWithCIImage:lutImage];
//    
//    NSImage *output = [[NSImage alloc] init];
//    
//    [output addRepresentation:ciiRep];
//    
//    self.inputImage = output;
    
    self.lut1DFilter = [CIFilter filterWithName:@"VVLUT1DFilterWithColorSpace"];
    
    [self.lut1DFilter setValue:[VVLUT1DFilter identityLUTDataOfSize:100] forKey:@"inputData"];
    [self.lut1DFilter setValue:@100 forKey:@"inputSize"];
    [self.lut1DFilter setValue:(__bridge id)CGColorSpaceCreateDeviceRGB() forKey:@"inputColorSpace"];
    
    self.imageWell.contentFilters = @[self.lut1DFilter];
}

@end
