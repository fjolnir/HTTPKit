#import "HTTP.h"
#import "HTTPConnection.h"
#import "HTTPPrivate.h"
#import "OnigRegexp.h"

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
        return [self.block call:aConnection];
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
        return [self.block callWithArguments:args];
    }
    return HTTPSentinel;
}
@end

@interface HTTP () {
    struct mg_context *_ctx;
    @public
    NSMutableArray *_GETHandlers, *_POSTHandlers, *_PUTHandlers, *_DELETEHandlers;
    HTTPHandlerBlock _webSocketHandler;
}
@end

static void *mongooseCallback(enum mg_event aEvent, struct mg_connection *aConnection)
{
    // This macro is to avoid allocating a connection when the event doesn't require it
    #define InitReqInfo() \
        const struct mg_request_info *requestInfo = mg_get_request_info(aConnection); \
        HTTP *self = (__bridge id)requestInfo->user_data
    #define InitConnection() \
        HTTPConnection *connection = [HTTPConnection withMGConnection:aConnection \
                                                               server:self]
        switch(aEvent) {
            case MG_NEW_REQUEST: @autoreleasepool {
                InitReqInfo();
                InitConnection();
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
                        [NSException raise:NSInternalInconsistencyException
                                    format:@"Unhandled request type: '%s'", method];
                    for(id<HTTPHandler> handler in handlers) {
                        if((result = [handler handleConnection:connection
                                                           URL:url]) != HTTPSentinel) {
                            [connection writeString:[result description]];
                            break;
                        }
                    }
                    return result == HTTPSentinel ? NULL : [connection _writeResponse];
                } @catch(NSException *e) {
                    HTTPConnection *errConn = [HTTPConnection withMGConnection:aConnection
                                                                        server:self];
                    errConn.status = 500;
                    errConn.reason = @"Internal Server Error";
                    [errConn writeFormat:@"Exception: %@", [e reason]];
                    return [errConn _writeResponse];
                }
            }
            case MG_WEBSOCKET_CONNECT: {
                InitReqInfo();
                if(self->_webSocketHandler)
                    return NULL;
                return ""; // Reject
            } case MG_WEBSOCKET_READY: {
                unsigned char buf[40];
                buf[0] = 0x81;
                buf[1] = snprintf((char *) buf + 2, sizeof(buf) - 2, "%s", "server ready");
                mg_write(aConnection, buf, 2 + buf[1]);
                return ""; // Return value ignored
            }
            case MG_WEBSOCKET_MESSAGE: @autoreleasepool {
                InitReqInfo();
                InitConnection();
                connection.isWebSocket = YES;
                if(self->_webSocketHandler) {
                    id result;
                    if((result = self->_webSocketHandler(connection))) {
                        if(!connection.isOpen)
                            return ""; // Close
                        if(result) {
                            [connection writeString:[result description]];
                            return [connection _writeWebSocketReply];
                        }
                        return NULL;
                    }
                    return "";
                }
                break;
            } case MG_WEBSOCKET_CLOSE: @autoreleasepool {
                InitReqInfo();
                InitConnection();
                connection.isWebSocket = YES;
                connection.isOpen      = NO;
                if(self->_webSocketHandler)
                    self->_webSocketHandler(connection);
                return ""; // Return value ignored
            } break;
            default:
                break;
        }
    return NULL;
}

@implementation HTTP

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

- (BOOL)listenOnPort:(NSUInteger)port onError:(HTTPErrorBlock)aErrorHandler
{
    char threadStr[5], portStr[8];
    sprintf(portStr,   "%ld", (unsigned long)port);
    sprintf(threadStr, "%d",  _numberOfThreads);
    const char *opts[] = {
        "listening_ports",          portStr,
        "enable_directory_listing", _enableDirListing ? "yes" : "no",
        "enable_keep_alive",        _enableKeepAlive ? "yes" : "no",
        "document_root",            [_publicDir UTF8String] ?: ".",
        "num_threads",              threadStr,
        NULL
    };
    _ctx = mg_start(mongooseCallback, (__bridge void *)self, opts);
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
        mg_stop(_ctx);
}

- (id<HTTPHandler>)_handlerFromObject:(id)aObj handlerBlock:(id)aBlock
{
    NSParameterAssert([aBlock isKindOfClass:[NSBlock class]]);
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
