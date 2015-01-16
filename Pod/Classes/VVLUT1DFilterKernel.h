//
//  VVLUT1DFilterKernel.h
//  Pods
//
//  Created by Greg Cotten on 1/12/15.
//
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

#define STRINGIZE(x) #x
#define STRINGIZE2(x) STRINGIZE(x)
#define SHADER_STRING(text) @ STRINGIZE2(text)
#define VVLUT1DFILTER_TEX_MAX_WIDTH 1024

@interface VVLUT1DFilterKernel : NSObject

+ (CIKernel *)kernel;

@end
