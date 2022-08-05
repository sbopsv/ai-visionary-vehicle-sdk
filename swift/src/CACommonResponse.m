/*
 * Copyright (C) 2016-2018 Alibaba Group Holding Limited
 */
#import "CACommonResponse.h"

@implementation CACommonResponse
@synthesize statusCode = _statusCode;
@synthesize error = _error;
    
- (instancetype) initWithHttpResponse:(NSURLResponse*)response
                             withData:(NSData*)data
                            withError:(NSError*)error {
    if (error != nil) {
        _error = error;
        _statusCode = (int)error.code;
        return self;
    } else {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
        _statusCode = (int)httpResponse.statusCode;
        _headers = [[NSMutableDictionary alloc] init];
        for (id key in httpResponse.allHeaderFields) {
            NSString* value = [httpResponse.allHeaderFields valueForKey: key];
            [self putHeader: value forName: key];
        }
        _body = data;
        return self;
    }
}

- (instancetype) initWithJson:(NSString*)json {
    self = [self init];
    NSError *error;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData: [json dataUsingEncoding:NSUTF8StringEncoding]
                                                        options: NSJSONReadingMutableContainers
                                                          error: &error];
    if (error != nil) {
        @throw [NSString stringWithFormat: @"json deserialize failed: %@", error];
    }
    
    NSNumber* code = [dic objectForKey: @"status"];
    _statusCode = [code intValue];
    [self addHeadersWithJsonDictionary: [dic objectForKey: @"header"]];
    [self setBodyString: [dic objectForKey: @"body"] withContentType: [self contentType]];
    return self;
}
    
- (NSString*) description {
    if (_error != nil) {
        return [_error description];
    } else {
        NSMutableString* s = [[NSMutableString alloc] initWithFormat:@"HTTP 1.1 %d\n", _statusCode];
        for (id key in _headers) {
            CAHeader* header = [_headers valueForKey: key];
            [s appendString: header.name];
            [s appendString: @": "];
            [s appendString: header.value];
            [s appendString: @"\n"];
            if (header.hasMore) {
                for (CAHeader* mh in header.moreHeaders) {
                    [s appendFormat: @"%@: %@\n", mh.name, mh.value];
                }
            }
        }
        [s appendString: @"\n"];
        [s appendString: [self bodyAsString]];
        return s;
    }
}

@end
