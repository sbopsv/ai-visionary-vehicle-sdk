/*
 * Copyright (C) 2016-2018 Alibaba Group Holding Limited
 */
#import <Foundation/Foundation.h>
#import "CACommonRequest.h"
#import "CACommonResponse.h"

/**
 * Client for CloudAPI Gateway
 * - invoke
 *
 */
@interface CAClient : NSObject<CASigner> {
    int _timeout;
    NSString* _appKey;
    NSString* _appSecret;
    NSString* _signatureMethod;
    NSURLSession* _session;
    BOOL (^_verifyHttpsCert)(NSURLAuthenticationChallenge *);
}

@property (nonatomic) int timeout;
@property (nonatomic) NSString* signatureMethod;
@property (nonatomic) BOOL (^verifyHttpsCert)(NSURLAuthenticationChallenge *);

-(void) setAppKeyAndAppSecret:(NSString*)appKey appSecret:(NSString*) appSecret;

/**
 * init client with appKeyId and secret
 */
- (CAClient*) init;

/**
 * invoke async
 */
- (void) invokeWithRequest: (CACommonRequest*)request
              withCallback: (void (^)(CACommonResponse*))callback;
@end
