//
//  VVLUT1DFilterMathHelper.h
//  VVLUT1DFilter
//
//  Created by Greg Cotten on 7/4/14.
//  Copyright (c) 2014 Video Village. All rights reserved.
//

#import <Foundation/Foundation.h>


double remap(double value, double inputLow, double inputHigh, double outputLow, double outputHigh);
double remapNoError(double value, double inputLow, double inputHigh, double outputLow, double outputHigh);

@interface VVLUT1DFilterMathHelper : NSObject

@end
