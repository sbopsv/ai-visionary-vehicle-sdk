/*
 * Copyright (C) 2016-2018 Alibaba Group Holding Limited
 */
#import "CAClient.h"
#import "CAUtils.h"
#import "CACommonRequest.h"

@implementation CAClient

@synthesize timeout = _timeout;
@synthesize signatureMethod = _signatureMethod;
@synthesize verifyHttpsCert = _verifyHttpsCert;

/**
 * init with AppKey:AppSecret
 */
-(CAClient*) init {
    _signatureMethod = CA_SIGNATURE_METHOD_HmacSHA256;
    _timeout = CA_REQUEST_DEFAULT_TIMEOUT;
    
    _session = [NSURLSession sessionWithConfiguration: [NSURLSessionConfiguration defaultSessionConfiguration]
                                             delegate: (id <NSURLSessionDelegate>)self
                                        delegateQueue: [NSOperationQueue mainQueue]];
    return self;
}

-(void) setAppKeyAndAppSecret:(NSString*)appKey appSecret:(NSString*) appSecret{
    _appKey = appKey;
    _appSecret = appSecret;
}

-(NSString*) appKey {
    return _appKey;
}

-(NSString*) signatureMethod {
    return _signatureMethod;
}

-(NSString*) signWithString:(NSString*)text {
    // NSLog(@"SIGN WITH TEXT\n%@\n", text);
    NSString* signature = @"EMPTY_SIGNATURE";
    if ([CA_SIGNATURE_METHOD_HmacSHA256 isEqualToString: _signatureMethod]) {
        signature = [CAUtils hmacSHA256: text withSecret: _appSecret];
    } else if ([CA_SIGNATURE_METHOD_HmacSHA1 isEqualToString: _signatureMethod]) {
        signature = [CAUtils hmacSHA1: text withSecret: _appSecret];
    } else {
        @throw [NSString stringWithFormat: @"Unexcepted signature method %@", _signatureMethod];
    }
    return signature;
}


/**
 *
 */
- (void) invokeWithRequest: (CACommonRequest*)request
       withCallback: (void (^)(CACommonResponse*))callback
{
    if (request.timeout < 0) {
        request.timeout = self.timeout;
    }
    [request signWithSigner: self];
    NSURLRequest* nsRequest = [request buildHttpRequest];
    NSLog(@"invoke with request\n%@", [request description]);
    NSURLSessionDataTask *task = [_session dataTaskWithRequest: nsRequest
                                             completionHandler: ^(NSData* data, NSURLResponse* response, NSError* error) {
                                                 CACommonResponse* caResponse = [[CACommonResponse alloc] initWithHttpResponse:response
                                                                                                                      withData:data
                                                                                                                     withError:error];
                                                 callback(caResponse);
                                             }];
    [task resume];
}

- (void)    URLSession:(NSURLSession *)session
              dataTask:(NSURLSessionDataTask *)dataTask
        didReceiveData:(NSData *)data
{
    NSLog(@"%@",[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding]);
}

- (void)        URLSession:(NSURLSession *)session
       didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
         completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * __nullable credential))completionHandler
{
    // 如果使用默认的处置方式，那么 credential 就会被忽略
    NSURLSessionAuthChallengeDisposition disposition = NSURLSessionAuthChallengePerformDefaultHandling;
    NSURLCredential *credential = nil;
    
    if ([challenge.protectionSpace.authenticationMethod isEqualToString: NSURLAuthenticationMethodServerTrust]) {
        /* 调用自定义的验证过程 */
        if (_verifyHttpsCert != nil && _verifyHttpsCert(challenge)) {
            credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
            if (credential) {
                disposition = NSURLSessionAuthChallengeUseCredential;
            }
        } else {
            /* 无效的话，取消 */
            disposition = NSURLSessionAuthChallengeCancelAuthenticationChallenge;
        }
    }
    if (completionHandler) {
        completionHandler(disposition, credential);
    }
}
@end
