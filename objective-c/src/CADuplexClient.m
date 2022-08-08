/*
 * Copyright (C) 2016-2018 Alibaba Group Holding Limited
 */
#import <Foundation/Foundation.h>
#import "SRWebSocket.h"
#import "CACommonRequest.h"
#import "CACommonResponse.h"
#import "CAUtils.h"
#import "CADuplexClient.h"

@implementation CAWebSocketTransaction
@synthesize sequence;
@synthesize expired;
@synthesize callback;
@end

@implementation CADuplexClient

@synthesize deviceId = _deviceId;
@synthesize status = _status;
@synthesize port = _port;
@synthesize host = _host;
@synthesize connectionBrokenHandler = _connectionBrokenHandler;
@synthesize notifyHandler = _notifyHandler;

/**
 * init CADuplexClient with appKey,appSecret,host
 */
-(instancetype) initWithHost: (NSString*)host;
{
    self = [super init];
    _port = 8080; // only 8080 available now
    _host = host;
    _url = [NSURL URLWithString: [NSString stringWithFormat: @"ws://%@:%d/websocket", _host, _port]];
    
    
    
    // initial status is CA_INITIAL
    _lock = [NSLock new];
    return self;
}

-(void) setAppKeyAndAppSecret:(NSString*)appKey appSecret:(NSString*) appSecret{
    [super setAppKeyAndAppSecret:appKey  appSecret:appSecret];
    // use random deviceId, format: "{uuid}@appkey"
    NSString* uuid = [[NSUUID UUID] UUIDString];
    uuid = [uuid stringByReplacingOccurrencesOfString: @"-" withString: @""];
    _deviceId = [NSString stringWithFormat: @"%@@%@", uuid, _appKey];
    _status = CA_INITIAL;
}

/**
 * open websocket and register with request:
 * - if success callback with register response
 * - if failed callback with response(error != nil)
 */
-(void) registerWithRequest: (CACommonRequest*)request
               withCallback: (void (^)(CACommonResponse*))callback {
    
    if (callback == nil) {
        @throw [NSString stringWithFormat:@"callback can't be empty"];
    }
    
    if (_status != CA_INITIAL) {
        NSError* error = [NSError errorWithDomain: @"com.aliyun.apigateway"
                                             code: 400
                                         userInfo: @{@"reason": [NSString stringWithFormat:@"unexcepted status: %d", (int)_status]}];
        CACommonResponse* resp = [[CACommonResponse alloc] initWithHttpResponse: nil
                                                                       withData: nil
                                                                      withError: error];
        callback(resp);
        return;
    }

    [request putHeader: _host forName: CA_HEADER_HOST];
    [request addHeader: _deviceId forName: CA_HEADER_DEVICE_ID];
    [request putHeader: CA_WEBSOCKET_API_TYPE_REGISTER forName: CA_HEADER_WEBSOCKET_API_TYPE];
    if (request.timeout < 0) {
        request.timeout = self.timeout;
    }
    _registerRequest = request;
    _registerCallback = callback;
    [self connect];
}

/**
 * unregister with request and close websocket:
 * - if success callback with unregister response, and status will be CA_CLOSED
 * - if failed callback with response(error != nil), and status will be CA_FAILED
 */
-(void) unregisterWithRequest: (CACommonRequest*)request
                 withCallback: (void (^)(CACommonResponse*))callback {
    if (callback == nil) {
        @throw [NSString stringWithFormat:@"callback can't be empty"];
    }
    
    if (_status != CA_CONNECTED) {
        NSError* error = [NSError errorWithDomain: @"com.aliyun.apigateway"
                                             code: 400
                                         userInfo: @{@"reason": [NSString stringWithFormat: @"Invalid Status %d", (int)_status]}];
        CACommonResponse* resp = [[CACommonResponse alloc] initWithHttpResponse: nil
                                                                       withData: nil
                                                                      withError: error];
        callback(resp);
        return;
    }
    
    _status = CA_UNREGISTERING;
    [request putHeader: _host forName: CA_HEADER_HOST];
    [request addHeader: _deviceId forName: CA_HEADER_DEVICE_ID];
    [request putHeader: CA_WEBSOCKET_API_TYPE_UNREGISTER forName: CA_HEADER_WEBSOCKET_API_TYPE];
    [self beginTransaction: request withCallback:^(CACommonResponse *response) {
        [self closeWithReason: @""];
        callback(response);
    }];
}

/**
 * invoke with request, via websocket
 * same usage with CAClient invokeWithRequest.
 */
