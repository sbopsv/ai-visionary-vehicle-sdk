/*
 * Copyright (C) 2016-2018 Alibaba Group Holding Limited
 */
#import <Foundation/Foundation.h>
#import "CACommonMessage.h"


static NSString* const CA_LF = @"\n";
static NSString* const CA_CURRENT_VERSION = @"1";
static NSString* const CA_USER_AGENT_DEFAULT = @"CA_iOS_SDK_2.0";
static NSString* const CA_HEADER_PREFIX = @"X-Ca-";
static NSString* const CA_HEADER_PREFIX_LOWERCASE = @"x-ca-";
static NSString* const CA_HEADER_APP_KEY = @"X-Ca-Key";
static NSString* const CA_HEADER_NONCE = @"X-Ca-Nonce";
static NSString* const CA_HEADER_TIMESTAMP = @"X-Ca-Timestamp";
static NSString* const CA_HEADER_VERSION = @"X-Ca-Version";

// 签名Header
static NSString* const CA_HEADER_SIGNATURE = @"X-Ca-Signature";

// 签名方法: 现在支持HAC-MAC, 和MAC256
static NSString* const CA_HEADER_SIGNATURE_METHOD = @"X-Ca-Signature-Method";

// 所有参与签名的Header
static NSString* const CA_HEADER_SIGNATURE_HEADERS = @"X-Ca-Signature-Headers";

//请求Header Accept
static NSString* const CA_HEADER_ACCEPT = @"Accept";

// 默认的Accept
static NSString* const CA_HEADER_ACCEPT_DEFAULT = @"application/json";

//请求Header UserAgent
static NSString* const CA_HEADER_USER_AGENT = @"User-Agent";

//请求Header Date
static NSString* const CA_HEADER_DATE = @"Date";

//请求Header Host
static NSString* const CA_HEADER_HOST = @"Host";

static int CA_REQUEST_DEFAULT_TIMEOUT = 10;
static int CA_REQUEST_DEFAULT_CACHE_POLICY = 0;

static NSString* const CA_SIGNATURE_METHOD_HmacSHA1 = @"HmacSHA1";
static NSString* const CA_SIGNATURE_METHOD_HmacSHA256 = @"HmacSHA256";

@protocol CASigner
- (NSString*) appKey;
- (NSString*) signatureMethod;
- (NSString*) signWithString:(NSString*)text;
@end

@interface CACommonRequest : CACommonMessage {
    NSString* _protocol;
    NSString* _host;
    NSString* _path;
    NSString* _method;
    NSURLRequestCachePolicy _cachePolicy;

    int _timeout;
    NSMutableDictionary* _queryParameters;
    NSMutableDictionary* _pathParameters;
    NSMutableDictionary* _formParameters;
    NSString* _signatureHeaders;
    NSObject* _attachment;
}

@property (nonatomic) int timeout;
@property (nonatomic) NSString* protocol;
@property (nonatomic) NSString* host;
@property (nonatomic) NSString* path;
@property (nonatomic) NSString* method;
@property (nonatomic) NSMutableDictionary* queryParameters;
@property (nonatomic) NSMutableDictionary* formParameters;
@property (nonatomic) NSMutableDictionary* pathParameters;

- (instancetype) initWithPath: (NSString*)path
                   withMethod: (NSString*)method
                     withHost: (NSString*)host
                      isHttps: (BOOL)isHttps;

- (instancetype) initWithPath: (NSString*)path
                   withMethod: (NSString*)method;

- (void) addPathParameter: (NSString*)value forKey:(NSString*)key;
- (void) addQueryParameter: (NSString*)value forKey:(NSString*)key;
- (void) addFormParameter: (NSString*)value forKey:(NSString*)key;
/**
 *  TODO: Added by Rinks (lincoms69)
 */
- (void) addBodyParameter: (NSData*)value;
- (void) signWithSigner:(id<CASigner>)signer;
- (NSURLRequest*) buildHttpRequest;
- (NSString*) buildJson;
@end
