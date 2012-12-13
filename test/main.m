#import <Foundation/Foundation.h>
#import "HTTP.h"

int main(int argc, const char * argv[])
{
    @autoreleasepool {
        HTTP *http = [HTTP new];
        http.enableDirListing = YES;
        [http handleGET:@"/users/**/*"
                   with:^(HTTPConnection *connection, NSString *path, NSString *name) {
            return [NSString stringWithFormat:@"Hello %@ - %@!", path, name];
        }];

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

        [http listenOnPort:8081 onError:^(id reason) {
            NSLog(@"Error: %@", reason);
        }];

        [[NSRunLoop mainRunLoop] runUntilDate:[NSDate distantFuture]];
    }
    return 0;
}

