//
//  AppDelegate.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/4/7.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "AppDelegate.h"
#import "MainPage.h"
#import "AINet.h"
#import "NSObject+Extension.h"
#import "AIKVPointer.h"
#import "NVDelegate_He.h"
#import "HeLogView.h"
#import <UMCommon/UMCommon.h>
#import "MemManagerWindow.h"
#import "MASConstraint.h"
#import "View+MASAdditions.h"

@interface AppDelegate ()

@property (strong, nonatomic) UILabel *tipLogLab;
@property (strong, nonatomic) UIButton *openHeLogBtn;
@property (strong, nonatomic) UIView *refreshDot;   //因为模拟器下的UI动画老是刷新不了,所以临时写这么个点,来推动UI线程被动刷新;
@property (strong, nonatomic) MemManagerWindow *memManagerWindow;
@property (strong, nonatomic) UIButton *memManagerBtn;
@property (strong, nonatomic) UIButton *tvBtn;
@property (strong, nonatomic) UIButton *rtBtn;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //0. 初始化UMeng
    [UMConfigure initWithAppkey:@"5f06fadaed3b4408234905b8" channel:@"default"];
    [UMConfigure setLogEnabled:true];
    
    //1. Path
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSLog(@"%@",paths[0]);
    
    //2. 初始化UI
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    MainPage *page = [[MainPage alloc] init];
    UINavigationController *naviC = [[UINavigationController alloc] initWithRootViewController:page];
    [self.window setRootViewController:naviC];
    [self.window makeKeyAndVisible];
    
    //3. heLogView打开按钮
    self.openHeLogBtn = [[UIButton alloc] initWithFrame:CGRectMake(ScreenWidth - 82, StateBarHeight, 40, 20)];
    [self.openHeLogBtn.titleLabel setFont:[UIFont systemFontOfSize:15]];
    [self.openHeLogBtn setTitleColor:UIColorWithRGBHex(0x0000EE) forState:UIControlStateNormal];
    [self.openHeLogBtn setBackgroundColor:UIColorWithRGBHex(0xEEFFEE)];
    [self.openHeLogBtn setTitle:@"经历" forState:UIControlStateNormal];
    [self.openHeLogBtn addTarget:self action:@selector(openHeLogBtnOnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.window addSubview:self.openHeLogBtn];
    
    //3. 被动UI刷新
    self.refreshDot = [[UIView alloc] initWithFrame:CGRectMake(ScreenWidth - 40, 8, 5, 5)];
    [self.refreshDot setBackgroundColor:UIColorWithRGBHex(0x00FF00)];
    [self.refreshDot.layer setCornerRadius:2.5f];
    [self.refreshDot.layer setMasksToBounds:true];
    [self.window addSubview:self.refreshDot];
    [self startRefreshDotAnimation];
    
    //3. 记忆管理按钮
    self.memManagerBtn = [[UIButton alloc] initWithFrame:CGRectMake(ScreenWidth - 124, StateBarHeight, 40, 20)];
    [self.memManagerBtn.titleLabel setFont:[UIFont systemFontOfSize:15]];
    [self.memManagerBtn setTitleColor:UIColorWithRGBHex(0x0000EE) forState:UIControlStateNormal];
    [self.memManagerBtn setBackgroundColor:UIColorWithRGBHex(0xEEFFEE)];
    [self.memManagerBtn setTitle:@"记忆" forState:UIControlStateNormal];
    [self.memManagerBtn addTarget:self action:@selector(memManagerBtnOnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.window addSubview:self.memManagerBtn];
    
    //3. 工作记忆按钮
    self.tvBtn = [[UIButton alloc] initWithFrame:CGRectMake(ScreenWidth - 166, StateBarHeight, 40, 20)];
    [self.tvBtn.titleLabel setFont:[UIFont systemFontOfSize:15]];
    [self.tvBtn setTitleColor:UIColorWithRGBHex(0x0000EE) forState:UIControlStateNormal];
    [self.tvBtn setBackgroundColor:UIColorWithRGBHex(0xEEFFEE)];
    [self.tvBtn setTitle:@"思维" forState:UIControlStateNormal];
    [self.tvBtn addTarget:self action:@selector(tvBtnOnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.window addSubview:self.tvBtn];
    
    //3. 强化训练按钮
    self.rtBtn = [[UIButton alloc] initWithFrame:CGRectMake(ScreenWidth - 208, StateBarHeight, 40, 20)];
    [self.rtBtn.titleLabel setFont:[UIFont systemFontOfSize:15]];
    [self.rtBtn setTitleColor:UIColorWithRGBHex(0x0000EE) forState:UIControlStateNormal];
    [self.rtBtn setBackgroundColor:UIColorWithRGBHex(0xEEFFEE)];
    [self.rtBtn setTitle:@"强训" forState:UIControlStateNormal];
    [self.rtBtn addTarget:self action:@selector(rtBtnOnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.window addSubview:self.rtBtn];
    
    //3. 强化训练配置->鸟出生地点;
    [theRT regist:kBirthPosRdmCentSEL target:self selector:@selector(setBirthPosMode_RdmCent)];
    [theRT regist:kBirthPosRdmSEL target:self selector:@selector(setBirthPosMode_Rdm)];
    [theRT regist:kBirthPosCentSEL target:self selector:@selector(setBirthPosMode_Cent)];
    
    //4. 神经网络可视化
    self.nvView = [[NVView alloc] initWithDelegate:[NVDelegate_He new]];
    [self.nvView setAlpha:0.9f];
    [self.window addSubview:self.nvView];
    
    //5. heLogView
    self.heLogView = [[HeLogView alloc] init];
    [self.window addSubview:self.heLogView];
    
    //6. tipLogLab
    self.tipLogLab = [[UILabel alloc] init];
    [self.tipLogLab setTextColor:[UIColor redColor]];
    [self.tipLogLab setFont:[UIFont fontWithName:@"PingFang SC" size:8.0f]];
    self.tipLogLab.lineBreakMode = NSLineBreakByCharWrapping;
    [self.tipLogLab setNumberOfLines:0];
    [self.window addSubview:self.tipLogLab];
    [self.tipLogLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.window);
        make.trailing.mas_equalTo(self.window);
        make.bottom.mas_equalTo(self.window);
    }];
    
    //7. 记忆管理器
    self.memManagerWindow = [[MemManagerWindow alloc] init];
    [self.window addSubview:self.memManagerWindow];
    
    //8. 工作记忆可视化
    self.tv = [[TOMVision2 alloc] init];
    [self.window addSubview:self.tv];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {}

- (void)applicationDidEnterBackground:(UIApplication *)application {}

- (void)applicationWillEnterForeground:(UIApplication *)application {}

- (void)applicationDidBecomeActive:(UIApplication *)application {}

- (void)applicationWillTerminate:(UIApplication *)application {}

//MARK:===============================================================
//MARK:                     < method >
//MARK:===============================================================
-(UIViewController*) getTopDisplayViewController{
    UINavigationController *navC = (UINavigationController*)[self.window rootViewController];    
    NSArray *controllers = navC.viewControllers;
    UIViewController *controller = [controllers lastObject];
    return controller;
}

-(void) setTipLog:(NSString*)tipLog{
    [self.tipLogLab setText:STRTOOK(tipLog)];
}

//MARK:===============================================================
//MARK:                     < privateMethod >
//MARK:===============================================================
-(void) openHeLogBtnOnClick:(id)btn{
    [self.heLogView open];
}

-(void) memManagerBtnOnClick:(id)btn{
    [self.memManagerWindow open];
}

-(void) tvBtnOnClick:(id)btn{
    [self.tv open];
}

-(void) rtBtnOnClick:(id)btn{
    [theRT open];
}

-(void) startRefreshDotAnimation{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.refreshDot.alpha = fabs(self.refreshDot.alpha - 1);
        [self startRefreshDotAnimation];
    });
}

//MARK:===============================================================
//MARK:                     < 小鸟出生地配置 >
//MARK:===============================================================
- (void)setBirthPosMode_RdmCent{
    self.birthPosMode = 1;
    [theRT invoked:kBirthPosRdmCentSEL];//标记执行完成;
}
- (void)setBirthPosMode_Rdm{
    self.birthPosMode = 0;
    [theRT invoked:kBirthPosRdmSEL];    //标记执行完成;
}
- (void)setBirthPosMode_Cent{
    self.birthPosMode = 2;
    [theRT invoked:kBirthPosCentSEL];   //标记执行完成;
}

@end
