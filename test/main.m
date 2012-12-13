#import <Foundation/Foundation.h>
#import "HTTP.h"

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
                   with:^(HTTPConnection *connection) {
                       return @"<form method=\"post\" action=\"/login\">"
                       @"<label for=\"username\">Name:</label>"
                       @"<input name=\"username\" type=\"text\">"
                       @"<label for=\"password\">Password:</label>"
                       @"<input name=\"password\" type=\"password\">"
                       @"<input type=\"submit\" value=\"Sign in\">"
                       @"</form>";
                   }];
        
        [http handlePOST:@"/login" with:^(HTTPConnection *connection) {
            NSLog(@"logging in user: %@ with password: %@",
                  [connection requestBodyVar:@"username"],
                  [connection requestBodyVar:@"password"]);
            return @"Welcome! I trust you so I didn't even check your password.";
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
            fprintf(stderr, "Error starting server: %s", [reason UTF8String]);
            exit(1);
        }];
        [[NSRunLoop mainRunLoop] runUntilDate:[NSDate distantFuture]];
    }
    return 0;
}
