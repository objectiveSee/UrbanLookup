//
//  DRCheezBurger.h
//  UrbanLookup
//
//  Created by Danny Ricciotti on 3/30/13.
//  Copyright (c) 2013 Danny Ricciotti. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DRCheezBurger : NSObject

+ (id)sharedCheezBurger;

- (void)lookupTerm:(NSString *)term withCompletion:(void(^)(BOOL success, id result))completionBlock;

@end
