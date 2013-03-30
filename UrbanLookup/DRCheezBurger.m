//
//  DRCheezBurger.m
//  UrbanLookup
//
//  Created by Danny Ricciotti on 3/30/13.
//  Copyright (c) 2013 Danny Ricciotti. All rights reserved.
//

#import "DRCheezBurger.h"

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

@implementation DRCheezBurger

+ (id)sharedCheezBurger
{
    static DRCheezBurger *cheez = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cheez = [[DRCheezBurger alloc] init];
    });
	return cheez;
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
//             NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//             NSParameterAssert(str);
//             NSLog(@"str =%@", str);
//                          
//             NSRange r = [str rangeOfString:@"event-item-lol-image"];
//             if ( r.location != NSNotFound )
//             {
//                 NSString *substr = [str substringFromIndex:r.location];
//                 NSRange r2 = [substr rangeOfString:@"src=\""];
//                 NSString *substr2 = [substr substringFromIndex:r2.location + r2.length];
//                 NSRange r3 = [substr2 rangeOfString:@"\""];
//                 NSString *imagePath = [substr2 substringToIndex:r3.location];
//                 
//                 NSLog(@"path = %@", imagePath);
//             }
             
             NSError *jsonError = nil;
             NSDictionary *responseBody = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
             if ( jsonError )
             {
                 NSLog(@"JSON Error: %@", error);
                 completionBlock(NO, nil);
             }
             else
             {
                 NSString *url = [responseBody objectForKey:@"thumbnail_url"];
                 if ( url )
                 {
                     completionBlock(YES, url);
                 }
                 else
                 {
                     completionBlock(NO, nil);
                 }
             }
         }
     }];
}


- (NSMutableURLRequest *)_buildRequest:(NSString *)term
{
    //fc6169dfe36648878f18dbf3ca9cfe4a
    // build request
    NSParameterAssert(term);
    NSString *cheezUrl = [NSString stringWithFormat:@"http://search.cheezburger.com/?q=%@", [term urlEncodeUsingEncoding:NSASCIIStringEncoding]];
    NSString *urlStr = [NSString stringWithFormat:@"http://api.embed.ly/1/oembed?key=%@&url=%@", @"fc6169dfe36648878f18dbf3ca9cfe4a",cheezUrl];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr]
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                       timeoutInterval:60.0f];
    [request setHTTPMethod: @"GET"];
    
    return request;
}

@end
