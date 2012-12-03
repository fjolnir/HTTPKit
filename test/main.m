#import <Foundation/Foundation.h>
#import "HTTP.h"

int main(int argc, const char * argv[])
{
    @autoreleasepool {
        HTTP *http = [HTTP new];
        [http handleGET:@"/users/**/*"
                   with:^(HTTPConnection *connection, NSString *path, NSString *name) {
            return [NSString stringWithFormat:@"Hello %@ - %@!", path, name];
        }];
        [http handleGET:@"/form"
                   with:^(HTTPConnection *connection) {
           return @"<form action=\"/post\" method=\"POST\">\n"
                   @"<input name=\"heyo\"/>\n"
                   @"</form>";
        }];
        [http handlePOST:@"/post" with:^(HTTPConnection *connection) {
            NSLog(@"%@", connection.requestMultipartSegments);
            return connection.requestMultipartSegments[@"heyo"][@"value"];
        }];
        [http listenOnPort:8081 onError:^(id reason) {
            NSLog(@"Error: %@", reason);
        }];
        [[NSRunLoop mainRunLoop] runUntilDate:[NSDate distantFuture]];
    }
    return 0;
}

