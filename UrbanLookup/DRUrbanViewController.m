//
//  DRUrbanViewController.m
//  UrbanLookup
//
//  Created by Danny Ricciotti on 3/30/13.
//  Copyright (c) 2013 Danny Ricciotti. All rights reserved.
//

#import "DRUrbanViewController.h"
#import "ASDepthModalViewController.h"
#import "EAParticleView.h"
#import "DRCheezBurger.h"

#import <QuartzCore/QuartzCore.h>

#import "UIImageView+WebCache.h"

typedef enum
{
    DRWordSpotInHead,
    DRWordSpotTopOffScreen,
    DRWordSpotBottomOffScreen,
    DRWordSpotBottom,
    DRWordSpotTermTop,
    DRWordSpotTop
} DRWordSpot;

// TODO: Image search is slow.
//#define CHEEZBURGER

// min lookup time for work (adds delay if lookup is faster then this time)
static const NSTimeInterval kMinTime = 1.5;

static const CGFloat kTopHeight = 50;
static const CGFloat kWidth = 180;
static const CGFloat kHeight = 113;

@interface DRUrbanViewController ()
@property (nonatomic, strong) NSString *term;
@property (nonatomic) BOOL isLookingUpDefinition;
@property (nonatomic) BOOL isDisplayed;
@property (nonatomic, strong) UITapGestureRecognizer *tapRecognizer;
@property (nonatomic, strong) UIActivityIndicatorView *lookupActivityIndicatorView;

@property (nonatomic, strong) DWTagList *currentSearchTermTagList;
@property (nonatomic, strong) DWTagList *currentSearchResultTagList;

//@property (nonatomic, strong) DRUrbanWord *searchTerm;

@property (nonatomic, strong) EAParticleView *particleView;

// to avoid a release while controller is on screen if the presenting controller doesn't retain reference to this controller.
@property (nonatomic, strong) DRUrbanViewController *strongSelf;

@end

@implementation DRUrbanViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.inputField.backgroundColor = [UIColor whiteColor];
    self.inputField.layer.cornerRadius = 8;
    self.inputField.textColor = [UIColor darkGrayColor];
    
    // Tpa recognizer
//    self.tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
//    [self.view addGestureRecognizer:self.tapRecognizer];
    
    self.lookupActivityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [self.lookupActivityIndicatorView setColor:[UIColor blackColor]];
    self.lookupActivityIndicatorView.hidesWhenStopped = YES;
    self.lookupActivityIndicatorView.center = CGPointMake(self.screamMan.bounds.size.width/2 - 40, self.screamMan.bounds.size.height/2);
    [self.screamMan addSubview:self.lookupActivityIndicatorView];
    [self setScreamManHidden:YES animated:NO];
    
    self.trackedViewName = @"Lookup";
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ( textField.text.length >= 1)
    {
        [self showDefinition:textField.text];
        [textField resignFirstResponder];
    }
    return NO;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self _removeOldWords];
}


- (void)showDefinition:(NSString *)term
{
    if ( self.isLookingUpDefinition == YES )
    {
        NSLog(@"Already looking up a term");
        return;
    }
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];

    static NSInteger lookupCounter = 0;
    [tracker sendEventWithCategory:@"UI Action"
                        withAction:@"Show Definition"
                         withLabel:term
                         withValue:[NSNumber numberWithInt:++lookupCounter]];
    
    // Clean up old terms
    self.inputField.text = nil;
    [self _removeOldWords];
    
    // validate term
    NSParameterAssert(term);
    self.term = term;
    
    // display controller (if needed)
    if ( self.isDisplayed == NO )
    {
//        [ASDepthModalViewController presentView:self.view
//                            withBackgroundColor:[UIColor blackColor]
//                            popupAnimationStyle:ASDepthModalAnimationNone];
        UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
        [window addSubview:self.view];
        self.view.frame = window.bounds;    // fullscreen
        [self setOffScreen:YES animated:NO];
        [self setOffScreen:NO animated:YES];
    }
    
    // show the scream man
    [self setScreamManHidden:NO animated:YES];
    
    // get this ready to go!
    if ( self.particleView == nil )
    {
        static const CGFloat kParticleViewWidth = 200;
        self.particleView = [[EAParticleView alloc] initStarsWithFrame:CGRectMake(self.view.bounds.size.width - kParticleViewWidth,
                                                                                  -160 + self.view.bounds.size.height,
                                                                                  kParticleViewWidth,
                                                                                  self.view.bounds.size.height - 300)];
        [self.particleView setIsEmitting:NO];
        self.particleView.userInteractionEnabled = NO;
        [self.view insertSubview:self.particleView belowSubview:self.screamMan];
    }
        
    // update state
    self.isDisplayed = YES;
    self.isLookingUpDefinition = YES;
    
    // Add taglist for search term
    CGRect frame = CGRectMake(self.view.bounds.size.width - kWidth,
                              self.view.bounds.size.height - kHeight,
                              kWidth,
                              kHeight);
    
    // Initalise and set the frame of the tag list
    NSParameterAssert(self.currentSearchResultTagList == nil);
    self.currentSearchTermTagList = [[DWTagList alloc] initWithFrame:frame];
    self.currentSearchTermTagList.tagDelegate = self;
    self.currentSearchTermTagList.backgroundColor = [UIColor clearColor];
    
    // Add the items to the array
    [self.currentSearchTermTagList setTags:[self _breakString:term]];
    
    CGFloat hue = ( arc4random() % 256 / 256.0 );  //  0.0 to 1.0
    CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from white
    CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from black
    UIColor *color = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
    
    [self.currentSearchTermTagList setLabelBackgroundColor:color];
    
    // Add the taglist to your UIView
    [self.view addSubview:self.currentSearchTermTagList];
    [self _animateView:self.currentSearchTermTagList toSpot:DRWordSpotInHead animated:NO];
    [self _animateView:self.currentSearchTermTagList toSpot:DRWordSpotBottom animated:YES];
    
    // Look up time tracking
    NSDate *date = [NSDate new];
    
    DRUrbanDictionary *urban = [DRUrbanDictionary sharedDictionary];
    [urban lookupTerm:term withCompletion:^(BOOL success, id result)
    {
        NSTimeInterval time = -[date timeIntervalSinceNow];
        double delayInSeconds = MAX(kMinTime-time, 0);
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            
            [self _animateView:self.currentSearchTermTagList toSpot:DRWordSpotTermTop animated:YES];
            NSLog(@"Definition finished. Success = %d", success);
            [self setScreamManHidden:YES animated:YES];
            [self _showDefinitionFromResult:result];
            self.isLookingUpDefinition = NO;
        });
    }];
    
