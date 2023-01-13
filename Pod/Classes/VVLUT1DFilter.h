//
//  VVLUT1DFilter.h
//  VVLUT1DFilter
//
//  Created by Greg Cotten on 7/4/14.
//  Copyright (c) 2014 Video Village. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import <CoreImage/CoreImage.h>

@interface VVLUT1DFilter : CIFilter

+ (void)registerFilter;
+ (NSData *)identityLUTDataOfSize:(int)size;

@end
