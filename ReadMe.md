# HTTPKit

HTTPKit is a lightweight framework for building webservers in Objective-C or [Tranquil](http://github.com/fjolnir/tranquil).

## Basic usage

    #import <HTTPKit.h>
    
    int main(int argc, const char * argv[])
    {
        @autoreleasepool {
            HTTP *http = [HTTP new];
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
            [http listenOnPort:8081 onError:^(id reason) {
                fprintf(stderr, "Error starting server: %s", [reason UTF8String]);
                exit(1);
            }];
            [[NSRunLoop mainRunLoop] runUntilDate:[NSDate distantFuture]];
        }
        return 0;
    }
    
### Or written in tranquil as:

    import "HTTPKit"
    import "html"
    t = Tag
    HTTP new handleGET: "/hello/*" with: `conn, name| "Hello «name»!"`;
             handleGET: "/login" with: { conn |
                 t html: "Log in" :[
                     t :#form :[
                         t :#label :"Name:" :{ #for  => #username },
                         t :#input :nil     :{ #name => #username, #type => #text },
                         t :#label :"Password:" :{ #for  => #password },
                         t :#input :nil         :{ #name => #password, #type => #password },
                         t :#input :nil :{ #value => "Sign in", #type => #submit  }
                     ] :{ #method => #post }
                 ]
             };
            handlePOST: "/login" with: { conn |
                 "Logging in user: «conn requestBodyVar: #username» with password: «conn requestBodyVar: #password»" print
                 ^"Welcome! I trust you so I didn't even check your password."
            };
            listenOnPort: 8080 onError: { reason | "Error starting server: «reason»" print. ^^1 }
            
    NSRunLoop mainRunLoop runUntilDate: NSDate distantFuture
            
            
            
