//
//  VVLUT1DFilterMathHelper.h
//  VVLUT1DFilter
//
//  Created by Greg Cotten on 7/4/14.
//  Copyright (c) 2014 Video Village. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VVLUT1DFilterMathHelper : NSObject

+ (double)remapValue:(double)value
            inputLow:(double)inputLow
           inputHigh:(double)inputHigh
           outputLow:(double)outputLow
          outputHigh:(double)outputHigh;

@end
