/*
 * Copyright (C) 2016-2018 Alibaba Group Holding Limited
 */
#import <Foundation/Foundation.h>
#import <SocketRocket/SRWebSocket.h>
#import "CAClient.h"

static NSString* const CA_HEADER_SEQUENCE = @"x-ca-seq";
static NSString* const CA_HEADER_DEVICE_ID = @"x-ca-deviceid";
static NSString* const CA_HEADER_WEBSOCKET_API_TYPE = @"x-ca-websocket_api_type";
static NSString* const CA_WEBSOCKET_API_TYPE_REGISTER = @"REGISTER";
static NSString* const CA_WEBSOCKET_API_TYPE_UNREGISTER = @"UNREGISTER";
static NSString* const CA_WEBSOCKET_API_TYPE_NOTIFY = @"NOTIFY";

static NSString* const CA_DUPLEX_COMMAND_HEARTBEAT_REQUEST = @"H1";
static NSString* const CA_DUPLEX_COMMAND_HEARTBEAT_RESPONSE = @"HO";
static NSString* const CA_DUPLEX_COMMAND_REGISTER_REQUEST = @"RG";
static NSString* const CA_DUPLEX_COMMAND_REGISTER_SUCCESS_RESPONSE = @"RO";
static NSString* const CA_DUPLEX_COMMAND_REGISER_FAIL_REQUEST = @"RF";
static NSString* const CA_DUPLEX_COMMAND_NOTIFY_REQUEST = @"NF";
static NSString* const CA_DUPLEX_COMMAND_NOTIFY_RESPONSE = @"NO";
static NSString* const CA_DUPLEX_COMMAND_OVERFLOWCONTROL = @"OS";
static NSString* const CA_DUPLEX_COMMAND_CONNECTION_RUNS_OUT = @"CR";

typedef NS_ENUM(NSUInteger, CADuplexClientStatus) {
    CA_INITIAL = 0,
    CA_CONNECTING = 1,
    CA_REGISTERING_SHORT = 2,       // SEND @"RO"
    CA_REGISTERING_LONG = 3,        // SEND Request
    CA_CONNECTED = 4,
    CA_CONNECTION_BROKEN = 5,
    CA_CONNECTION_EXPIRED = 6,
    CA_UNREGISTERING = 7,
    CA_FAILED = 8,
    CA_CLOSED = 9,
};

@interface CAWebSocketTransaction: NSObject {
    NSDate *expired;
    NSString* sequence;
    void (^callback)(CACommonResponse*);
}
@property NSDate* expired;
@property NSString* sequence;
@property void (^callback)(CACommonResponse*);
@end

@interface CADuplexClient: CAClient <SRWebSocketDelegate> {
    int _port;
    NSURL* _url;
    NSString* _host;
    
    NSString* _deviceId;
    CACommonRequest *_registerRequest;
    void (^_registerCallback)(CACommonResponse*);

    CADuplexClientStatus _status;
    NSMutableDictionary* _trans;

    int _sequence;
    NSDate* _heartbeatExpired;
    NSString* _sessionCredential;
    SRWebSocket* _websocket;
    NSLock* _lock;
    
    int _heartbeatTimeout;
    NSThread* _heartbeatThread;
    
    void (^_notifyHandler)(NSString*);
    void (^_connectionBrokenHandler)(NSString*);
}

@property (nonatomic) NSString* deviceId;
@property (nonatomic, readonly) int port;
@property (nonatomic, readonly) NSString* host;
@property (nonatomic, readonly) CADuplexClientStatus status;

/**
 * trigger when connection borken. with message
 */
@property (nonatomic) void (^connectionBrokenHandler)(NSString*);
/**
 * trigger when receive notify from websocket.
 */
@property (nonatomic) void (^notifyHandler)(NSString*);

/**
 * init duplex client with host
 */
-(instancetype) initWithHost: (NSString*)host;


-(void) setAppKeyAndAppSecret:(NSString*)appKey
                    appSecret:(NSString*) appSecret;

/**
 * open websocket and register with request:
 * - if success callback with register response
 * - if failed callback with response(error != nil)
 */
-(void) registerWithRequest: (CACommonRequest*)request
               withCallback: (void (^)(CACommonResponse*))callback;

/**
 * unregister with request and close websocket:
 * - if success callback with unregister response, and status will be CA_CLOSED
 * - if failed callback with response(error != nil), and status will be CA_FAILED
 */
-(void) unregisterWithRequest: (CACommonRequest*)request
                 withCallback: (void (^)(CACommonResponse*))callback;

/**
 * invoke with request, via websocket
 * same usage with CAClient invokeWithRequest.
 */
-(void) invokeWithRequest: (CACommonRequest *)request
             withCallback: (void (^)(CACommonResponse*))callback;

-(NSString *) getDeviceId;
@end
