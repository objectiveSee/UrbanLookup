//
//  DRViewController.m
//  UrbanLookup
//
//  Created by Danny Ricciotti on 3/30/13.
//  Copyright (c) 2013 Danny Ricciotti. All rights reserved.
//

#import "DRViewController.h"


@interface DRViewController ()
@property (nonatomic, strong) DRUrbanViewController *urbanController;
@end

@implementation DRViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self.inputField becomeFirstResponder];
    
    self.trackedViewName = @"Main Menu";
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)_handleInput:(NSString *)text
{
    if ( text.length > 0 )
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.inputField resignFirstResponder];
            if ( self.urbanController == nil )
            {
                self.urbanController = [[DRUrbanViewController alloc] initWithNibName:nil bundle:nil];
                self.urbanController.delegate = self;
            }
            [self.urbanController showDefinition:text];
            
            [self setOffScreen:YES animated:YES];
        });
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self _handleInput:textField.text];
    return NO;
}

- (void)urbanControllerDidDismiss
{
    self.urbanController = nil;
    [self setOffScreen:NO animated:YES];
}

- (void)setOffScreen:(BOOL)offScreen animated:(BOOL)animated
{
    [UIView animateWithDuration:animated?0.3:0 animations:^{
        self.view.transform = offScreen?
        CGAffineTransformMakeTranslation(0, -self.view.frame.size.height):
        CGAffineTransformIdentity;
    }];
}

@end
