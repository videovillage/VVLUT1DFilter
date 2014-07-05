//
//  VVLUT1DFilterMathHelper.m
//  VVLUT1DFilter
//
//  Created by Greg Cotten on 7/4/14.
//  Copyright (c) 2014 Video Village. All rights reserved.
//

#import "VVLUT1DFilterMathHelper.h"

@implementation VVLUT1DFilterMathHelper


+ (double)remapValue:(double)value
            inputLow:(double)inputLow
           inputHigh:(double)inputHigh
           outputLow:(double)outputLow
          outputHigh:(double)outputHigh{
    return outputLow + ((value - inputLow)*(outputHigh - outputLow))/(inputHigh - inputLow);
}

@end
