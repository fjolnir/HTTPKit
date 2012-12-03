#import "HTTPConnection.h"
#import "HTTPPrivate.h"
#import "HTTP.h"
#import "OnigRegexp.h"

@interface HTTPConnection () {
    NSMutableData *_responseData;
    NSData *_requestBody;
    long _requestLength;
    NSMutableDictionary *_cookiesToWrite, *_responseHeaders, *_requestMultipartSegments;
}
- (NSString *)_getVar:(NSString *)aName inBuffer:(const void *)aBuf length:(long)aLen;
@end

@implementation HTTPConnection
+ (HTTPConnection *)withMGConnection:(struct mg_connection *)aConn server:(HTTP *)aServer
{
    HTTPConnection *ret = [self new];
    ret.mgConnection = aConn;
    struct mg_request_info *req = mg_get_request_info(aConn);
    ret.mgRequest    = req;
    ret.server = aServer;

//    const char *h;
//    if((h = mg_get_header(aConn, "Content-Type")))
//        ret->_responseHeaders[@"Content-Type"] = [NSString stringWithUTF8String:h];
    return ret;
}

- (id)init
{
    if(!(self = [super init]))
        return nil;
    _status = 200;
    _reason = @"OK";
    _responseData = [NSMutableData new];
    _requestLength = -1;
    _cookiesToWrite = [NSMutableDictionary new];
    _responseHeaders = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                 @"text/html", @"Content-Type", nil];
    return self;
}

- (NSString *)_cookieHeader
{
    if(![_cookiesToWrite count])
        return nil;

    NSMutableString *header = [NSMutableString new];
    for(NSString *name in _cookiesToWrite) {
        NSDictionary *cookie = _cookiesToWrite[name];
        [header appendString:@"Set-Cookie: "];
        [header appendString:name];
        [header appendString:@"="];
        [header appendString:cookie[@"value"]];
        NSDictionary *attribs = cookie[@"attributes"];
        for(NSString *attrName in attribs) {
            [header appendString:@"; "];
            [header appendString:attrName];
            [header appendString:@"="];
            [header appendString:[attribs[attrName] description]];
        }
    }
    [header appendString:@"\r\n"];
    return header;
}

- (void *)_writeResponse
{
    NSMutableString *headerStr = [NSMutableString stringWithFormat:
                                  @"HTTP/1.1 %d %@\r\n"
                                  @"Content-Length: %ld\r\n",
                                  _status, _reason, (long)[_responseData length]];
    for(NSString *header in _responseHeaders) {
        [headerStr appendString:header];
        [headerStr appendString:@": "];
        [headerStr appendString:_responseHeaders[header]];
        [headerStr appendString:@"\r\n"];
    }
    NSString *cookieStr = [self _cookieHeader];
    if(cookieStr)
        [headerStr appendString:cookieStr];
    [headerStr appendString:@"\r\n"];
    const char *bytes = [headerStr UTF8String];
    mg_write(_mgConnection, bytes, strlen(bytes));
    mg_write(_mgConnection, [_responseData bytes], [_responseData length]);
    return "";
}

- (NSNumber *)writeData:(NSData *)aData
{
    [_responseData appendData:aData];
    return @([aData length]);
//    int bytesWritten = mg_write(_mgConnection, [aData bytes], [data length]);
    //return @(bytesWritten);
}

- (NSNumber *)writeString:(NSString *)aString
{
    return [self writeData:[aString dataUsingEncoding:NSUTF8StringEncoding]];
}
- (NSNumber *)writeFormat:(NSString *)aFormat, ...
{
    va_list args;
    va_start(args, aFormat);
    NSString *str = [[NSString alloc] initWithFormat:aFormat arguments:args];
    va_end(args);
    return [self writeString:str];
}

#pragma mark -

- (NSString *)getCookie:(NSString *)aName
{
    char buf[1024];
    if(mg_get_cookie(_mgConnection, [aName UTF8String], buf, 1024) > 0)
        return [NSString stringWithUTF8String:buf];
    return nil;
}

