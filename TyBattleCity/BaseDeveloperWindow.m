//
//  BaseDeveloperWindow.m
//  TyBattleCity
//
//  Created by luckytianyiyan on 2017/8/10.
//  Copyright © 2017年 luckytianyiyan. All rights reserved.
//

#import "BaseDeveloperWindow.h"

@interface UIWindow (Private)

- (UIKeyCommand *)_keyCommandForEvent:(UIEvent *)event;

@end

@implementation BaseDeveloperWindow

#if DEBUG
- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (UIKeyCommand *)_keyCommandForEvent:(UIEvent *)event {
    UIKeyCommand *command = [super _keyCommandForEvent:event];
    if (_keyCommandDelegate && command) {
        NSString *keyCode = [[event valueForKey:@"_keyCode"] stringValue];
        if ([[event valueForKey:@"_isKeyDown"] boolValue]) {
            [_keyCommandDelegate keyDown:keyCode command:command];
        } else {
            [_keyCommandDelegate keyUp:keyCode command:command];
        }
    }
    
    return command;
}
#endif

@end
