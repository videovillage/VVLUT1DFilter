//
//  VVAppDelegate.m
//  VVLUT1DFilter
//
//  Created by Greg Cotten on 7/4/14.
//  Copyright (c) 2014 Video Village. All rights reserved.
//

#import "VVAppDelegate.h"
#import "VVLUT1DFilter.h"

@interface VVAppDelegate ()

@property (strong) CIFilter *lut1DFilter;

@end

@implementation VVAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    self.inputImage = [NSImage imageNamed:@"test"];
    
//    CIImage *lutImage = [CIImage imageWithBitmapData:[VVLUT1DFilter identityLUTDataOfSize:10000]
//                                         bytesPerRow:sizeof(float)*4*10
//                                                size:CGSizeMake(10, 1000)
//                                              format:kCIFormatRGBAf
//                                          colorSpace:CGColorSpaceCreateDeviceRGB()];
//    
//    NSCIImageRep *ciiRep = [NSCIImageRep imageRepWithCIImage:lutImage];
//    
//    NSImage *output = [[NSImage alloc] init];
//    
//    [output addRepresentation:ciiRep];
    
//    self.inputImage = output;
    
    [VVLUT1DFilter registerFilter];
    self.lut1DFilter = [CIFilter filterWithName:@"VVLUT1DFilter"];
    
    [self.lut1DFilter setValue:[VVLUT1DFilter identityLUTDataOfSize:100] forKey:@"lutData"];
    [self.lut1DFilter setValue:@100 forKey:@"lutSize"];
    
    self.imageWell.contentFilters = @[self.lut1DFilter];
}

@end
