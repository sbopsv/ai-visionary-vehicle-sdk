/*
 * Copyright (C) 2016-2018 Alibaba Group Holding Limited
 */
#import "CACommonRequest.h"
#import "CAUtils.h"
    
@implementation CACommonRequest

@synthesize host = _host;
@synthesize path = _path;
@synthesize method = _method;
@synthesize timeout = _timeout;
@synthesize queryParameters = _queryParameters;
@synthesize pathParameters = _pathParameters;
@synthesize formParameters = _formParameters;

/**
 *
 */
- (instancetype) initWithPath: (NSString*)path
                   withMethod: (NSString*)method
                     withHost: (NSString*)host
                      isHttps: (BOOL)isHttps
{
    self = [super init];
    _host = host;
    _method = method;
    _path = path;
    _protocol = isHttps ? @"https://" : @"http://";
    _timeout = -1;
    _cachePolicy = CA_REQUEST_DEFAULT_CACHE_POLICY;

    _headers = [[NSMutableDictionary alloc] init];
    _formParameters = [[NSMutableDictionary alloc] init];
    _pathParameters = [[NSMutableDictionary alloc] init];
    _queryParameters = [[NSMutableDictionary alloc] init];
    
    [self addHeader: _host forName: CA_HEADER_HOST];
    [self addHeader: CA_CURRENT_VERSION forName: CA_HEADER_VERSION];
    [self addHeader: CA_USER_AGENT_DEFAULT forName: CA_HEADER_USER_AGENT];
    [self addHeader: [[NSUUID UUID] UUIDString] forName: CA_HEADER_NONCE];
    [self addHeader: CA_HEADER_ACCEPT_DEFAULT forName: CA_HEADER_ACCEPT];
    [self addHeader: CA_CONTENT_TYPE_JSON forName: CA_HEADER_CONTENT_TYPE];

    //
    // add current time to `Date` and `X-Ca-Timestamp` Header
    NSDate* now = [NSDate date];
    NSDateFormatter* df = [[NSDateFormatter alloc] init ];
    df.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [df setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss z"];
    [self addHeader: [df stringFromDate: now] forName: CA_HEADER_DATE];
    NSTimeInterval timeStamp = [now timeIntervalSince1970] * 1000;
    [self addHeader: [NSString stringWithFormat:@"%0.0lf", timeStamp] forName: CA_HEADER_TIMESTAMP];
    
    return self;
}

- (instancetype) initWithPath: (NSString*)path
                   withMethod: (NSString*)method
{
    self = [self initWithPath: path
                   withMethod: method
                     withHost: @""
                      isHttps: false];
    return self;
}

- (void) addPathParameter: (NSString*)value forKey:(NSString *)key {
    [self.pathParameters setValue: value forKey: key];
}
    
- (void) addQueryParameter: (NSString*)value forKey:(NSString *)key {
    [self.queryParameters setValue: value forKey: key];
}
    
- (void) addFormParameter: (NSString*)value forKey:(NSString *)key {
    [self.formParameters setValue: value forKey: key];
    [self putHeader: CA_CONTENT_TYPE_FORM forName: CA_HEADER_CONTENT_TYPE];
}

/**
 * TODO: Added by Rinks (lincoms69)
 *
 */
- (void) addBodyParameter: (NSData*)value {
    [self setBody:value withContentType:[self contentType]];
    [self putHeader: CA_CONTENT_TYPE_STREAM forName: CA_HEADER_CONTENT_TYPE];
}

/**
 *
 */
- (NSURLRequest*) buildHttpRequest {
    NSString* path = [CAUtils buildPath: _path withParams: _pathParameters];
    NSString* queryString = [CAUtils buildParams: _queryParameters];
    
    /**
     *  拼接URL
     *  HTTP + HOST + PATH(With pathparameter) + Query Parameter
     */
    NSMutableString *url = [[NSMutableString alloc] initWithFormat:@"%@%@%@", _protocol, _host, path];
    if ([queryString length] > 0){
        [url appendFormat:@"?%@" , queryString];
    }
    
    /**
     *  使用URL初始化一个NSMutableURLRequest类
     *  同时指定缓存策略和超时时间，这两个配置从AppConfiguration.h中设置
     */
    NSMutableURLRequest *result = [NSMutableURLRequest requestWithURL: [NSURL URLWithString: url]
                                                          cachePolicy: _cachePolicy
                                                      timeoutInterval: _timeout];

    result.HTTPMethod = _method;
    for (id key in _headers) {
        CAHeader *header = [_headers objectForKey: key];
        NSString* v = [[NSString alloc] initWithData:[header.value dataUsingEncoding:NSUTF8StringEncoding] encoding:NSISOLatin1StringEncoding];
        [result setValue: v forHTTPHeaderField: header.name];
        if (header.hasMore) {
            for (CAHeader *h2 in header.moreHeaders) {
                NSString* v2 = [[NSString alloc] initWithData:[h2.value dataUsingEncoding:NSUTF8StringEncoding] encoding:NSISOLatin1StringEncoding];
                [result setValue: v2 forHTTPHeaderField: h2.name];
            }
        }
    }
    
    if ([_formParameters count] > 0) {
        /**
         *  如果formParams不为空
         *  将Form中的内容拼接成字符串后使用UTF8编码序列化成Byte数组后加入到Request中去
         */
        NSString *body = [CAUtils buildParams: _formParameters];
        [result setHTTPBody: [body dataUsingEncoding: NSUTF8StringEncoding]];
    } else if (nil != self.body) {
        /**
         *  如果类型为byte数组的body不为空
         *  将body中的内容MD5算法加密后再采用BASE64方法Encode成字符串，放入HTTP头中
         *  做内容校验，避免内容在网络中被篡改
         */
        [result setHTTPBody: self.body];
    }
    return result;
}

- (NSString*) buildJson {
    NSMutableDictionary* dic = [[NSMutableDictionary alloc] init];
    [dic setValue: _method forKey: @"method"];
    [dic setValue: _host forKey: @"host"];
    NSString* path = [CAUtils buildPath: _path withParams: _pathParameters];
    [dic setValue: path forKey: @"path"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    for (id key in _queryParameters) {
        [params setValue: [_queryParameters valueForKey: key] forKey: key];
    }
//    for (id key in _formParameters) {
//        [params setValue: [_formParameters valueForKey: key] forKey: key];
//    }
    [dic setValue: params forKey: @"querys"];
    
    [dic setValue: [self toJsonDictionary] forKey: @"headers"];
    if ([_formParameters count] > 0) {
        // NSString* body = [CAUtils buildParams: _formParameters];
        [dic setValue: [self querysToSign] forKey: @"body"];
    }
    if (_body != nil) {
        [dic setValue: @"1" forKey: @"isBase64"];
        [dic setValue: [_body base64EncodedStringWithOptions: 0] forKey: @"body"];
    }
    
//    String method;
//    String host;
//    String path;
//    Map<String , String> querys;
//    Map<String, List<String>> headers;
//    int isBase64 = 0;
//    String body;
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject: dic
                                                       options: NSJSONWritingPrettyPrinted
                                                         error: &error];
    NSString *json =[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return json;
}

-(void) signWithSigner:(id<CASigner>)signer {
    //
    // sign request with appKey and appSecret
    [self putHeader: [signer appKey] forName: CA_HEADER_APP_KEY];
    [self putHeader: [signer signatureMethod] forName: CA_HEADER_SIGNATURE_METHOD];
    NSMutableString* stringToSign = [[NSMutableString alloc] init];
    NSMutableString* signatureHeaders = [[NSMutableString alloc] init];
    [self prepareSigatureStringTo: stringToSign signatureHeadersTo: signatureHeaders];
    NSString* signature = [signer signWithString: stringToSign];
    [self putHeader: signature forName: CA_HEADER_SIGNATURE];
    [self putHeader: signatureHeaders forName: CA_HEADER_SIGNATURE_HEADERS];
    //
    // NSLog(@"\n%@\n", stringToSign);
}

/**
 String stringToSign=
 HTTPMethod + "\n" +
 Accept + "\n"
 Content-MD5 + "\n"
 Content-Type + "\n" +
 Date + "\n" +
 Headers +
 Url

 POST
 application/json; charset=utf-8
 
 application/x-www-form-urlencoded; charset=utf-8
 Fri, 11 May 2018 03:52:28 GMT+00:00
 x-ca-key:23524193
 x-ca-nonce:bb195952-b62f-4ad6-8b5a-893089c489f8
 x-ca-seq:0
 x-ca-timestamp:1526010748924
 x-ca-websocket_api_type:REGISTER
 /register?Password=test&Username=test&password=test&username=test
 */

- (void) prepareSigatureStringTo: (NSMutableString*)s signatureHeadersTo:(NSMutableString*)signatureHeaders {
    // HTTPMethod + "\n"
    [s appendString: _method];
    [s appendString: CA_LF];
    // Accept + "\n"
    [s appendString: [self headerValueByName: CA_HEADER_ACCEPT]];
    [s appendString: CA_LF];
    // Content-MD5 + "\n"
    if (self.body != nil) {
        [s appendString: [self headerValueByName: CA_HEADER_CONTENT_MD5]];
    }
    [s appendString: CA_LF];
    // ContentType: "\n"
    [s appendString: [self headerValueByName: CA_HEADER_CONTENT_TYPE]];
    [s appendString: CA_LF];
    // Date + "\n"
    [s appendString: [self headerValueByName: CA_HEADER_DATE]];
    [s appendString: CA_LF];
    
    // Headers
    BOOL first = true;
    for (CAHeader* header in [self headersToSign]) {
        [s appendString: header.name];
        [s appendString: @":"];
        [s appendString: header.value];
        [s appendString: CA_LF];

        if (!first) {
            [signatureHeaders appendString: @","];
        } else {
            first = false;
        }
        [signatureHeaders appendString: header.name];

//      not support multiply X-Ca... headers Now
//        if ([header hasMore]) {
//            for (CAHeader* moreHeader in [header moreHeaders]) {
//                [s appendString: moreHeader.name];
//                [s appendString: @":"];
//                [s appendString: moreHeader.value];
//                [s appendString: CA_LF];
//            }
//        }
    }
    
    // Url and Params
    [s appendString: [self urlToSign]];
}

-(NSString*) urlToSign {
    NSMutableString* s = [[NSMutableString alloc] init];
    [s appendString: [CAUtils buildPath: _path withParams: _pathParameters]];
    NSString* querys = [self querysToSign];
    if (![NSString isStringEmpty: querys]) {
        [s appendString: @"?"];
        [s appendString: querys];
    }
    return s;
}

-(NSString*) querysToSign {
    NSMutableDictionary * parameters = [[NSMutableDictionary alloc] init];
    if ([self.formParameters count] > 0){
        [parameters addEntriesFromDictionary: self.formParameters];
    }
    if([self.queryParameters count] > 0){
        [parameters addEntriesFromDictionary: self.queryParameters];
    }
    if ([parameters count] == 0) {
        return @"";
    }
    
    NSArray * sortedKeys = [[parameters allKeys] sortedArrayUsingComparator:^NSComparisonResult(__strong id obj1,__strong id obj2) {
        NSString *str1=(NSString *)obj1;
        NSString *str2=(NSString *)obj2;
        return [str1 compare:str2];
    }];
    
    // append
    // ... ?Password=test&Username=test&password=test&username=test
    NSMutableString* s = [[NSMutableString alloc] init];
    for(int i = 0 ; i < sortedKeys.count ; i++){
        id key = [sortedKeys objectAtIndex:i];
        [s appendString:key];
        
        NSString* value = [parameters objectForKey:key];
        if (![NSString isStringEmpty: value]) {
            [s appendFormat:@"=%@" , value];
        }
        if (i != sortedKeys.count - 1) {
            [s appendString:@"&"];
        }
    }
    return s;
}

- (NSArray*) headersToSign {
    NSMutableArray* headers = [[NSMutableArray alloc] init];
    for (NSString* key in _headers) {
        if ([key hasPrefix: CA_HEADER_PREFIX_LOWERCASE]) {
            if ([key caseInsensitiveCompare: CA_HEADER_SIGNATURE] == NSOrderedSame) {
                continue;
            }
            if ([key caseInsensitiveCompare: CA_HEADER_SIGNATURE_HEADERS] == NSOrderedSame) {
                continue;
            }
            CAHeader* h = [_headers valueForKey: key];
            // some bugs cause only header start with "X-Ca" can be signatured
            if ([h.name hasPrefix: CA_HEADER_PREFIX]) {
                [headers addObject: h];
            }
        }
    }
    if ([headers count] == 0) {
        return headers;
    }
    return [headers sortedArrayUsingComparator:^NSComparisonResult(__strong id obj1,__strong id obj2) {
        NSString *str1=((CAHeader *)obj1).name;
        NSString *str2=((CAHeader *)obj2).name;
        return [str1 compare:str2];
    }];
}

- (NSString*) description {
    NSMutableString* s = [[NSMutableString alloc] initWithFormat:@"%@ %@ HTTP/1.1\n", _method, [self urlToSign]];
    for (id key in _headers) {
        CAHeader* h = [_headers valueForKey: key];
        [s appendString: h.name];
        [s appendString: @": "];
        [s appendString: h.value ];
        [s appendString: @"\n"];
    }
    [s appendString: @"\n"];
    [s appendString: [self bodyAsString]];
    return s;
}
@end
