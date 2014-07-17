#import <Foundation/Foundation.h>
#import <HTTPKit/HTTPServer.h>
#import <dispatch/dispatch.h>
#include <unistd.h>

int main(int argc, const char * argv[])
{
    @autoreleasepool {
        HTTP.enableDirListing = YES;
        HTTP.extraMIMETypes = @{ @"json": @"application/json" };
        
        // Simple "Hello you!" pong
        [HTTP handleGET:@"/hello/*"
                   with:^(HTTPConnection *connection, NSString *name) {
                       return [NSString stringWithFormat:@"Hello %@!", name];
                  }];

        // Simplified login example
        [HTTP handleGET:@"/login"
                   with:^id (HTTPConnection *connection) {
                       return
                       @"<form method=\"post\" action=\"/login\">"
                           @"<label for=\"username\">Name:</label>"
                           @"<input name=\"username\" type=\"text\">"
                           @"<label for=\"password\">Password:</label>"
                           @"<input name=\"password\" type=\"password\">"
                           @"<input type=\"submit\" value=\"Sign in\">"
                       @"</form>";
                   }];

        [HTTP handlePOST:@"/login" with:^id (HTTPConnection *connection) {
            NSLog(@"logging in user: %@ with password: %@",
                  [connection requestBodyVar:@"username"],
                  [connection requestBodyVar:@"password"]);
            return @"Welcome! I trust you so I didn't even check your password.";
        }];

        // SSE
        [HTTP handleGET:@"/sse" with:^id (HTTPConnection *connection) {
            return
            @"<script type=\"text/javascript\">"
                @"var source = new EventSource('/sse_events');"
                @"source.addEventListener('message', function(e) {"
                    @"console.log('Got message: ' + e.data);"
                @"}, false);"
            @"</script>";
        }];
        
        [HTTP handleGET:@"/sse_events" with:^id (HTTPConnection *connection) {
            [connection makeStreaming];
            [connection setResponseHeader:@"Content-Type" to:@"text/event-stream"];
            
            NSString *lastId = [connection requestHeader:@"Last-Event-ID"];
            if(lastId)
                NSLog(@"Welcome back %@", lastId); // Probably lost the connection, pick up where it left off?
            
            while(connection.isOpen) {
                [connection writeString:@"id: foo\n"
                                        @"data: Hey!\n\n"];
                usleep(USEC_PER_SEC*0.5);
            }
         
            return nil;
        }];
        
        // WebSocket
        [HTTP handleWebSocket:^id (HTTPConnection *connection) {
            if(!connection.isOpen) {
                NSLog(@"Socket closed");
                return nil;
            }
            NSLog(@"WebSocket message '%@' from %ld", connection.requestBody, connection.remoteIp);
            if([connection.requestBody isEqual:@"exit"])
                [connection close];
            return [connection.requestBody capitalizedString];
        }];
        
        // Reverse proxy
        [HTTP handleGET:@"/proxy/**" with:^id (HTTPConnection *connection, NSArray *path) {
            NSString *forwardURLStr = [NSMutableString stringWithFormat:@"http://apple.com/%@", path];
            NSURL *forwardURL = [NSURL URLWithString:forwardURLStr];
            NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:forwardURL];
            
            NSHTTPURLResponse *response;
            NSData *responseData = [NSURLConnection sendSynchronousRequest:req
                                                         returningResponse:&response
                                                                     error:nil];
            
            connection.shouldWriteHeaders = NO;
            NSDictionary *headers = [response allHeaderFields];
            [connection writeFormat:@"HTTP/1.1 %lu OK\r\n", [response statusCode]];
            for(NSString *header in headers) {
                if(![header isEqualToString:@"Content-Encoding"]
                   && ![header isEqualToString:@"Content-Length"])
                [connection writeFormat:@"%@: %@\r\n", header, headers[header]];
            }
            [connection writeFormat:@"Content-Length: %lu\r\n\r\n", [responseData length]];
            [connection writeData:responseData];
            return nil;
        }];

#ifdef __APPLE__ // These use functionality not in Foundation Lite yet
        // Reverse proxy
        [HTTP handleGET:@"/proxy/**" with:^id (HTTPConnection *connection, NSArray *path) {
            NSString *forwardURLStr = [NSMutableString stringWithFormat:@"http://apple.com/%@", path];
            NSURL *forwardURL = [NSURL URLWithString:forwardURLStr];
            NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:forwardURL];
            
            NSHTTPURLResponse *response;
            NSData *responseData = [NSURLConnection sendSynchronousRequest:req
                                                         returningResponse:&response
                                                                     error:nil];
            
            connection.shouldWriteHeaders = NO;
            NSDictionary *headers = [response allHeaderFields];
            [connection writeFormat:@"HTTP/1.1 %lu OK\r\n", [response statusCode]];
            for(NSString *header in headers) {
                if(![header isEqualToString:@"Content-Encoding"]
                   && ![header isEqualToString:@"Content-Length"])
                [connection writeFormat:@"%@: %@\r\n", header, headers[header]];
            }
            [connection writeFormat:@"Content-Length: %lu\r\n\r\n", [responseData length]];
            [connection writeData:responseData];
            return nil;
        }];
        
        [HTTP handleGET:@"/file.json"
                   with:^id (HTTPConnection *connection) {
            [@"{ 'foo': 'bar' }" writeToFile:@"/tmp/test.json"
                                  atomically:YES
                                    encoding:NSUTF8StringEncoding
                                       error:nil];
            [connection serveFileAtPath:@"/tmp/test.json"];
            return nil;
        }];
#endif

        [HTTP listenOnPort:8081
         authenticateWith:^BOOL(HTTPMethod method, NSString *username, NSString *password) {
             return YES;
         }
                   onError:^(id reason) {
            NSLog(@"Error starting server: %@", reason);
            exit(1);
        }];
        dispatch_main();
    }
    return 0;
}
