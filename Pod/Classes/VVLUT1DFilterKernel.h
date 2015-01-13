//
//  VVLUT1DFilterKernel.h
//  Pods
//
//  Created by Greg Cotten on 1/12/15.
//
//

#import <Foundation/Foundation.h>

#define STRINGIZE(x) #x
#define STRINGIZE2(x) STRINGIZE(x)
#define SHADER_STRING(text) @ STRINGIZE2(text)

@interface VVLUT1DFilterKernel : NSObject

+ (NSString *)kernelString;

@end
