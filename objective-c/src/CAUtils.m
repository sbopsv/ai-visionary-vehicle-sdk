/*
 * Copyright (C) 2016-2018 Alibaba Group Holding Limited
 */
#import "CAUtils.h"
#import <CommonCrypto/CommonHMAC.h>

@implementation CAUtils
/**
 *
 */
+(NSString*) calcMD5:(NSData*)data {
    NSString* s = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return [NSString md5ForString: s];
}

/**
 *
 */
+(NSString*) hmacSHA256:(NSString *)data withSecret:(NSString*)secret {
    const char *cKey  = [secret cStringUsingEncoding:NSUTF8StringEncoding];
    const char *cData = [data cStringUsingEncoding:NSUTF8StringEncoding];

    unsigned char cHMAC[CC_SHA256_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA256, cKey, strlen(cKey), cData, strlen(cData), cHMAC);

    //
    // 将加密结果进行一次BASE64编码
    NSData* HMAC = [[NSData alloc] initWithBytes: cHMAC
                                          length: sizeof(cHMAC)];
    NSString* hash = [HMAC base64EncodedStringWithOptions:0];
    return hash;
}

/**
 *
 */
+(NSString*) hmacSHA1:(NSString *)data withSecret:(NSString*)secret {
    const char *cKey  = [secret cStringUsingEncoding:NSUTF8StringEncoding];
    const char *cData = [data cStringUsingEncoding:NSUTF8StringEncoding];
    
    unsigned char cHMAC[CC_SHA1_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA1, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    
    //
    // 将加密结果进行一次BASE64编码
    NSData* HMAC = [[NSData alloc] initWithBytes: cHMAC
                                          length: sizeof(cHMAC)];
    NSString* hash = [HMAC base64EncodedStringWithOptions:0];
    return hash;
}


/**
 * buildPath with: /path/[param1]
 * and param1=value1
 */
+(NSString*) buildPath: (NSString*)path withParams:(NSDictionary*)params {
    NSMutableString* r = [[NSMutableString alloc] initWithString: path];
    for (id key in params) {
        NSString* value = [params objectForKey:key];
        [r replaceCharactersInRange: [r rangeOfString:[NSString stringWithFormat:@"[%@]", key]]
                         withString: value];
    }
    return r;
}

/**
 * params
 */
+(NSString*) buildParams: (NSDictionary*)params {
    NSCharacterSet* charset = [[NSCharacterSet characterSetWithCharactersInString:@"+= \"#%/:<>?@[\\]^`{|}"] invertedSet];
    NSMutableString * r = [[NSMutableString alloc] init];
    if (nil == params || [params count] == 0) {
        return @"";
    }
    bool isFirst = true;
    for (id key in params) {
        if (!isFirst) {
            [r appendString:@"&"];
        } else {
            isFirst = false;
        }
        NSString* p = [params objectForKey: key];
        [r appendFormat:@"%@=%@", key , [p stringByAddingPercentEncodingWithAllowedCharacters: charset]];
    }
    return r;
}
@end

@implementation NSString(CAUtils)
+(BOOL)isStringEmpty: (NSString*)aString {
    if (!aString) {
        return YES;
    }
    return [aString isEqualToString:@""];
}
+(NSString*) md5ForString: (NSString*)s {
    unsigned char digist[CC_MD5_DIGEST_LENGTH]; //CC_MD5_DIGEST_LENGTH = 16
    const char *pStr = [s UTF8String];
    CC_MD5(pStr, (uint)strlen(pStr), digist);
    NSData * md5data = [[NSData alloc] initWithBytes:digist length:sizeof(digist)];
    NSString * result = [md5data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    return result;
}
@end
