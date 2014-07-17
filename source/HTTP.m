#import <HTTPKit/HTTPServer.h>
#import <HTTPKit/HTTPConnection.h>
#import "HTTPPrivate.h"
#import <CocoaOniguruma/OnigRegexp.h>

static NSString *HTTPSentinel = @" __HTTPSentinel__ ";

@protocol HTTPHandler <NSObject>
@property(readwrite, copy) HTTPHandlerBlock block;
@property(readwrite, strong) id route;
- (id)handleConnection:(HTTPConnection *)aConnection URL:(NSString *)URL;
@end

@interface HTTPHandler_String : NSObject <HTTPHandler>
@property(readwrite, strong) NSString *route;
@end

@implementation HTTPHandler_String
@synthesize block=_block;
- (id)handleConnection:(HTTPConnection *)aConnection URL:(NSString *)URL
{
    if([URL isEqualToString:_route])
        return self.block ? self.block(aConnection) : nil;
    return HTTPSentinel;
}
@end

@interface HTTPHandler_Regex : NSObject <HTTPHandler>
@property(readwrite, strong) OnigRegexp *route;
@end

@implementation HTTPHandler_Regex
@synthesize block=_block;
- (id)handleConnection:(HTTPConnection *)aConnection URL:(NSString *)URL
{
    OnigResult *result = [_route match:URL];
    if(result) {
        NSMutableArray *args = [[result strings] mutableCopy];
        [args replaceObjectAtIndex:0 withObject:aConnection];
        return CallBlockWithArguments(self.block, args);
    }
    return HTTPSentinel;
}
@end

@interface HTTPServer () {
    struct mg_context *_ctx;
    @public
    NSMutableArray *_GETHandlers, *_POSTHandlers, *_PUTHandlers, *_DELETEHandlers;
    HTTPHandlerBlock _webSocketHandler;
    HTTPAuthenticationBlock _authenticationHandler;
}
@end

static int _requestDidBegin(struct mg_connection * const aConnection)
{
    @autoreleasepool {
        const struct mg_request_info *requestInfo = mg_get_request_info(aConnection);
        HTTPServer *self = (__bridge id)requestInfo->user_data;
        HTTPConnection *connection = [HTTPConnection withMGConnection:aConnection server:self];
        
        @try {
            const char *method = requestInfo->request_method;
            NSString *url = [NSString stringWithUTF8String:requestInfo->uri];
            id result = HTTPSentinel;
            NSArray *handlers;
            if(strcmp(method, "GET") == 0)
                handlers = self->_GETHandlers;
            else if(strcmp(method, "POST") == 0)
                handlers = self->_POSTHandlers;
            else if(strcmp(method, "PUT") == 0)
                handlers = self->_PUTHandlers;
            else if(strcmp(method, "DELETE") == 0)
                handlers = self->_DELETEHandlers;
            else
                return 0;
            
            for(id<HTTPHandler> handler in handlers) {
                if((result = [handler handleConnection:connection
                                                   URL:url]) != HTTPSentinel) {
                    if(connection.isOpen) {
                        if([result isKindOfClass:[NSData class]])
                            [connection writeData:result];
                        else if(result)
                            [connection writeString:[result description]];
                    }
                    break;
                }
            }
            if(result != HTTPSentinel) {
                [connection _flushAndClose:!connection.isStreaming];
                return 1;
            }
            else
                return 0;
        } @catch(NSException *e) {
            HTTPConnection *errConn = [HTTPConnection withMGConnection:aConnection
                                                                server:self];
            errConn.status = 500;
            errConn.reason = @"Internal Server Error";
            [errConn writeFormat:@"Exception: %@", [e reason]];
            [connection _flushAndClose:YES];
            return 1;
        }
    }
}

static void _requestDidEnd(const struct mg_connection * const aConnection, int const aReplyStatusCode)
{
    @autoreleasepool {
        const struct mg_request_info *requestInfo = mg_get_request_info((struct mg_connection *)aConnection);
        HTTPServer *self = (__bridge id)requestInfo->user_data;
        HTTPConnection *connection = [HTTPConnection withMGConnection:(struct mg_connection *)aConnection
                                                               server:self];
        
        connection.isOpen      = NO;
        
    }
}

