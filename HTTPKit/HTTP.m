#import "HTTP.h"
#import "HTTPConnection.h"
#import "HTTPPrivate.h"
#import "OnigRegexp.h"

static NSString *HTTPSentinel = @" __HTTPSentinel__ ";

@protocol HTTPHandler <NSObject>
- (id)handleConnection:(HTTPConnection *)aConnection URL:(NSString *)URL;
@end

@interface HTTPHandler_Regex : NSObject <HTTPHandler>
@property(readwrite, copy) HTTPHandlerBlock block;
@property(readwrite, strong) OnigRegexp *regex;
@end

@implementation HTTPHandler_Regex
- (id)handleConnection:(HTTPConnection *)aConnection URL:(NSString *)URL
{
    OnigResult *result = [_regex match:URL];
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
    @autoreleasepool {
        const struct mg_request_info *requestInfo = mg_get_request_info(aConnection);
        HTTP *self = (__bridge id)requestInfo->user_data;
        HTTPConnection *connection = [HTTPConnection withMGConnection:aConnection
                                                               server:self];
        switch(aEvent) {
            case MG_NEW_REQUEST: @try {
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
            case MG_WEBSOCKET_CONNECT:
                if(self->_webSocketHandler)
                    return NULL;
                return ""; // Reject
            case MG_WEBSOCKET_READY: {
                unsigned char buf[40];
                buf[0] = 0x81;
                buf[1] = snprintf((char *) buf + 2, sizeof(buf) - 2, "%s", "server ready");
                mg_write(aConnection, buf, 2 + buf[1]);
                return ""; // Return value ignored
            }
            case MG_WEBSOCKET_MESSAGE:
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
            case MG_WEBSOCKET_CLOSE:
                connection.isWebSocket = YES;
                connection.isOpen      = NO;
                if(self->_webSocketHandler)
                    self->_webSocketHandler(connection);
                return ""; // Return value ignored
            case MG_HTTP_ERROR: {
    //            long replyStatus = (intptr_t)requestInfo->ev_data;
            } break;
            default:
                break;
        }
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

    return self;
}

- (BOOL)listenOnPort:(NSUInteger)port onError:(HTTPErrorBlock)aErrorHandler
{
    const char *opts[] = {
        "listening_ports", [[NSString stringWithFormat:@"%ld", (long)port] UTF8String],
        "enable_directory_listing", _dirListingEnabled ? "yes" : "no",
        "document_root", [_publicDir UTF8String] ?: ".",
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

    HTTPHandler_Regex *handler = [HTTPHandler_Regex new];
    if([aObj isKindOfClass:[NSString class]]) {
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
        handler.regex = [OnigRegexp compile:aObj error:&err];
        if(err) {
            [NSException raise:NSInvalidArgumentException
                        format:@"Couldn't compile Regex '%@'", aObj];
            return nil;
        }
    } else
        handler.regex = aObj;
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
