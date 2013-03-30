//
//  DRUrbanDictionary.h
//  UrbanLookup
//
//  Created by Danny Ricciotti on 3/30/13.
//  Copyright (c) 2013 Danny Ricciotti. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DRUrbanDictionary : NSObject

+ (id)sharedDictionary;

- (void)lookupTerm:(NSString *)term withCompletion:(void(^)(BOOL success, id result))completionBlock;

@end
