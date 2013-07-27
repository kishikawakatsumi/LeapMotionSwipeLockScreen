//
//  LockWindow.h
//  LockScreen
//
//  Created by kishikawa katsumi on 2013/07/28.
//  Copyright (c) 2013 kishikawa katsumi. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface LockWindow : NSWindow

- (id)initWithContentRect:(NSRect)contentRect;
- (void)lock;
- (void)unlock;

@end
