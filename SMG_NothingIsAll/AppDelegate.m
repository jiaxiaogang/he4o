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

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSLog(@"_______Path:\n______________________________________\n\n%@\n\n______________________________________\n",paths[0]);
    
    //初始化UI
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    StudyViewController *page = [[StudyViewController alloc] init];
    UINavigationController *naviC = [[UINavigationController alloc] initWithRootViewController:page];
    [self.window setRootViewController:naviC];
    [self.window makeKeyAndVisible];
    
    //模拟actionControl构建最简单的节点...
    [[AINet sharedInstance] insertString:@"1234"];
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

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
