// CocoaOniguruma is copyrighted free software by Satoshi Nakagawa <psychs AT limechat DOT net>.
// You can redistribute it and/or modify it under the new BSD license.

#import "OnigRegexp.h"


#define CHAR_SIZE 2

#define STRING_ENCODING NSUTF16LittleEndianStringEncoding
#define ONIG_ENCODING ONIG_ENCODING_UTF16_LE


@interface OnigResult (Private)
- (id)initWithRegexp:(OnigRegexp*)expression region:(OnigRegion*)region target:(NSString*)target;
- (NSMutableArray*)captureNameArray;
@end


@implementation OnigRegexp

- (id)initWithEntity:(regex_t*)entity expression:(NSString*)expression
{
    self = [super init];
    if (self) {
        _entity = entity;
        _expression = [expression copy];
    }
    return self;
}

- (void)dealloc
{
    if (_entity) onig_free(_entity);
#if !__has_feature(objc_arc)
    [_expression release];
    [super dealloc];
#endif
}

+ (OnigRegexp*)compile:(NSString*)expression
{
    return [self compile:expression ignorecase:NO multiline:NO extended:NO error:NULL];
}

+ (OnigRegexp*)compile:(NSString*)expression error:(NSError **)error
{
    return [self compile:expression ignorecase:NO multiline:NO extended:NO error:error];
}

+ (OnigRegexp*)compileIgnorecase:(NSString*)expression
{
    return [self compile:expression ignorecase:YES multiline:NO extended:NO error:NULL];
}

+ (OnigRegexp*)compileIgnorecase:(NSString*)expression error:(NSError **)error
{
    return [self compile:expression ignorecase:YES multiline:NO extended:NO error:error];
}

+ (OnigRegexp*)compile:(NSString*)expression ignorecase:(BOOL)ignorecase multiline:(BOOL)multiline
{
    return [self compile:expression ignorecase:ignorecase multiline:multiline extended:NO error:NULL];
}

+ (OnigRegexp*)compile:(NSString*)expression ignorecase:(BOOL)ignorecase multiline:(BOOL)multiline error:(NSError **)error
{
    return [self compile:expression ignorecase:ignorecase multiline:multiline extended:NO error:NULL];
}

+ (OnigRegexp*)compile:(NSString*)expression ignorecase:(BOOL)ignorecase multiline:(BOOL)multiline extended:(BOOL)extended
{
    return [self compile:expression ignorecase:ignorecase multiline:multiline extended:extended error:NULL];
}

+ (OnigRegexp*)compile:(NSString*)expression ignorecase:(BOOL)ignorecase multiline:(BOOL)multiline extended:(BOOL)extended error:(NSError **)error
{
    OnigOption options = OnigOptionNone;
    options |= multiline ? OnigOptionMultiline : OnigOptionSingleline;
    if(ignorecase) options |= OnigOptionIgnorecase;
    if(extended) options |= OnigOptionExtend;
    return [self compile:expression options:options error:error];
}

+ (OnigRegexp*)compile:(NSString*)expression options:(OnigOption)theOptions
{
    return [self compile:expression options:theOptions error:NULL];
}

+ (OnigRegexp*)compile:(NSString*)expression options:(OnigOption)theOptions error:(NSError **)error
{
    if (!expression) {
        if(error != NULL) {
            //Make NSError;
            NSDictionary* dict = [NSDictionary dictionaryWithObject:@"Invalid expression argument"
                                                             forKey:NSLocalizedDescriptionKey];
            *error = [NSError errorWithDomain:@"CocoaOniguruma" code:ONIG_NORMAL userInfo:dict];
        }
        return nil;
    }
    
    OnigOptionType option = theOptions;
    
    OnigErrorInfo err;
    regex_t* entity = 0;
    const UChar* str = (const UChar*)[expression cStringUsingEncoding:STRING_ENCODING];
    
    int status;
    @synchronized([OnigRegexp class]) {
        status = onig_new(&entity,
                              str,
                              str + [expression length] * CHAR_SIZE,
                              option,
                              ONIG_ENCODING,
                              ONIG_SYNTAX_DEFAULT,
                              &err);
    }
    
    if (status == ONIG_NORMAL) {
        OnigRegexp* regexp = [[self alloc] initWithEntity:entity expression:expression];
#if !__has_feature(objc_arc)
        [regexp autorelease];
#endif
        return regexp;
    }
    else {
        if(error != NULL) {
            //Make NSError;
            UChar str[ONIG_MAX_ERROR_MESSAGE_LEN];
            onig_error_code_to_str(str, status, &err);
            NSString* errorStr = [NSString stringWithCString:(char*)str
                                                    encoding:NSASCIIStringEncoding];
            NSDictionary* dict = [NSDictionary dictionaryWithObject:errorStr
                                                             forKey:NSLocalizedDescriptionKey];
            *error = [NSError errorWithDomain:@"CocoaOniguruma" code:status userInfo:dict];
        }
        if (entity) onig_free(entity);
        return nil;
    }
}

