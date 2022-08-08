/*
 * Copyright (C) 2016-2018 Alibaba Group Holding Limited
 */
#import <Foundation/Foundation.h>
#import "CACommonRequest.h"

/**
 * Common Response to process HTTP/WebSocket response
 */
@interface CACommonResponse : CACommonMessage {
    @protected
    int _statusCode;
    NSError* _error;
}

/**
 * http status code or network status code
 */
@property (nonatomic, readonly) int statusCode;

/**
 * if error
 */
@property (nonatomic, readonly) NSError* error;

/**
 * init response with NSURL... result
 */
- (instancetype) initWithHttpResponse: (NSURLResponse*)response
                             withData: (NSData*)data
                            withError: (NSError*)error;

/**
 * init response with websocket content json
 */
- (instancetype) initWithJson: (NSString*)json;

/**
 * to string
 */
- (NSString*) description;
@end
