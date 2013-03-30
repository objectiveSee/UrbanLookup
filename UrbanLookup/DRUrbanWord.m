//
//  DRUrbanWord.m
//  UrbanLookup
//
//  Created by Danny Ricciotti on 3/30/13.
//  Copyright (c) 2013 Danny Ricciotti. All rights reserved.
//

#import "DRUrbanWord.h"

@interface DRUrbanWord ()
@property (nonatomic, strong) UILabel *label;
@end

@implementation DRUrbanWord

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        self.label = [[UILabel alloc] initWithFrame:self.bounds];
        self.label.font = [UIFont boldSystemFontOfSize:40];
        self.label.adjustsFontSizeToFitWidth = YES;
        self.label.minimumScaleFactor = 0.1;
        self.label.textColor = [UIColor blackColor];
        self.label.numberOfLines = 1;
        
        UIImage *i = [[UIImage imageNamed:@"bubble"] resizableImageWithCapInsets:UIEdgeInsetsMake(20, 50, 38, 20)];
        UIImageView *v = [[UIImageView alloc] initWithImage:i];
        v.frame = self.bounds;
        v.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        
        self.backgroundColor = [UIColor colorWithPatternImage:i];
    }
    return self;
}


+ (DRUrbanWord *)urbanWord:(NSString *)str inFrame:(CGRect)frame
{
//    DRUrbanWord *w = [[DRUrbanWord alloc] initWithFrame:frame];
//    w.text = str;
//    [w sizeToFit];
//    return w;
    return nil;
}

@end
