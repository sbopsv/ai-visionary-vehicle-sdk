/*
 * Copyright (C) 2016-2018 Alibaba Group Holding Limited
 */
#import "CACommonMessage.h"
#import "CAUtils.h"

@implementation CAHeader
@synthesize name = _name;
@synthesize value = _value;

- (instancetype) initWithValue: (NSString*)value forName:(NSString*)name {
    _name = name;
    _value = value;
    return self;
}

- (BOOL) hasMore {
    return _moreHeaders != nil;
}

- (void) addMore:(CAHeader*)header {
    if (_moreHeaders != nil) {
        _moreHeaders = [[NSMutableArray alloc] init];
    }
    [_moreHeaders addObject: header];
}

- (NSArray*) moreHeaders {
    return _moreHeaders;
}
@end

@implementation CACommonMessage

- (instancetype) init {
    _headers = [[NSMutableDictionary alloc] init];
    return self;
}

- (NSDictionary*) toJsonDictionary {
    NSMutableDictionary* headers = [[NSMutableDictionary alloc] init];
    for (NSString* key in _headers) {
        CAHeader* header = [_headers valueForKey: key];
        NSMutableArray* values = [[NSMutableArray alloc] init];
        [values addObject: header.value];
        if (header.hasMore) {
            for (CAHeader* mh in header.moreHeaders) {
                [values addObject: mh.value];
            }
        }
        [headers setValue: values forKey: header.name];
    }
    return headers;
}

- (void) addHeadersWithJsonDictionary: (NSDictionary*) dict {
    for (NSString* name in dict) {
        id v = [dict valueForKey: name];
        if ([v isKindOfClass: [NSArray class]]) {
            for (NSString* value in v) {
                [self addHeader: value forName: name];
            }
        } else if ([v isKindOfClass: [NSString class]]) {
            [self addHeader: v forName: name];
        } else {
            @throw [NSString stringWithFormat: @"bad class kind: %@", v];
        }
    }
}

- (NSString*) putHeader:(NSString *)value forName:(nonnull NSString *)name {
    if (value == nil) {
        @throw [NSString stringWithFormat: @"empty header value for %@", name];
    }
    NSString* key = [name lowercaseString];
    CAHeader* old = [_headers objectForKey: key];
    CAHeader* new = [[CAHeader alloc] initWithValue: value forName: name];
    if (old != nil) {
        [_headers setValue: new forKey: key];
        return old.value;
    } else {
        [_headers setValue: new forKey: key];
        return nil;
    }
}

- (void) addHeader: (NSString*)value forName:(NSString *)name {
    if (value == nil) {
        @throw [NSString stringWithFormat: @"empty header value for %@", name];
    }
    NSString* key = [name lowercaseString];
    CAHeader* header = [_headers objectForKey: key];
    if (header != nil) {
        [header addMore: [[CAHeader alloc] initWithValue: value forName: name]];
    } else {
        header = [[CAHeader alloc] initWithValue: value forName: name];
        [_headers setValue: header forKey: key];
    }
}

/**
 *
 */
- (CAHeader*) headerByName: (NSString*)name {
    if ([NSString isStringEmpty:name]) {
        @throw [NSString stringWithFormat:@"headerByName input empty"];
    }
    return [_headers objectForKey: [name lowercaseString]];
}

/**
 *
 */
- (NSString*) headerValueByName: (NSString*)name {
    if ([NSString isStringEmpty:name]) {
        @throw [NSString stringWithFormat:@"headerValueByName input empty"];
    }
    CAHeader* header = [_headers objectForKey: [name lowercaseString]];
    if (header == nil) {
        @throw [NSString stringWithFormat:@"missing header %@", name];
    }
    if (header.hasMore) {
        @throw [NSString stringWithFormat:@"ambigous header %@", name];
    }
    return header.value;
}

- (NSString*) contentType {
    return [self headerValueByName: CA_HEADER_CONTENT_TYPE];
}

- (NSData*) body {
    return _body;
}

- (NSString*) bodyAsString {
//    NSString* contentType = [self headerValueByName: CA_HEADER_CONTENT_TYPE];
//    String[] charsetStr = contentType.split(";");
//    for(int i = 0 ; i < charsetStr.length ; i++){
//        if(charsetStr[i].contains("charset")){
//            charset = Charset.forName(charsetStr[i].substring(charsetStr[i].indexOf("=")));
//        }
//    }
//    contentType
    if (_body == nil) {
        return @"";
    } else {
        return [[NSString alloc] initWithData: _body encoding:NSUTF8StringEncoding];
    }
}

- (void) setBody:(NSData*)data withContentType:(NSString*)contentType {
    _body = data;
    [self putHeader: contentType forName:CA_HEADER_CONTENT_TYPE];
    NSString* md5 = [CAUtils calcMD5: _body];
    [self putHeader: md5 forName: CA_HEADER_CONTENT_MD5];
}

- (void) setBodyString:(NSString*)s withContentType:(NSString*)contentType {
    NSData* buf = [s dataUsingEncoding: NSUTF8StringEncoding];
    [self setBody: buf withContentType: contentType];
}
@end
