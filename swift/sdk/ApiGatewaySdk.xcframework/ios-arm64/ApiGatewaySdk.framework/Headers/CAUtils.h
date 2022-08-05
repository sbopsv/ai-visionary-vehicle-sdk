/*
 * Copyright (C) 2016-2018 Alibaba Group Holding Limited
 */
#import <Foundation/Foundation.h>

@interface CAUtils : NSObject
+(NSString*) calcMD5: (NSData*)data;
+(NSString*) hmacSHA256:(NSString *)data withSecret:(NSString*)key;
+(NSString*) hmacSHA1:(NSString *)data withSecret:(NSString*)key;
+(NSString*) buildPath: (NSString*)path withParams:(NSDictionary*)params;
+(NSString*) buildParams: (NSDictionary*)params;
@end

@interface  NSString(CAUtils)
+(BOOL)isStringEmpty: (NSString*)aString;
+(NSString*) md5ForString: (NSString*)s;
@end