static int _websocketConnected(const struct mg_connection * const aConnection)
{

    const struct mg_request_info *requestInfo = mg_get_request_info((struct mg_connection *)aConnection);
    HTTPServer *self = (__bridge id)requestInfo->user_data;
    if(self->_webSocketHandler)
        return 0;
    else
        return 1; // Reject
}

static void _websocketReady(struct mg_connection * const aConnection)
{
    const char *reply = "server ready";
    mg_websocket_write(aConnection, WEBSOCKET_OPCODE_TEXT, reply, strlen(reply));
}

static int  _handleWebsocketData(struct mg_connection * const aConnection, int const aBits,
                                 char * const aData, size_t const aDataLen)
{
    @autoreleasepool {
        const struct mg_request_info *requestInfo = mg_get_request_info((struct mg_connection *)aConnection);
        HTTPServer *self = (__bridge id)requestInfo->user_data;
        HTTPWebSocketConnection *connection = [HTTPWebSocketConnection withMGWebSocketConnection:aConnection server:self
                                                                   messageBody:[NSData dataWithBytesNoCopy:aData
                                                                                                    length:aDataLen
                                                                                              freeWhenDone:NO]];
        if(self->_webSocketHandler) {
            id result;
            if((result = self->_webSocketHandler(connection)))
                [connection writeString:[result description]];
            if(connection.isOpen)
                return 1;
            
        }
        
        // If we got this far it means the connection needs to be closed
        connection.isOpen = NO;
        if(self->_webSocketHandler)
            self->_webSocketHandler(connection);
        return 0;
    }
}

static int _requestRequiresAuthentication(struct mg_connection * const aConnection)
{
    @autoreleasepool {
        const struct mg_request_info *requestInfo = mg_get_request_info((struct mg_connection *)aConnection);
        HTTPServer *self = (__bridge id)requestInfo->user_data;
        return self->_authenticationHandler != nil;
    }
}

static int _handleAuthRequest(struct mg_connection * const aConnection, const char * const aUser, const char *aPassword)
{
    @autoreleasepool {
        const struct mg_request_info *requestInfo = mg_get_request_info((struct mg_connection *)aConnection);
        HTTPServer *self = (__bridge id)requestInfo->user_data;
        HTTPAuthenticationBlock authBlock = self->_authenticationHandler;
        if(authBlock) {
            HTTPMethod const method =
                  strcmp(requestInfo->request_method, "GET"     ) == 0 ? kHTTPMethodGET
                : strcmp(requestInfo->request_method, "POST"    ) == 0 ? kHTTPMethodPOST
                : strcmp(requestInfo->request_method, "PUT"     ) == 0 ? kHTTPMethodPUT
                : strcmp(requestInfo->request_method, "DELETE"  ) == 0 ? kHTTPMethodDELETE
                : strcmp(requestInfo->request_method, "HEAD"    ) == 0 ? kHTTPMethodHEAD
                : strcmp(requestInfo->request_method, "CONNECT" ) == 0 ? kHTTPMethodCONNECT
                : strcmp(requestInfo->request_method, "PROPFIND") == 0 ? kHTTPMethodPROPFIND
                : strcmp(requestInfo->request_method, "MKCOL"   ) == 0 ? kHTTPMethodMKCOL
                : strcmp(requestInfo->request_method, "OPTIONS" ) == 0 ? kHTTPMethodOPTIONS
                :                                                        kHTTPInvalidMethod;
            
            return authBlock(method, [NSString stringWithUTF8String:aUser], [NSString stringWithUTF8String:aPassword]);
        } else
            return 0;
    }
}

static struct mg_callbacks _MongooseCallbacks = {
    .begin_request     = &_requestDidBegin,
    .end_request       = &_requestDidEnd,
    .websocket_connect = &_websocketConnected,
    .websocket_ready   = &_websocketReady,
    .websocket_data    = &_handleWebsocketData,
    .should_authorize_request = &_requestRequiresAuthentication,
    .authorize_request = &_handleAuthRequest
};

@implementation HTTPServer

+ (HTTPServer *)defaultServer
{
    static HTTPServer *DefaultServer;
    static dispatch_once_t OnceToken;
    dispatch_once(&OnceToken, ^{ DefaultServer = [HTTPServer new]; });
    return DefaultServer;
}

