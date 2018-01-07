//
//  AppDelegate.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/4/7.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "AppDelegate.h"
#import "StudyViewController.h"
#import "AINet.h"
#import "AIIMVHunger.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    //1. Path
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSLog(@"_______Path:\n______________________________________\n\n%@\n\n______________________________________\n",paths[0]);
    
    //2. 初始化UI
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    StudyViewController *page = [[StudyViewController alloc] init];
    UINavigationController *naviC = [[UINavigationController alloc] initWithRootViewController:page];
    [self.window setRootViewController:naviC];
    [self.window makeKeyAndVisible];
    
    //3. 假数据模拟actionControl构建节点...
    [self testBuildDataNet];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {}

- (void)applicationDidEnterBackground:(UIApplication *)application {}

- (void)applicationWillEnterForeground:(UIApplication *)application {}

- (void)applicationDidBecomeActive:(UIApplication *)application {}

- (void)applicationWillTerminate:(UIApplication *)application {}

/**
 *  MARK:--------------------method--------------------
 */
-(UIViewController*) getTopDisplayViewController{
    UINavigationController *navC = (UINavigationController*)[self.window rootViewController];
    
    NSArray *controllers = navC.viewControllers;
    UIViewController *controller = [controllers lastObject];
    return controller;
}

-(void) testBuildDataNet{
    //1. 饥饿感知
    AIIMVHunger *hungerModel = [[AIIMVHunger alloc] init];
    //....思维model设计...
    [[AINet sharedInstance] insertProperty:nil];
}

@end
