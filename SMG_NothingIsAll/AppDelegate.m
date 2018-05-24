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
#import "XGRedis.h"

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
    
    XGRedis *redis = [[XGRedis alloc] init];
    
    [redis setObject:@"test1" forKey:@"key1"];
    NSObject *v1 = [redis objectForKey:@"key1"];
    [redis setObject:@"test2" forKey:@"key2" time:5];
    [redis setObject:@"test3" forKey:@"key3" time:10];
    [redis setObject:@"test3" forKey:@"key3" time:40];
    
    NSLog(@"");
    
    
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

@end
