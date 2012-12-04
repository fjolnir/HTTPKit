#import <Foundation/Foundation.h>

@class HTTP;

typedef enum {
    kHTTPMethodGET,
    kHTTPMethodPOST,
    kHTTPMethodPUT,
    kHTTPMethodDELETE
} HTTPMethod;

@interface HTTPConnection : NSObject
@property(readwrite, assign) int status;
@property(readwrite, strong) NSString *reason;
@property(readwrite, weak) HTTP *server;
@property(readonly, strong) NSDictionary *headers;
@property(readonly, strong) NSDictionary *requestMultipartSegments;
@property(readonly, strong, nonatomic) NSData *requestBodyData;
@property(readonly, strong) NSString *requestBody, *httpAuthUser;
@property(readonly, strong) NSData *queryString;
@property(readonly, strong) NSURL *url;
@property(readonly) long requestLength, remoteIp, remotePort;
@property(readonly) BOOL requestIsMultipart, isWebSocket, isOpen, isSSL;

- (NSNumber *)writeData:(NSData *)aData;
- (NSNumber *)writeString:(NSString *)aString;
- (NSNumber *)writeFormat:(NSString *)aFormat, ...;

- (NSString *)getCookie:(NSString *)aName;
- (void)setCookie:(NSString *)aName
               to:(NSString *)aValue
   withAttributes:(NSDictionary *)aAttrs;
- (void)setCookie:(NSString *)aName
               to:(NSString *)aValue;
- (void)setCookie:(NSString *)aName
               to:(NSString *)aValue
          expires:(NSDate *)aExpiryDate;

- (NSString *)requestBodyVar:(NSString *)aName;
- (NSString *)requestQueryVar:(NSString *)aName;

- (NSString *)requestHeader:(NSString *)aName;
- (void)setResponseHeader:(NSString *)aHeader to:(NSString *)aValue;

- (void)close;
@end
