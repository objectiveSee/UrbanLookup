//
//  DRViewController.h
//  UrbanLookup
//
//  Created by Danny Ricciotti on 3/30/13.
//  Copyright (c) 2013 Danny Ricciotti. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DRViewController : UIViewController <UITextFieldDelegate, DRUrbanViewControllerDelegate>

@property (nonatomic, weak) IBOutlet UITextField *inputField;

@end