#ifdef CHEEZBURGER
    // Remote image thumbnail
    [self.remoteImageView cancelCurrentImageLoad];
    self.remoteImageView.image = nil;
    DRCheezBurger *c = [DRCheezBurger sharedCheezBurger];
    NSString *myTerm = term;
    [c lookupTerm:term withCompletion:^(BOOL success, id result) {
        if ( [self.term isEqualToString:myTerm])
        {
            if ( success )
            {
                [self.remoteImageView setImageWithURL:[NSURL URLWithString:result]
                                     placeholderImage:nil
                                              options:SDWebImageRefreshCached];
            }
        }
    }];
#endif
}

- (void)_showDefinitionFromResult:(NSDictionary *)result
{
    NSParameterAssert(self.currentSearchResultTagList == nil);

    // get def from result
//    NSLog(@"Res=%@", result);
    
    NSString *definition = @"Fail! Network error";
    
    if ( result )
    {
        NSAssert([result isKindOfClass:[NSDictionary class]], @"invalid class: %@", [result class]);
        NSArray *list = [result objectForKey:@"list"];
        NSParameterAssert(list);
        
        if ( list.count < 1 )
        {
            definition = @"Fail! Word not found :(";
        }
        else
        {
            NSDictionary *firstDef = [list objectAtIndex:0];
            
            definition = [firstDef objectForKey:@"definition"];
            NSParameterAssert(definition);
        }
    }
    
    // Initalise and set the frame of the tag list
    self.currentSearchResultTagList = [[DWTagList alloc] initWithFrame:UIEdgeInsetsInsetRect(self.view.bounds, UIEdgeInsetsMake(kTopHeight, 0, 0, 0))];
    self.currentSearchResultTagList.tagDelegate = self;
    self.currentSearchResultTagList.backgroundColor = [UIColor clearColor];
    
#ifdef CHEEZBURGER
    self.currentSearchResultTagList.frame = UIEdgeInsetsInsetRect(self.view.bounds, UIEdgeInsetsMake(kTopHeight, 0, self.remoteImageView.frame.size.height, 0));
    NSLog(@"frame = %@", NSStringFromCGRect(self.currentSearchResultTagList.frame));
#endif
    
    [self.currentSearchResultTagList setLabelBackgroundColor:[UIColor clearColor]];
    [self.currentSearchResultTagList setTextColor:[UIColor whiteColor]];
    
    [self _animateView:self.currentSearchResultTagList toSpot:DRWordSpotBottomOffScreen animated:NO];
    
    // Add the items to the array
    [self.currentSearchResultTagList setTags:[self _breakString:definition]];
    
    // Add the taglist to your UIView
    self.currentSearchResultTagList.alpha = 0;
    [self.view addSubview:self.currentSearchResultTagList];
    [self _animateView:self.currentSearchResultTagList toSpot:DRWordSpotTop animated:YES];
    
    NSParameterAssert(self.particleView);
    [self.particleView setIsEmitting:YES];
}