- (void)setCookie:(NSString *)aName
               to:(NSString *)aValue
   withAttributes:(NSDictionary *)aAttrs
{
    NSParameterAssert(aName && aValue);
    _cookiesToWrite[aName] = @{ @"value": aValue, @"attributes": aAttrs ?: @{} };
}

- (void)setCookie:(NSString *)aName
               to:(NSString *)aValue
          expires:(NSDate *)aExpiryDate
{
    time_t time = [aExpiryDate timeIntervalSince1970];
    struct tm timeStruct;
    localtime_r(&time, &timeStruct);
    char buffer[80];
    strftime(buffer, 80, "%a, %d-%b-%Y %H:%M:%S GMT", &timeStruct);
    NSString *dateStr = [NSString stringWithCString:buffer encoding:NSASCIIStringEncoding];
    [self setCookie:aName to:aValue withAttributes:@{ @"Expires": dateStr } ];
}

- (long)requestLength
{
    if(_requestLength != -1)
        return _requestLength;
    const char *lenHeader = mg_get_header(_mgConnection, "Content-Length");
    if(lenHeader)
        _requestLength = atol(lenHeader);
    return _requestLength;
}

- (NSString *)queryString
{
    const char *str = _mgRequest->query_string;
    if(str)
        return [NSString stringWithUTF8String:str];
    return nil;
}

- (BOOL)requestIsMultipart
{
    const char *contentHeader = mg_get_header(_mgConnection, "Content-Type");
    if(contentHeader && strstr(contentHeader, "multipart/form-data") == contentHeader)
        return YES;
    return NO;
}

- (NSData *)requestBody
{
    if(!_requestBody) {
        long len = self.requestLength;
        if([self requestIsMultipart] || len == -1)
            return nil;

        NSMutableData *data = [NSMutableData dataWithLength:len];
        mg_read(_mgConnection, [data mutableBytes], [data length]);
        _requestBody = data;
    }
    return _requestBody;
}

