
//  Created by Danny Ricciotti on 3/30/13.
//  Copyright (c) 2013 Danny Ricciotti. All rights reserved.
//
//  EAParticleView.h

#import <UIKit/UIKit.h>

@interface EAParticleView : UIView

///@name Effect specific initalizers
- (id)initStarsWithFrame:(CGRect)frame;

///@name Emitter Methods
- (void)setEmitterPosition:(CGPoint)point;
- (void)setEmitterPositionFromTouch: (UITouch*)t;
- (void)setIsEmitting:(BOOL)isEmitting;
- (void) decayOverTime:(NSTimeInterval)interval;

@end
