#import <Foundation/Foundation.h>

@class HTTPConnection;
#define HTTP [HTTPServer defaultServer]

typedef enum {
    kHTTPInvalidMethod,
    kHTTPMethodGET,
    kHTTPMethodPOST,
    kHTTPMethodPUT,
    kHTTPMethodDELETE,
    kHTTPMethodHEAD,
    kHTTPMethodCONNECT,
    kHTTPMethodPROPFIND,
    kHTTPMethodMKCOL,
    kHTTPMethodOPTIONS
} HTTPMethod;

typedef BOOL (^HTTPAuthenticationBlock)(HTTPMethod method, NSString *username, NSString *password);
typedef void (^HTTPErrorBlock)(id reason);
typedef id (^HTTPHandlerBlock)(HTTPConnection *, ...);

@interface HTTPServer : NSObject
@property(readwrite, strong) NSString *publicDir;
@property(readwrite, assign) BOOL enableDirListing, enableKeepAlive;
@property(readwrite, assign) unsigned int numberOfThreads;
@property(readwrite, copy)   NSDictionary *extraMIMETypes;

+ (HTTPServer *)defaultServer;

- (BOOL)listenOnPort:(NSUInteger)port onError:(HTTPErrorBlock)aErrorHandler;
- (BOOL)listenOnPort:(NSUInteger)port
    authenticateWith:(HTTPAuthenticationBlock)aAuthBlock
             onError:(HTTPErrorBlock)aErrorHandler;

- (void)handleGET:(id)aRoute    with:(id)aHandler;
- (void)handlePOST:(id)aRoute   with:(id)aHandler;
- (void)handlePUT:(id)aRoute    with:(id)aHandler;
- (void)handleDELETE:(id)aRoute with:(id)aHandler;
- (void)handleWebSocket:(id)aHandler;
@end
