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
@property (strong, nonatomic) UIView *refreshDot;//因为模拟器下的UI动画老不刷新,所以写个闪动点,来推动UI被动刷新;
@property (strong, nonatomic) MemManagerWindow *memManagerWindow;

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
    [self createNavBtn:1 title:@"经历" action:@selector(openHeLogBtnOnClick:) bg:0];
    
    //3. 被动UI刷新
    self.refreshDot = [[UIView alloc] initWithFrame:CGRectMake(ScreenWidth - 40, 8, 5, 5)];
    [self.refreshDot setBackgroundColor:UIColorWithRGBHex(0x00FF00)];
    [self.refreshDot.layer setCornerRadius:2.5f];
    [self.refreshDot.layer setMasksToBounds:true];
    [self.window addSubview:self.refreshDot];
    [self startRefreshDotAnimation];
    
    //3. 记忆管理按钮
    [self createNavBtn:2 title:@"记忆" action:@selector(memManagerBtnOnClick:) bg:0];
    
    //3. 工作记忆按钮
    [self createNavBtn:3 title:@"思维" action:@selector(tvBtnOnClick:) bg:0];
    
    //3. 强化训练按钮
    [self createNavBtn:4 title:@"强训" action:@selector(rtBtnOnClick:) bg:0];
    
    //3. 强化训练配置->鸟出生地点;
    [theRT regist:kBirthPosRdmCentSEL target:self selector:@selector(setBirthPosMode_RdmCent)];
    [theRT regist:kBirthPosRdmSEL target:self selector:@selector(setBirthPosMode_Rdm)];
    [theRT regist:kBirthPosCentSEL target:self selector:@selector(setBirthPosMode_Cent)];
    
    //3. 强行停止思考能力按钮
    [self createNavBtn:5 title:@"植物" action:@selector(stopThinkBtnOnClick:) bg:1];
    
    //3. 模拟重启
    [self createNavBtn:6 title:@"重启" action:@selector(resetBtnOnClick:) bg:0];
    
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
    
    //9. 初始化XGConfig
    [XGConfig.instance initConfig];
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

/**
 *  MARK:--------------------无日志模式--------------------
 *  @version
 *      2022.08.17: 调试训练卡顿是因为theTV的帧记录导致的 (参考27065);
 */
-(void)setNoLogMode:(BOOL)noLogMode{
    [theTV setStop:noLogMode];
    [theHeLog setStop:noLogMode];
    //self.noNSLog = noLogMode;
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

-(void) stopThinkBtnOnClick:(UIButton*)btn{
    theTC.stopThink = !theTC.stopThink;
    [btn setTitle:theTC.stopThink ? @"动物" : @"植物" forState:UIControlStateNormal];
}

-(void) resetBtnOnClick:(UIButton*)btn{
    [btn setTitle:@"成功" forState:UIControlStateNormal];
    [theTC clear];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [btn setTitle:@"重启" forState:UIControlStateNormal];
    });
}

-(void) startRefreshDotAnimation{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.refreshDot.alpha = fabs(self.refreshDot.alpha - 1);
        [self startRefreshDotAnimation];
    });
}

/**
 *  MARK:--------------------创建navBtn--------------------
 *  @param index : 0=40, 1=82, 2=124, 3=166, 4=208, 5=250, 6=292
 *  @param bg : 默认0绿,1红;
 */
-(void) createNavBtn:(NSInteger)index title:(NSString*)title action:(SEL)action bg:(int)bg{
    //1. 数据准备;
    CGFloat marginRight = index * 40 + 40 + index * 2;
    CGFloat x = ScreenWidth - marginRight;
    UIColor *bgColor = bg == 1 ? UIColorWithRGBHex(0xFFEEEE) : UIColorWithRGBHex(0xEEFFEE);
    
    //2. 创建btn;
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(x, StateBarHeight, 40, 20)];
    [btn.titleLabel setFont:[UIFont systemFontOfSize:15]];
    [btn setTitleColor:UIColorWithRGBHex(0x0000EE) forState:UIControlStateNormal];
    [btn setBackgroundColor:bgColor];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    [self.window addSubview:btn];
}

//MARK:===============================================================
//MARK:                     < 小鸟出生地配置 >
//MARK:===============================================================
- (void)setBirthPosMode_Rdm{
    self.birthPosMode = 0;
    [theRT invoked:kBirthPosRdmSEL];
}
- (void)setBirthPosMode_RdmCent{
    self.birthPosMode = 1;
    [theRT invoked:kBirthPosRdmCentSEL];
}
- (void)setBirthPosMode_Cent{
    self.birthPosMode = 2;
    [theRT invoked:kBirthPosCentSEL];
}

@end
