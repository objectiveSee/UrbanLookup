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
    self.inputField.text = @"Hackathon";
//    [self _handleInput:@"[Caffeine]"];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    UIImage *i = [[UIImage imageNamed:@"background"] resizableImageWithCapInsets:UIEdgeInsetsMake(200, 0, 0, 0)];
    UIImageView *iv = [[UIImageView alloc] initWithImage:i];
    [self.view insertSubview:iv atIndex:0];
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
#if 0
        [[DRUrbanDictionary sharedDictionary] lookupTerm:text withCompletion:^(BOOL success, id result) {
            // Finished!
            NSLog(@"Hey!");
        }];
#else
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.inputField resignFirstResponder];
            if ( self.urbanController == nil )
            {
                self.urbanController = [[DRUrbanViewController alloc] initWithNibName:nil bundle:nil];
                self.urbanController.delegate = self;
                [self.urbanController showDefinition:text];
            }
 
        });
#endif
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
}

@end
