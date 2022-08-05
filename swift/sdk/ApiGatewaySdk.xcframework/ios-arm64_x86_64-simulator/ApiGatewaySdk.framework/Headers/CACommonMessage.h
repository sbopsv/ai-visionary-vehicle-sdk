/*
 * Copyright (C) 2016-2018 Alibaba Group Holding Limited
 */
#import <Foundation/Foundation.h>

@interface CAHeader: NSObject {
    NSString* _name;
    NSString* _value;
    NSMutableArray* _moreHeaders;
}
NS_ASSUME_NONNULL_BEGIN
@property (nonatomic, readonly) NSString* name;
@property (nonatomic, readonly) NSString* value;

- (instancetype) initWithValue: (NSString*)value forName:(NSString*)name;
- (BOOL) hasMore;
- (void) addMore:(CAHeader*)header;
- (NSArray*) moreHeaders;
NS_ASSUME_NONNULL_END
@end

NS_ASSUME_NONNULL_BEGIN
//请求Header Content-Type
static NSString* const CA_HEADER_CONTENT_TYPE = @"Content-Type";

//请求Body内容MD5 Header
static NSString* const CA_HEADER_CONTENT_MD5 = @"Content-MD5";

//表单类型Content-Type
static NSString* const CA_CONTENT_TYPE_FORM = @"application/x-www-form-urlencoded; charset=UTF-8";

//流类型Content-Type
static NSString* const CA_CONTENT_TYPE_STREAM = @"application/octet-stream; charset=UTF-8";

//JSON类型Content-Type
static NSString* const CA_CONTENT_TYPE_JSON = @"application/json; charset=UTF-8";

//XML类型Content-Type
static NSString* const CA_CONTENT_TYPE_XML = @"application/xml; charset=UTF-8";

//文本类型Content-Type
static NSString* const CA_CONTENT_TYPE_TEXT = @"application/text; charset=UTF-8";
NS_ASSUME_NONNULL_END

@interface CACommonMessage : NSObject {
    NSData* _body;
    NSMutableDictionary* _headers;
}

NS_ASSUME_NONNULL_BEGIN
- (instancetype) init;
- (CAHeader*) headerByName: (NSString*)name;
- (NSString*) headerValueByName: (NSString*)name;
- (NSString*) putHeader:(NSString *)value forName:(nonnull NSString *)name;
- (void) addHeader: (NSString*)value forName:(NSString *)name;

- (NSDictionary*) toJsonDictionary;
- (void) addHeadersWithJsonDictionary: (NSDictionary*) dict;

- (NSString*) contentType;

- (NSData*) body;
- (NSString*) bodyAsString;

- (void) setBody:(NSData*)data withContentType:(NSString*)contentType;
- (void) setBodyString:(NSString*)s withContentType:(NSString*)contentType;

NS_ASSUME_NONNULL_END
@end
