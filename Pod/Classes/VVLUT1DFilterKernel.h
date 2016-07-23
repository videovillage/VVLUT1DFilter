//
//  VVLUT1DFilterKernel.h
//  Pods
//
//  Created by Greg Cotten on 1/12/15.
//
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

#define VVLUT1DFILTER_TEX_MAX_WIDTH 4096

@interface VVLUT1DFilterKernel : NSObject

+ (CIKernel *)kernel;

@end
