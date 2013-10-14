#import <mongoose/mongoose.h>
#import <HTTPKit/HTTPConnection.h>
#import <HTTPKit/HTTPWebSocketConnection.h>
#import <HTTPKit/NSBlockUtilities.h>
#import <FABatching/FABatching.h>

@interface HTTPConnection () {
    @protected
    struct mg_connection *_mgConnection;
    NSMutableData *_responseData;
    BOOL _wroteHeaders;
    
    NSData *_requestBodyData;
    long _requestLength;
    NSMutableDictionary *_cookiesToWrite, *_responseHeaders, *_requestMultipartSegments;
    FA_BATCH_IVARS
}
@property(readwrite, assign) struct mg_connection *mgConnection;
@property(readwrite, assign) struct mg_request_info *mgRequest;
@property(readwrite, strong, nonatomic) NSData *requestBodyData;
@property(readwrite, assign) BOOL isWebSocket, isOpen;
+ (instancetype)withMGConnection:(struct mg_connection *)aConn server:(HTTPServer *)aServer;
- (NSInteger)_flushAndClose:(BOOL)aShouldClose;
- (NSString *)_getVar:(NSString *)aName inBuffer:(const void *)aBuf length:(long)aLen;
@end

@interface HTTPWebSocketConnection ()
+ (instancetype)withMGWebSocketConnection:(struct mg_connection *)aConn
                                       server:(HTTPServer *)aServer
                                  messageBody:(NSData *)aMsg;
@end
