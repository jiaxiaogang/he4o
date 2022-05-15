//
//  AppDelegate.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/4/7.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NVView,HeLogView,TOMVision2;
@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NVView *nvView;
@property (strong, nonatomic) HeLogView *heLogView;
@property (strong, nonatomic) TOMVision2 *tv;
@property (assign, nonatomic) BOOL noNSLog;

-(UIViewController*) getTopDisplayViewController;
-(void) setTipLog:(NSString*)tipLog;

@end
