
//  Created by Danny Ricciotti on 3/30/13.
//  Copyright (c) 2013 Danny Ricciotti. All rights reserved.
//
//  EAParticleView.m

#import "EAParticleView.h"
#import <QuartzCore/QuartzCore.h>

@interface EAParticleView ()
@property (nonatomic, strong) CAEmitterLayer* emitter;
@property (nonatomic, assign) CGFloat decayAmount;
@property (nonatomic, assign) CGFloat emitterBirthRate;
@end

@implementation EAParticleView
{
}

- (id)initWithFrame:(CGRect)frame
{
    NSParameterAssert(nil); // invalid initalizer
    return nil;
}

- (id)initStarsWithFrame:(CGRect)frame
{
    static const CGFloat kEmitterY = 70;
    static const CGFloat kEmitterX = 0;
    
    if ( self = [super initWithFrame:frame] )
    {
        self.emitter = (CAEmitterLayer*)self.layer;
        self.emitter.emitterPosition = CGPointMake(kEmitterX, kEmitterY);
        self.emitter.emitterShape = kCAEmitterLayerPoint;
        
        self.emitterBirthRate = 4;
        
        self.emitter.seed = arc4random_uniform(1000);
        
        CAEmitterCell *cell = [CAEmitterCell emitterCell];
        cell.contents = (__bridge id)[[UIImage imageNamed:@"DazStar"] CGImage];
        cell.name = @"stars";
        cell.birthRate = 4;
        cell.lifetime = 2.0;
        cell.color = [[UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1.0] CGColor];
        cell.redRange = 1;
        cell.greenRange = 1;
        cell.blueRange = 1;
        
        cell.velocity = -200;
        cell.velocityRange = 50;
        cell.emissionRange = (CGFloat) M_PI_2;
        cell.emissionLongitude = (CGFloat) M_PI;
        cell.yAcceleration = 150;
        cell.scale = 1.0;
        cell.scaleRange = 0.2;
        cell.spinRange = 10.0;
        self.emitter.emitterCells = [NSArray arrayWithObject:cell];
    }
    return self;
}

+ (Class) layerClass //3
{
    //configure the UIView to have emitter layer
    return [CAEmitterLayer class];
}

- (void)setEmitterPosition:(CGPoint)point
{
    self.emitter.emitterPosition = point;
}

-(void)setEmitterPositionFromTouch: (UITouch*)t
{
    //change the emitter's position
    self.emitter.emitterPosition = [t locationInView:self];
}

-(void)setIsEmitting:(BOOL)isEmitting
{
    //turn on/off the emitting of particles
    self.emitter.birthRate = isEmitting ? self.emitterBirthRate : 0;
}

static NSTimeInterval const kDecayStepInterval = 0.1;
- (void) decayStep
{
    self.emitter.birthRate -=_decayAmount;
    if (self.emitter.birthRate < 0)
    {
        self.emitter.birthRate = 0;
    }
    else
    {
        // run in NSRunLoopCommonModes because the timer wont fire if scrolling (or for other reasons) if you use the default mode.
        // if timer does not fire then emitter won't decay which is undesired.
        [self performSelector:@selector(decayStep) withObject:nil afterDelay:kDecayStepInterval inModes:@[NSRunLoopCommonModes]];
    }
}

- (void) decayOverTime:(NSTimeInterval)interval {
    self.decayAmount = (CGFloat) (self.emitter.birthRate /  (interval / kDecayStepInterval));
    [self decayStep];
    
    // As a fail-safe, we turn off the emitter after its decayinterval. This is to prevent against the case when the decay timers do not fire at the expected intervals (due to runloop modes, etc).
    [self performSelector:@selector(_stopEmitting) withObject:nil afterDelay:interval + 0.2 inModes:@[NSRunLoopCommonModes]];
}

#pragma mark - Private

- (void)_stopEmitting
{
    [self setIsEmitting:NO];
}

@end