- (void)setScreamManHidden:(BOOL)hidden animated:(BOOL)animated
{
    [UIView animateWithDuration:animated ? 0.3 : 0 delay:0 options:0 animations:^{
        self.screamMan.transform = CGAffineTransformMakeTranslation(0, hidden ? self.view.bounds.size.height - self.screamMan.bounds.origin.y : 0);
    } completion:nil];
}

- (void)_didTap:(UITapGestureRecognizer *)recognizer
{
    [self dismiss];
}

- (void)dismiss
{
    NSLog(@"Dismissing!");
    
    if ( [self.delegate respondsToSelector:@selector(urbanControllerDidDismiss)] )
    {
        [self.delegate urbanControllerDidDismiss];
    }
    [self setOffScreen:YES animated:YES];
    self.isDisplayed = NO;
}

- (void)setIsDisplayed:(BOOL)isDisplayed
{
    if ( isDisplayed != _isDisplayed )
    {
        if ( isDisplayed )
        {
            self.strongSelf = self;
        }
        else
        {
            self.strongSelf = nil;
        }
    }
    _isDisplayed = isDisplayed;
}

- (void)setIsLookingUpDefinition:(BOOL)isLookingUpDefinition
{
    if ( isLookingUpDefinition )
    {
        [self.lookupActivityIndicatorView startAnimating];
    }
    else
    {
        [self.lookupActivityIndicatorView stopAnimating];
    }
    [self.particleView setIsEmitting:isLookingUpDefinition];
    isLookingUpDefinition = _isLookingUpDefinition;
}

- (NSArray *)_breakString:(NSString *)str
{
    return [str componentsSeparatedByString:@" "];
}

- (void)_animateView:(UIView *)view toSpot:(DRWordSpot)spot animated:(BOOL)animated
{
    CGFloat alpha = 1;
    CGPoint center;
    CGFloat scale = 1;
    BOOL remove = NO;
    
    switch (spot)
    {
            // top
        case DRWordSpotTop: // definition tags when they are on top
            alpha = 1;
            center = CGPointMake(view.center.x, view.frame.size.height/2 + kTopHeight + 60);
            break;
        case DRWordSpotTermTop: // position of search term when on top
            alpha = 1;
            center = CGPointMake(view.center.x, view.frame.size.height/2 + 60);
            break;
        case DRWordSpotTopOffScreen:
            center = CGPointMake(view.center.x, -view.frame.size.height/2);
            alpha = 0;
            remove = YES;
            break;
            
            // bottom
        case DRWordSpotBottom:
            center = CGPointMake(self.view.bounds.size.width - view.bounds.size.width/2, self.view.bounds.size.height - view.frame.size.height/2);
            alpha = 1;
            break;
        case DRWordSpotBottomOffScreen:
            center = CGPointMake(self.view.bounds.size.width - view.bounds.size.width/2, self.view.bounds.size.height + view.frame.size.height/2);
            alpha = 0;
            break;
            
            // head
        case DRWordSpotInHead:
        default:
            scale = 1.0;    // todo make work with scale = 0. UI positioning bug
            center = CGPointMake(50, self.view.bounds.size.height - view.frame.size.height/2);
            alpha = 0;
            break;
    }
    
    [UIView animateWithDuration:animated ? 0.4 : 0 animations:^{
        view.alpha = alpha;
        view.transform = CGAffineTransformMakeScale(scale, scale);
        view.center = center;
    } completion:^(BOOL finished) {
        if ( finished && remove )
        {
            NSLog(@"view done: %@", view);
            [view removeFromSuperview];
        }
    }];
}

- (void)_removeOldWords
{
    if ( self.currentSearchResultTagList )
    {
        [self _animateView:self.currentSearchResultTagList toSpot:DRWordSpotTopOffScreen animated:YES];
        self.currentSearchResultTagList = nil;
    }
    if ( self.currentSearchTermTagList )
    {
        [self _animateView:self.currentSearchTermTagList toSpot:DRWordSpotTopOffScreen animated:YES];
        self.currentSearchTermTagList = nil;
    }
}

#pragma mark - DWTagListDelegate

- (void)selectedTag:(NSString*)tagName
{
    NSLog(@"Picked this!");
    [self showDefinition:tagName];
}

- (void)setOffScreen:(BOOL)offScreen animated:(BOOL)animated
{
    [UIView animateWithDuration:animated?0.3:0 animations:^{
        self.view.transform = offScreen?
        CGAffineTransformMakeTranslation(0, self.view.frame.size.height):
        CGAffineTransformIdentity;
    }completion:^(BOOL finished) {
        if ( finished && offScreen && animated )
        {
            // ONLY REMOVE FROM SUPERVIEW NOW BECAUSE WE KNOW THIS CASE ONLY EXISTS WHEN DISMISSING
            [self.view removeFromSuperview];
        }
    }];
}

@end
