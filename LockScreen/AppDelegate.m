//
//  AppDelegate.m
//  LockScreen
//
//  Created by kishikawa katsumi on 2013/07/27.
//  Copyright (c) 2013 kishikawa katsumi. All rights reserved.
//

#import "AppDelegate.h"
#import "LockWindow.h"
#import "LeapObjectiveC.h"

@interface AppDelegate ()

@property (nonatomic) NSMutableArray *windows;
@property (nonatomic, getter = isLocked) BOOL locked;

@property (nonatomic) NSInteger swipeGestureID;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    LeapController *controller = [[LeapController alloc] init];
    controller.policyFlags = LEAP_POLICY_BACKGROUND_FRAMES;
    [controller addListener:self];
}

- (void)lockScreen
{
    if (self.isLocked) {
        return;
    }
    
    @try {
        NSApplicationPresentationOptions options =
        NSApplicationPresentationHideDock +
        NSApplicationPresentationHideMenuBar +
        NSApplicationPresentationDisableForceQuit +
        NSApplicationPresentationDisableProcessSwitching;
        [NSApp setPresentationOptions:options];
        
        self.windows = [[NSMutableArray alloc] init];
        
        NSArray *screens = [NSScreen screens];
        for (NSScreen *screen in screens) {
            NSRect screenFrame = screen.frame;
            
            LockWindow *window = [[LockWindow alloc] initWithContentRect:screenFrame];
            [window lock];
            
            [self.windows addObject:window];
        }
        
        self.locked = YES;
    }
    @catch(NSException * exception) {
        NSLog(@"%@", @"Error.  Make sure you have a valid combination of options.");
    }
}

- (void)unlockScreen
{
    if (!self.isLocked) {
        return;
    }
    
    @try {
        [NSApp setPresentationOptions:NSApplicationPresentationDefault];
        
        for (LockWindow *window in self.windows) {
            [window unlock];
        }
        
//    self.windows = nil;
        
        self.locked = NO;
    }
    @catch(NSException * exception) {
        NSLog(@"%@", @"Error.  Make sure you have a valid combination of options.");
    }
}

- (void)handleSwipe:(LeapSwipeGesture *)swipeGesture
{
    if (swipeGesture.state == LEAP_GESTURE_STATE_START) {
        self.swipeGestureID = swipeGesture.id;
    }
    if (swipeGesture.state == LEAP_GESTURE_STATE_STOP) {
        if (self.swipeGestureID == swipeGesture.id) {
//            LeapGesture *startPosition = swipeGesture.startPosition;
//            LeapGesture *endPosition = swipeGesture.position;
            float x = swipeGesture.direction.x;
            float y = swipeGesture.direction.y;
            
            if (fabsf(x) > fabsf(y)) {
                if (x > 0.0f) {
                    [self unlockScreen];
                } else {
                    [self lockScreen];
                }
            } else {
                [self lockScreen];
            }
        }
    }
}

- (void)onInit:(NSNotification *)notification
{
//    NSLog(@"%s", __func__);
}

- (void)onConnect:(NSNotification *)notification
{
//    NSLog(@"%s", __func__);
    LeapController *controller = notification.object;
    [controller enableGesture:LEAP_GESTURE_TYPE_SWIPE enable:YES];
    [controller enableGesture:LEAP_GESTURE_TYPE_CIRCLE enable:YES];
    [controller enableGesture:LEAP_GESTURE_TYPE_SCREEN_TAP enable:YES];
    [controller enableGesture:LEAP_GESTURE_TYPE_KEY_TAP enable:YES];
}

- (void)onDisconnect:(NSNotification *)notification
{
//    NSLog(@"%s", __func__);
}

- (void)onExit:(NSNotification *)notification
{
//    NSLog(@"%s", __func__);
}

- (void)onFocusGained:(NSNotification *)notification
{
//    NSLog(@"%s", __func__);
}

- (void)onFocusLost:(NSNotification *)notification
{
//    NSLog(@"%s", __func__);
}
- (void)onFrame:(NSNotification *)notification
{
    LeapController *controller = notification.object;
    LeapFrame *frame = [controller frame:0];
    
    NSArray *gestures = [frame gestures:nil];
    for (LeapGesture *gesture in gestures) {
        switch (gesture.type) {
            case LEAP_GESTURE_TYPE_SWIPE: {
                [self handleSwipe:(LeapSwipeGesture *)gesture];
                break;
            }
            default:
                break;
        }
    }
}

@end
