//
//  LockWindow.m
//  LockScreen
//
//  Created by kishikawa katsumi on 2013/07/28.
//  Copyright (c) 2013 kishikawa katsumi. All rights reserved.
//

#import "LockWindow.h"
#import <Quartz/Quartz.h>

@interface LockWindow ()

@property (nonatomic) NSImageView *sliderView;
@property (nonatomic) NSImageView *arrowView;

@end

@implementation LockWindow

- (id)initWithContentRect:(NSRect)contentRect
{
    self = [super initWithContentRect:contentRect styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:NO screen:[NSScreen mainScreen]];
    if (self) {
        self.backgroundColor = [NSColor colorWithPatternImage:[NSImage imageNamed:@"Linen"]];
        self.isVisible = YES;
        self.level = NSScreenSaverWindowLevel;
        
        [self.contentView setWantsLayer:YES];
    }
    
    return self;
}

- (void)setupSliderView
{
    NSRect windowFrame = self.frame;
    
    self.sliderView = [[NSImageView alloc] init];
    self.sliderView.wantsLayer = YES;
    self.sliderView.image = [NSImage imageNamed:@"Slider"];
    
    NSRect sliderFrame = self.sliderView.frame;
    sliderFrame.size = self.sliderView.image.size;
    sliderFrame.origin = NSMakePoint((NSWidth(windowFrame) - NSWidth(sliderFrame)) / 2,
                                     (NSHeight(windowFrame) - NSHeight(sliderFrame)) / 2);
    self.sliderView.frame = sliderFrame;
    
    [self.contentView addSubview:self.sliderView];
    
    self.arrowView = [[NSImageView alloc] init];
    self.arrowView.wantsLayer = YES;
    self.arrowView.image = [NSImage imageNamed:@"Arrow"];
    
    NSRect arrowFrame = self.arrowView.frame;
    arrowFrame.size = self.arrowView.image.size;
    arrowFrame.origin = NSMakePoint(6.0f, 6.0f);
    self.arrowView.frame = arrowFrame;
    
    [self.sliderView addSubview:self.arrowView];
    
    CALayer *layer = self.arrowView.layer;
    layer.opacity = 0.0f;
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    animation.toValue = @(1.0f);
    animation.duration = 0.5;
    animation.beginTime =  CACurrentMediaTime() + 0.25;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.autoreverses = YES;
    animation.repeatCount = HUGE_VALF;
    
    [layer addAnimation:animation forKey:@"blink"];
}

- (void)lock
{
    self.alphaValue = 0.0f;
    [self makeKeyAndOrderFront:nil];
    
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:0.25];
    [self.animator setAlphaValue:1.0f];
    
    [NSAnimationContext endGrouping];
    
    [self setupSliderView];
}

- (void)unlock
{
    CALayer *layer = self.arrowView.layer;
    [layer removeAnimationForKey:@"blink"];
    layer.opacity = 1.0f;
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
    animation.delegate = self;
    animation.fromValue = [layer valueForKey:@"position"];
    NSPoint point = NSMakePoint(NSWidth(self.sliderView.frame) - 6.0f - NSWidth(self.arrowView.frame),
                                layer.position.y);
    animation.toValue = [NSValue valueWithPoint:NSPointFromCGPoint(point)];
    animation.duration = 0.5;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    layer.position = point;
    
    [layer addAnimation:animation forKey:@"unlock"];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    double delayInSeconds = 0.1;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [NSAnimationContext beginGrouping];
        
        __block __unsafe_unretained NSWindow *bself = self;
        [[NSAnimationContext currentContext] setDuration:0.25];
        [[NSAnimationContext currentContext] setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        [[NSAnimationContext currentContext] setCompletionHandler:^{
            [bself orderOut:nil];
        }];
        
        [self.animator setAlphaValue:0.0f];
        [NSAnimationContext endGrouping];
    });
}

@end
