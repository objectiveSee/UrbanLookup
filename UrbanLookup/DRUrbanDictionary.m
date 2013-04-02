//
//  DRUrbanDictionary.m
//  UrbanLookup
//
//  Created by Danny Ricciotti on 3/30/13.
//  Copyright (c) 2013 Danny Ricciotti. All rights reserved.
//

#import "DRUrbanDictionary.h"

@interface NSString (encode)
-(NSString *)urlEncodeUsingEncoding:(NSStringEncoding)encoding;
@end

@implementation NSString (encode)
// from http://madebymany.com/blog/url-encoding-an-nsstring-on-ios
-(NSString *)urlEncodeUsingEncoding:(NSStringEncoding)encoding {
	return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,
                                                               (CFStringRef)self,
                                                               NULL,
                                                               (CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",
                                                               CFStringConvertNSStringEncodingToEncoding(encoding)));
}
@end

///////////////////

const NSString *kAPIURLFormatString = @"http://api.urbandictionary.com/v0/define?term=%@";

@implementation DRUrbanDictionary

+ (id)sharedDictionary
{
    static DRUrbanDictionary *dictionary = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dictionary = [[DRUrbanDictionary alloc] init];
    });
	return dictionary;
}

- (id)init
{
    self = [super init];
    if (self) {
        //
    }
    return self;
}

- (void)lookupTerm:(NSString *)term withCompletion:(void(^)(BOOL success, id result))completionBlock
{
    NSParameterAssert(completionBlock);
    NSMutableURLRequest *request = [self _buildRequest:term];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         NSAssert([NSThread isMainThread] == YES, @"Should be main thread");
         NSInteger statusCode = 0;
         if ( response )
         {
             NSAssert([response isKindOfClass:[NSHTTPURLResponse class]], @"invalid class");
             statusCode = [(NSHTTPURLResponse *)response statusCode];
         }
         
         // verify that the request was successful and response code was 200 (HTTP success)
         if (( error != nil ) || ( statusCode != 200 ))
         {
             NSLog(@"Error: %@", error);
             completionBlock(NO, nil);
         }
         else
         {
             NSError *jsonError = nil;
             NSDictionary *responseBody = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
             if ( jsonError )
             {
                 NSLog(@"JSON Error: %@", error);
                 completionBlock(NO, nil);
             }
             else
             {
                 completionBlock(YES, responseBody);
             }
         }
     }];
}

- (NSMutableURLRequest *)_buildRequest:(NSString *)term
{
    // build request
    NSParameterAssert(term);
    NSString *urlStr = [NSString stringWithFormat:(NSString *)kAPIURLFormatString, [term urlEncodeUsingEncoding:NSASCIIStringEncoding]];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr]
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                       timeoutInterval:60.0f];
    [request setHTTPMethod: @"GET"];
    
    return request;
}
@end
