//
//  BaseDeveloperWindow.h
//  TyBattleCity
//
//  Created by luckytianyiyan on 2017/8/10.
//  Copyright © 2017年 luckytianyiyan. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BaseDeveloperKeyCommandDelegate

@required
- (void)keyUp:(NSString *)keyCode command:(UIKeyCommand *)command;
- (void)keyDown:(NSString *)keyCode command:(UIKeyCommand *)command;

@end

@interface BaseDeveloperWindow : UIWindow

@property (nonatomic, weak) id<BaseDeveloperKeyCommandDelegate> keyCommandDelegate;

@end
