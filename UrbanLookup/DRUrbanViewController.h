//
//  DRUrbanViewController.h
//  UrbanLookup
//
//  Created by Danny Ricciotti on 3/30/13.
//  Copyright (c) 2013 Danny Ricciotti. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DWTagList.h"

@protocol DRUrbanViewControllerDelegate <NSObject>
@optional
- (void)urbanControllerDidDismiss;
@end

@interface DRUrbanViewController : UIViewController <DWTagListDelegate>

@property (nonatomic, weak) id<DRUrbanViewControllerDelegate>delegate;

@property (nonatomic, weak) IBOutlet UIImageView *screamMan;

@property (nonatomic, weak) IBOutlet UIImageView *remoteImageView;

- (void)showDefinition:(NSString *)term;

- (void)dismiss;

@end
