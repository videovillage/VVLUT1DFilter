//
//  VVLUT1DFilterMathHelper.m
//  VVLUT1DFilter
//
//  Created by Greg Cotten on 7/4/14.
//  Copyright (c) 2014 Video Village. All rights reserved.
//

#import "VVLUT1DFilterMathHelper.h"

double remap(double value, double inputLow, double inputHigh, double outputLow, double outputHigh){
    if(value < inputLow || value > inputHigh){
        @throw [NSException exceptionWithName:@"RemapValueOutOfBounds"
                                       reason:[NSString stringWithFormat:@"Tried to remap out-of-bounds value (%f) with input constraints low:%f high:%f", value, inputLow, inputHigh]
                                     userInfo:nil];
    }
    if(inputLow > inputHigh){
        @throw [NSException exceptionWithName:@"RemapInputsError"
                                       reason:[NSString stringWithFormat:@"Inputs low:%f high:%f. low must be less than or equal to high", inputLow, inputHigh]
                                     userInfo:nil];
    }
    if(outputLow > outputHigh){
        @throw [NSException exceptionWithName:@"RemapOutputsError"
                                       reason:[NSString stringWithFormat:@"Outputs low:%f high:%f. low must be less than or equal to high", outputLow, outputHigh]
                                     userInfo:nil];
    }
    return remapNoError(value, inputLow, inputHigh, outputLow, outputHigh);
}

double remapNoError(double value, double inputLow, double inputHigh, double outputLow, double outputHigh){
    return outputLow + ((value - inputLow)*(outputHigh - outputLow))/(inputHigh - inputLow);
}

@implementation VVLUT1DFilterMathHelper

@end