- (id)init
{
    if(!(self = [super init]))
        return nil;
    _GETHandlers  = [NSMutableArray new];
    _POSTHandlers = [NSMutableArray new];
    _enableKeepAlive = YES;
    _numberOfThreads = 30;

    return self;
}

- (BOOL)listenOnPort:(NSUInteger)aPort onError:(HTTPErrorBlock)aErrorHandler
{
    return [self listenOnPort:aPort authenticateWith:nil onError:aErrorHandler];
}
- (BOOL)listenOnPort:(NSUInteger)aPort
    authenticateWith:(HTTPAuthenticationBlock)aAuthBlock
             onError:(HTTPErrorBlock)aErrorHandler
{
    char threadStr[5], portStr[8];
    sprintf(portStr,   "%ld", (unsigned long)aPort);
    sprintf(threadStr, "%d",  _numberOfThreads);
    
    NSMutableString *mimeTypes = [NSMutableString new];
    for(NSString *extension in _extraMIMETypes) {
        [mimeTypes appendFormat:@".%@=%@,", extension, _extraMIMETypes[extension]];
    }
    
    _authenticationHandler = [aAuthBlock copy];
    
    const char *opts[] = {
        "listening_ports",          portStr,
        "enable_directory_listing", _enableDirListing ? "yes" : "no",
        "enable_keep_alive",        _enableKeepAlive ? "yes" : "no",
        "document_root",            [_publicDir UTF8String] ?: ".",
        "num_threads",              threadStr,
        "extra_mime_types",         [mimeTypes UTF8String],
        NULL
    };
    _ctx = mg_start(&_MongooseCallbacks, (__bridge void *)self, opts);
    if(!_ctx) {
        if(aErrorHandler)
            aErrorHandler(@"Unable to start server");
        return NO;
    }
    return YES;
}

- (void)dealloc
{
    if(_ctx)
        mg_stop(_ctx), _ctx = NULL;
}

- (id<HTTPHandler>)_handlerFromObject:(id)aObj handlerBlock:(id)aBlock
{
    NSParameterAssert([aBlock isKindOfClass:NSClassFromString(NSBlockClassName)]);
    NSParameterAssert([aObj isKindOfClass:[NSString class]] ||
                      [aObj isKindOfClass:[OnigRegexp class]]);

    id<HTTPHandler> handler;
    if([aObj isKindOfClass:[NSString class]]) {
        if([aObj rangeOfString:@"*"].location == NSNotFound) {
            handler = [HTTPHandler_String new];
            handler.route = aObj;
        } else {
            handler = [HTTPHandler_Regex new];
            // Convert the pattern to a regular expression
            if(![aObj hasSuffix:@"/"])
                aObj = [aObj stringByAppendingString:@"/?$"];
            else
                aObj = [aObj stringByAppendingString:@"$"];

            aObj = [aObj replaceAllByRegexp:@"\\*+" withBlock:^(OnigResult *r) {
                NSParameterAssert([r count] == 1 && [r.strings[0] length] <= 2);
                return [r.strings[0] length] == 2 ? @"((?:[^/]+/??)+)" : @"([^/]+)";
            }];
            NSError *err = nil;
            handler.route = [OnigRegexp compile:aObj error:&err];
            if(err) {
                [NSException raise:NSInvalidArgumentException
                            format:@"Couldn't compile Regex '%@'", aObj];
                return nil;
            }
        }
    } else {
        handler = [HTTPHandler_Regex new];
        handler.route = aObj;
    }
    handler.block = aBlock;
    return handler;
}
- (void)handleGET:(id)aRoute with:(id)aHandler
{
    [_GETHandlers addObject:[self _handlerFromObject:aRoute handlerBlock:aHandler]];
}
- (void)handlePOST:(id)aRoute with:(id)aHandler
{
    [_POSTHandlers addObject:[self _handlerFromObject:aRoute handlerBlock:aHandler]];
}
- (void)handlePUT:(id)aRoute with:(id)aHandler
{
    [_PUTHandlers addObject:[self _handlerFromObject:aRoute handlerBlock:aHandler]];
}
- (void)handleDELETE:(id)aRoute with:(id)aHandler
{
    [_DELETEHandlers addObject:[self _handlerFromObject:aRoute handlerBlock:aHandler]];
}
- (void)handleWebSocket:(id)aHandler
{
    _webSocketHandler = [aHandler copy];
}
@end
