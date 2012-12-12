#import "mongoose.h"
#import "HTTPConnection.h"
#import "NSBlock+TranquilCompatibility.h"

@interface HTTPConnection ()
@property(readwrite, assign) struct mg_connection *mgConnection;
@property(readwrite, assign) struct mg_request_info *mgRequest;
@property(readwrite, strong, nonatomic) NSData *requestBodyData;
@property(readwrite, assign) BOOL isWebSocket, isOpen;
+ (HTTPConnection *)withMGConnection:(struct mg_connection *)aConn server:(HTTP *)aServer;
- (void *)_writeResponse;
- (void *)_writeWebSocketReply;
@end
