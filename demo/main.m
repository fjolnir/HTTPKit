#import <Foundation/Foundation.h>
#import <HTTPKit/HTTP.h>
#import <dispatch/dispatch.h>

int main(int argc, const char * argv[])
{
    @autoreleasepool {
        HTTP *http = [HTTP new];
        http.enableDirListing = YES;
        // Simple "Hello you!" pong
        [http handleGET:@"/hello/*"
                   with:^(HTTPConnection *connection, NSString *name) {
                       return [NSString stringWithFormat:@"Hello %@!", name];
                  }];

        // Simplified login example
        [http handleGET:@"/login"
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

        [http handlePOST:@"/login" with:^id (HTTPConnection *connection) {
            NSLog(@"logging in user: %@ with password: %@",
                  [connection requestBodyVar:@"username"],
                  [connection requestBodyVar:@"password"]);
            return @"Welcome! I trust you so I didn't even check your password.";
        }];

        // SSE
        [http handleGET:@"/sse" with:^id (HTTPConnection *connection) {
            return
            @"<script type=\"text/javascript\">"
                @"var source = new EventSource('/sse_events');"
                @"source.addEventListener('message', function(e) {"
                    @"console.log('Got message: ' + e.data);"
                @"}, false);"
            @"</script>";
        }];
        
        [http handleGET:@"/sse_events" with:^id (HTTPConnection *connection) {
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
        [http handleWebSocket:^id (HTTPConnection *connection) {
            if(!connection.isOpen) {
                NSLog(@"Socket closed");
                return nil;
            }
            NSLog(@"WebSocket message '%@' from %ld", connection.requestBody, connection.remoteIp);
            if([connection.requestBody isEqual:@"exit"])
                [connection close];
            return [connection.requestBody capitalizedString];
        }];

        [http listenOnPort:8081 onError:^(id reason) {
            NSLog(@"Error starting server: %@", reason);
            exit(1);
        }];
        dispatch_main();
    }
    return 0;
}