- (OnigResult*)search:(NSString*)target
{
    return [self search:target start:0 end:-1];
}

- (OnigResult*)search:(NSString*)target start:(int)start
{
    return [self search:target start:start end:-1];
}

- (OnigResult*)search:(NSString*)target start:(int)start end:(int)end
{
    if (!target) return nil;
    if (end < 0) end = [target length];
    
    OnigRegion* region = onig_region_new();
    const UChar* str = (const UChar*)[target cStringUsingEncoding:STRING_ENCODING];
    
    int status = onig_search(_entity,
                             str,
                             str + [target length] * CHAR_SIZE,
                             str + start * CHAR_SIZE,
                             str + end * CHAR_SIZE,
                             region,
                             ONIG_OPTION_NONE);
    
    if (status != ONIG_MISMATCH) {
        OnigResult* result = [[OnigResult alloc] initWithRegexp:self region:region target:target];
#if !__has_feature(objc_arc)
        [result autorelease];
#endif
        return result;
    }
    else {
        onig_region_free(region, 1);
        return nil;
    }
}

- (OnigResult*)search:(NSString*)target range:(NSRange)range
{
    return [self search:target start:range.location end:NSMaxRange(range)];
}

- (OnigResult*)match:(NSString*)target
{
    return [self match:target start:0];
}

- (OnigResult*)match:(NSString*)target start:(int)start
{
    if (!target) return nil;
    
    OnigRegion* region = onig_region_new();
    const UChar* str = (const UChar*)[target cStringUsingEncoding:STRING_ENCODING];
    
    int status = onig_match(_entity,
                            str,
                            str + [target length] * CHAR_SIZE,
                            str + start * CHAR_SIZE,
                            region,
                            ONIG_OPTION_NONE);
    
    if (status != ONIG_MISMATCH) {
        OnigResult* result = [[OnigResult alloc] initWithRegexp:self region:region target:target];
#if !__has_feature(objc_arc)
        [result autorelease];
#endif
        return result;
    }
    else {
        onig_region_free(region, 1);
        return nil;
    }
}

- (NSUInteger)captureCount
{
    return onig_number_of_captures(_entity);
}

- (NSString*)expression
{
    return _expression;
}

- (regex_t*)entity
{
    return _entity;
}

@end


@implementation OnigResult

- (id)initWithRegexp:(OnigRegexp*)expression region:(OnigRegion*)region target:(NSString*)target
{
    self = [super init];
    if (self) {
        _expression = expression;
#if !__has_feature(objc_arc)
        [_expression retain];
#endif
        _region = region;
        _target = [target copy];
        _captureNames = [NSMutableArray new];
    }
    return self;
}

- (void)dealloc
{
    if (_region) onig_region_free(_region, 1);
#if !__has_feature(objc_arc)
    [_expression release];
    [_target release];
    [super dealloc];
#endif
}

- (OnigRegexp*)_expression
{
    return _expression;
}

- (NSString*)target
{
    return _target;
}

- (int)size
{
    return [self count];
}

- (NSUInteger)count
{
    return _region->num_regs;
}

- (NSString*)stringAt:(NSUInteger)index
{
    return [_target substringWithRange:[self rangeAt:index]];
}

- (NSArray*)strings
{
    NSMutableArray* array = [NSMutableArray array];
    int i, count;
    for (i=0, count=[self count]; i<count; i++) {
        [array addObject:[self stringAt:i]];
    }
    return array;
}

- (NSRange)rangeAt:(NSUInteger)index
{
    return NSMakeRange([self locationAt:index], [self lengthAt:index]);
}

- (NSUInteger)locationAt:(NSUInteger)index
{
    return *(_region->beg + index) / CHAR_SIZE;
}

- (NSUInteger)lengthAt:(NSUInteger)index
{
    return (*(_region->end + index) - *(_region->beg + index)) / CHAR_SIZE;
}

- (NSString*)body
{
    return [self stringAt:0];
}

- (NSRange)bodyRange
{
    return [self rangeAt:0];
}

- (NSString*)preMatch
{
    return [_target substringToIndex:[self locationAt:0]];
}

- (NSString*)postMatch
{
    return [_target substringFromIndex:[self locationAt:0] + [self lengthAt:0]];
}

@end