- (NSDictionary *)requestMultipartSegments
{
    if(_requestMultipartSegments)
        return _requestMultipartSegments;
    if(![self requestIsMultipart])
        return nil;
    _requestMultipartSegments = [NSMutableDictionary new];
    
    // We need to deal with the different parts
    const char *contentHeader = mg_get_header(_mgConnection, "Content-Type");
    char boundary[100] = {0};
    int found = sscanf(contentHeader, "multipart/form-data; boundary=%99s", boundary);
    if(!found)
        [NSException raise:NSInternalInconsistencyException
                    format:@"Invalid request: no multipart boundary"];

    size_t boundaryLen = strlen(boundary);
    const int bufSize = 10*1024;
    char *buf = malloc(bufSize);
    mg_read(_mgConnection, buf, 2); // \r\n
    FILE *handle;
    NSMutableDictionary *currSeg = nil;
    char scanBuf[1024], nameFieldBuf[11];
    int bytesRead, ofs, startOfs;
    while((bytesRead = mg_read(_mgConnection, buf, bufSize))) {
        ofs = 0;
        if(!currSeg) {
        newSegment:
            ofs += boundaryLen + 2; // Skip over the boundary & \r\n

            // Create a temp file to write to
            handle = tmpfile();
            assert(handle);
            currSeg = [@{
                @"handle": [[NSFileHandle alloc] initWithFileDescriptor:fileno(handle)
                                                         closeOnDealloc:YES]
            } mutableCopy];

            // Read name/filename from content-disposition header
            nameFieldBuf[0] = '\0';
            sscanf(buf+ofs, "Content-Disposition: form-data; %10[^=]=\"%1023[^\"]",
                   nameFieldBuf, scanBuf);
            if(strcmp(nameFieldBuf, "name") == 0)
                currSeg[@"name"] = [NSString stringWithUTF8String:scanBuf];
            else if(strcmp(nameFieldBuf, "filename") == 0)
                currSeg[@"filename"] = [NSString stringWithUTF8String:scanBuf];
            else
                [NSException raise:NSInternalInconsistencyException
                            format:@"Invalid content disposition"];
            ofs += 35 + strlen(nameFieldBuf) + strlen(scanBuf);

            nameFieldBuf[0] = '\0';
            sscanf(buf+ofs, "; %10[^=]=\"%1023[^\"]", nameFieldBuf, scanBuf);
            if(strcmp(nameFieldBuf, "name") == 0)
                currSeg[@"name"] = [NSString stringWithUTF8String:scanBuf];
            else if(strcmp(nameFieldBuf, "filename") == 0)
                currSeg[@"filename"] = [NSString stringWithUTF8String:scanBuf];
            if(strlen(nameFieldBuf) > 0)
                ofs += 5 + strlen(nameFieldBuf) + strlen(scanBuf);
            ofs += 2; // \r\n

            NSAssert(currSeg[@"name"], @"Malformed request");
            _requestMultipartSegments[currSeg[@"name"]] = currSeg;

            // Read Content-Type header
            scanBuf[0] = '\0';
            sscanf(buf+ofs, "Content-Type: %1023s", scanBuf);
            if(strlen(scanBuf))
                currSeg[@"contentType"] = [NSString stringWithUTF8String:scanBuf];

            // Seek past any other headers (\r\n\r\n)
            do {
                ofs += 1;
            } while(ofs < (bytesRead-4) && strncmp(buf+ofs, "\r\n\r\n", 4));
            if(ofs >= bufSize-4)
                [NSException raise:NSInternalInconsistencyException
                            format:@"Malformed request"];
            ofs += 4;
        }
        startOfs = ofs;

        // Read segment contents
        // We read the file, looking for \r\n, when one is encountered,
        // we backtrack by the length of the boundary, and compare
        char *p0, *p1;
        while(ofs < bytesRead) {
            p0 = buf+ofs;
            p1 = buf+ofs+1;

            if((*p0 == '-' && *p1 == '-')
               && (ofs < bytesRead - boundaryLen)
               && (strncmp(buf+ofs+2, boundary, boundaryLen) == 0)) {
                fwrite(buf+startOfs, sizeof(char), ofs-startOfs-2, handle);
                ofs += 2; // Skip over the '--', boundary is handled in the next iteration
                rewind(handle);
                if(!currSeg[@"filename"]) {
                    // If it's not a file, we just load the string value to make things easy
                    NSData *strData = [currSeg[@"handle"] readDataToEndOfFile];
                    rewind(handle);
                    NSString *strVal = [[NSString alloc] initWithData:strData
                                                             encoding:NSUTF8StringEncoding];
                    currSeg[@"value"] = strVal ?: @"invalid encoding";
                }
                if(strncmp(buf+ofs+boundaryLen, "--", 2) != 0)
                    goto newSegment;
                else
                    goto doneProcessingSegments;
            } else
                ++ofs;
        }
        fwrite(buf+startOfs, sizeof(char), ofs-startOfs, handle);
    }
doneProcessingSegments:
    free(buf);
    return _requestMultipartSegments;
}

- (NSString *)_getVar:(NSString *)aName inBuffer:(const void *)aBuf length:(long)aLen
{
    if(!aBuf || !aLen)
        return nil;
    char *buf = malloc(aLen);
    int bytesRead = mg_get_var(aBuf, aLen, [aName UTF8String], buf, aLen);
    if(!bytesRead)
        return nil;
    return [[NSString alloc] initWithBytesNoCopy:buf
                                          length:bytesRead
                                        encoding:NSUTF8StringEncoding
                                    freeWhenDone:YES];
}

- (NSString *)requestBodyVar:(NSString *)aName
{
    NSData *body = self.requestBody;
    return [self _getVar:aName inBuffer:[body bytes] length:[body length]];
}

- (NSString *)requestQueryVar:(NSString *)aName
{
    const char *str = _mgRequest->query_string;
    if(str)
        return [self _getVar:aName inBuffer:str length:strlen(str)];
    return nil;
}

#pragma mark -

- (void)setResponseHeader:(NSString *)aHeader to:(NSString *)aValue
{
    NSParameterAssert(aHeader);
    if(aValue)
        _responseHeaders[aHeader] = aValue;
    else
        [_responseHeaders removeObjectForKey:aHeader];
}

- (NSString *)requestHeader:(NSString *)aName
{
    const char *h;
    if((h = mg_get_header(_mgConnection, [aName UTF8String])))
        return [NSString stringWithUTF8String:h];
    return nil;
}
@end
