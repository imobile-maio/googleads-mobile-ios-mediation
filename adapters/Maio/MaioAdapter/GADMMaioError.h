//
//  GADMMaioError.h
//  GADMMaioAdapter
//
//  Copyright © 2017 i-mobile, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GADMMaioError : NSObject

+ (NSError *)errorWithDescription:(NSString *)description;
+ (NSError *)errorWithDescription:(NSString *)description errorCode:(NSInteger)errorCode;
+ (NSString *)stringFromErrorCode:(NSInteger)errorCode;

+ (BOOL)codeIsAboutLoad:(NSInteger)errorCode;
+ (BOOL)codeIsAboutShow:(NSInteger)errorCode;

@end