-(void) invokeWithRequest: (CACommonRequest*)request
             withCallback: (void (^)(CACommonResponse*))callback {
    if (callback == nil) {
        @throw [NSString stringWithFormat:@"callback can't be empty"];
    }
    
    if (_status != CA_CONNECTED) {
        NSError* error = [NSError errorWithDomain: @"com.aliyun.apigateway"
                                             code: 400
                                         userInfo: @{@"reason": [NSString stringWithFormat: @"Invalid client status %d", (int)_status]}];
        CACommonResponse* resp = [[CACommonResponse alloc] initWithHttpResponse: nil
                                                                       withData: nil
                                                                      withError: error];
        callback(resp);
        return;
    }
    
    [request addHeader: _deviceId forName: CA_HEADER_DEVICE_ID];
    [request putHeader: _host forName: CA_HEADER_HOST];
    if (request.timeout < 0) {
        request.timeout = self.timeout;
    }
    [self beginTransaction: request withCallback: callback];
}

/**
 * SRWebSocketDelegate webSocketDidOpen, when websocket connected
 */
- (void)webSocketDidOpen:(SRWebSocket *)webSocket {
    NSLog(@"### CADuplexClient status=CA_REGISTERING_SHORT from %d, websocket opened, send RG", (int)_status);
    @synchronized(_lock) {
//        if (_status != CA_CONNECTING) {
//            NSLog(@">>> Websocket status unexpected: %lu", _status);
//        }
        _status = CA_REGISTERING_SHORT;
        NSString* msg = [NSString stringWithFormat: @"%@#%@", CA_DUPLEX_COMMAND_REGISTER_REQUEST, _deviceId];
        [self sendData: msg];
        NSLog(@">>> Websocket send: %@", msg);
    }
}

/**
 * SRWebSocketDelegate webSocket didCloseWithCode, trigger when websocket broken
 * if first registered
 *     change _status to CA_CONNECT_BROKEN, heartbeatThread will reconnect
 * else
 *     change _status to CA_FAILED, trigger register callback
 */
- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
    if (_status == CA_CLOSED || _status == CA_FAILED) {
        return;
    }
    if (_status == CA_UNREGISTERING) {
        [self closeWithReason:@"disconnect by server"];
        return;
    }
    @synchronized(_lock) {
        if (_heartbeatThread == nil) {
            _status = CA_FAILED;
            NSLog(@"### CADuplexClient status=CA_FAILED code=%@ reason=%@", @(code).stringValue , reason);
            NSError* error = [NSError errorWithDomain: @"com.aliyun.apigateway"
                                                 code: code
                                             userInfo: @{@"reason": [NSString stringWithFormat: @"connect failed %@", reason]}];
            CACommonResponse* response = [[CACommonResponse alloc] initWithHttpResponse: nil withData:nil withError: error];
            _registerCallback(response);
        } else  {
            _status = CA_CONNECTION_BROKEN;
            NSLog(@"### CADuplexClient status=CA_CONNECTION_BROKEN code=%@ reason=%@", @(code).stringValue , reason);
        }
    }
}

/**
 * SRWebSocketDelegate webSocket:didReceiveMessage
 * trigger when websocket receive message
 * websocket commands: refer to documents: ...
 */
- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message {
    NSString* text = (NSString*)message;
    NSLog(@"<<< WebSocket receive: %@\n", text);
    if ([NSString isStringEmpty: text]) {
        return;
    } else if (text.length <= 2) {
        if ([CA_DUPLEX_COMMAND_OVERFLOWCONTROL caseInsensitiveCompare: text]) {
            NSLog(@"### CADuplexClient status=CA_CONNECTION_EXPIRED recv 'OS'");
            @synchronized (_lock) {
                _status = CA_CONNECTION_EXPIRED;
            }
            return;
        } else if ([CA_DUPLEX_COMMAND_CONNECTION_RUNS_OUT caseInsensitiveCompare: text]) {
            NSLog(@"### CADuplexClient status=CA_CONNECTION_EXPIRED recv 'CR'");
            @synchronized (_lock) {
                _status = CA_CONNECTION_EXPIRED;
            }
            return;
        } else {
            return;
        }
    } else if ([text hasPrefix: CA_DUPLEX_COMMAND_HEARTBEAT_RESPONSE]) {
        NSString* sessionCredential = [text substringFromIndex:3];
        if ([_sessionCredential isEqualToString: sessionCredential]) {
            _heartbeatExpired = [[NSDate date] dateByAddingTimeInterval: _heartbeatTimeout / 1000];
        } else {
            NSLog(@"### CADuplexClient status=CA_CONNECTION_BROKEN session broken %@!=%@", sessionCredential, _sessionCredential) ;
            @synchronized (_lock) {
                _status = CA_CONNECTION_BROKEN;
            }
        }
    } else if ([text hasPrefix: CA_DUPLEX_COMMAND_REGISER_FAIL_REQUEST]) {  // "RF"
        NSString* msg = [text substringFromIndex: 3];
        NSError* error = [NSError errorWithDomain: @"com.aliyun.apigateway"
                                             code: -2
                                         userInfo: @{@"reason": [NSString stringWithFormat: @"websocket <R1> failed %@", msg]}];
        [self closeWithReason: [error description]];
        if (_heartbeatThread == nil) {
            _registerCallback([[CACommonResponse alloc] initWithHttpResponse: nil withData:nil withError: error]);
        }
        return;
    } else if ([text hasPrefix: CA_DUPLEX_COMMAND_REGISTER_SUCCESS_RESPONSE]) { // "RO"
        NSArray* array = [text componentsSeparatedByString: @"#"];
        _sessionCredential = array[1];
        _heartbeatTimeout = [array[2] intValue];
        _heartbeatExpired = [[NSDate date] dateByAddingTimeInterval: _heartbeatTimeout / 1000];

        if (_status == CA_REGISTERING_SHORT) {
            NSLog(@"### CADuplexClient status=CA_REGISTERING_LONG send register");
            _status = CA_REGISTERING_LONG;
           
            [self beginTransaction: _registerRequest withCallback:^(CACommonResponse *response) {
                [self registeredWithResponse: response];
            }];
        }
        return;
    } else if([text hasPrefix: CA_DUPLEX_COMMAND_NOTIFY_REQUEST]) {
         @synchronized(_lock) {
            [self sendData: CA_DUPLEX_COMMAND_NOTIFY_RESPONSE];
        }
        NSString* msg = [text substringFromIndex: 3];
        if (_notifyHandler != nil) {
            _notifyHandler(msg);
        }
        return ;
    } else if (false /*text.length() > 2 && !text.startsWith("{") && "#".equalsIgnoreCase(text.substring(3 ,4))*/){
        //兼容以后新版本信令
        return;
    } else{
        CACommonResponse* response = [[CACommonResponse alloc] initWithJson: text];
        [self endTransaction: response];
    }
}

//
// 协议方法 Websocket 打开失败
- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error {
    if (_connectionBrokenHandler != nil) {
        _connectionBrokenHandler([error description]);
    }
    if (_heartbeatThread == nil) {
        [self closeWithReason: @"websocket open failed"];
    } else {
        NSLog(@"### CADuplexClient status=CA_CONNECTION_BROKEN reconnect");
        _status = CA_CONNECTION_BROKEN;
    }
}

-(void) heartbeatProc: (int)timeout {
    while (true) {
        [NSThread sleepForTimeInterval: 1.0];
        NSDate* now = [NSDate date];
        //
        // clear timeout transactions
        NSMutableArray* expiredTxs = [[NSMutableArray alloc] init];
        @synchronized (_lock) {
            for (id key in _trans) {
                CAWebSocketTransaction* tx = [_trans valueForKey: key];
                if ([now compare: tx.expired] > 0) {
                    [expiredTxs addObject: tx];
                }
            }
        }
        for (CAWebSocketTransaction* tx in expiredTxs) {
            NSError* error = [NSError errorWithDomain: @"com.aliyun.apigateway"
                                                 code: -1
                                             userInfo: @{@"reason": [NSString stringWithFormat: @"transaction timeout"]}];
            CACommonResponse* response = [[CACommonResponse alloc] initWithHttpResponse:nil withData:nil withError: error];
            tx.callback(response);
            @synchronized (_lock) {
                [_trans removeObjectForKey: tx.sequence];
            }
        }
        
        //
        // process heartbeat
        if (_status == CA_CONNECTED) {
            if ([now compare: _heartbeatExpired] > 0) {
                @synchronized(_lock) {
                    NSLog(@">>> Websocket send: %@", CA_DUPLEX_COMMAND_HEARTBEAT_REQUEST);
                    [self sendData: CA_DUPLEX_COMMAND_HEARTBEAT_REQUEST];
                }
            }
        } else if (_status == CA_CONNECTION_EXPIRED) {
            NSLog(@">>> reconnect from CA_CONNECTION_EXPIRED");
            [self connect];
        } else if (_status == CA_CONNECTION_BROKEN) {
            NSLog(@">>> reconnect from CA_CONNECTION_BROKEN");
            [self connect];
        } else if (_status == CA_CLOSED || _status == CA_FAILED) {
            NSLog(@"Heartbeat thread failed status=%d", (int)_status);
            return;
        }
    }
}

-(void) connect {
    @synchronized (_lock) {
        _trans = [[NSMutableDictionary alloc] init];
        _sequence = 0;
        
        NSLog(@"### CADuplexClient status=CA_CONNECTING from %d websocket opening...", (int)_status);
        _status = CA_CONNECTING;
        _websocket = [[SRWebSocket alloc] initWithURL: _url];
        _websocket.delegate = self;
        [_websocket open];
    }
}


-(void) closeWithReason: (NSString*)reason {
    @synchronized(_lock) {
        if ([NSString isStringEmpty: reason]) {
            NSLog(@"### CADuplexClient status=CA_CLOSED from %d", (int)_status);
            _status = CA_CLOSED;
        } else {
            NSLog(@"### CADuplexClient status=CA_FAILED from %d reason:%@", (int)_status, reason);
            _status = CA_FAILED;
        }
        if(nil != _websocket){
            [_websocket close];
        }
        if (_heartbeatThread != nil) {
            [_heartbeatThread cancel];
            _heartbeatThread = nil;
        }
    }
    if (_connectionBrokenHandler != nil) {
        _connectionBrokenHandler(reason);
    }
}

/**
 * begin transaction with request
 */
-(void) beginTransaction:(CACommonRequest*)request withCallback:(void (^)(CACommonResponse*))callback  {
    @synchronized(_lock) {
        _sequence++;
        CAWebSocketTransaction* tx = [[CAWebSocketTransaction alloc] init];
        tx.sequence = [NSString stringWithFormat:@"%d", _sequence];
        tx.expired = [[NSDate date] dateByAddingTimeInterval: request.timeout / 1000];
        tx.callback = callback;
        [_trans setObject: tx forKey: tx.sequence];
        
        NSLog(@">>> === REQUEST === \n%@\n>>> === REQUEST ===", [request description]);
        [request putHeader: [[NSUUID UUID] UUIDString] forName: CA_HEADER_NONCE];
        [request signWithSigner: self];
        [request putHeader: tx.sequence forName: CA_HEADER_SEQUENCE];
        NSString* json = [request buildJson];
        [self sendData: json];
    }
}

/**
 * end transaction with response
 */
-(void) endTransaction: (CACommonResponse*)response {
    NSLog(@"<<< === RESPONSE === \n%@\n<<< === RESPONSE ===", [response description]);
    CAWebSocketTransaction* tx;
    NSString* sequence = [response headerValueByName: CA_HEADER_SEQUENCE];
    @synchronized(_lock) {
        tx = [_trans objectForKey: sequence];
        if (tx != nil) {
            [_trans removeObjectForKey: sequence];
        } else {
            NSLog(@"transaction missing, sequence=%@", sequence);
            return;
        }
        
    }
    tx.callback(response);
}

/**
 * process register response
 */
-(void) registeredWithResponse: (CACommonResponse*)response {
    @synchronized(_lock) {
        if (response.error == nil && response.statusCode == 200) {
            NSLog(@"### CADuplexClient status=CA_CONNECTED register success");
            _status = CA_CONNECTED;
            if (_heartbeatThread == nil) {
                _heartbeatThread = [[NSThread alloc]initWithTarget:self selector:@selector(heartbeatProc:) object:nil];
                [_heartbeatThread start];
                _registerCallback(response);
            }
        } else {
            _status = CA_FAILED;
            NSLog(@"### CADuplexClient status=CA_FAILED register failed");
            [self closeWithReason: [response description]];
        }
    }
}

-(NSString *) getDeviceId{
    return _deviceId;
}


- (void)sendData:(id)data {
    if (_websocket != nil) {
        // 只有 SR_OPEN 开启状态才能调 send 方法啊，不然要崩
        if (_websocket.readyState == SR_OPEN) {
            [_websocket send:data];
            
        } else if (_websocket.readyState == SR_CONNECTING) {
            NSLog(@"connecting...");
            for(int i=2; i<10; i++) {
                [NSThread sleepForTimeInterval:1];
                if (_websocket.readyState == SR_OPEN) {
                    [_websocket send:data];
                    
                }
            }
        } else if (_websocket.readyState == SR_CLOSING || _websocket.readyState == SR_CLOSED) {
            // websocket 断开了，调用 connect 方法重连
            [self connect];
        }
    } else {
        [self connect];
        NSLog(@"no internet , send failed , reconecting...");
    }
    
}

@end
