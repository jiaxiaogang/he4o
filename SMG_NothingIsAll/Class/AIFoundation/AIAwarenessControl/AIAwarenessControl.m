//
//  AIAwarenessControl.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/11/9.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "AIAwarenessControl.h"
#import "AIThinkingRule.h"

@interface AIAwarenessControl()<AIMainThreadDelegate>

@property (strong,nonatomic) AIMainThread *mainThread;      //主意识
@property (strong,nonatomic) AIThinkingRule *thinkingRule;  //思维

@end

@implementation AIAwarenessControl

static AIAwarenessControl *_instance;
+(AIAwarenessControl*) shareInstance{
    if (_instance == nil) {
        _instance = [[AIAwarenessControl alloc] init];
    }
    return _instance;
}

-(id) init{
    self = [super init];
    if (self) {
        [self initData];
        [self initRun];
    }
    return self;
}



-(void) initData{
    self.mainThread = [[AIMainThread alloc] init];
    self.thinkingRule = [[AIThinkingRule alloc] init];
}

-(void) initRun{
    self.mainThread.delegate = self;
}

//MARK:===============================================================
//MARK:                     < method >
//MARK:===============================================================
-(void) awake{
    [self.mainThread awake];
}

-(void) sleep{
    [self.mainThread sleep];
}

-(void) commitInput:(id)data{
    NSLog(@"input传入");
    //1. 潜意识isBusy = false时,执行联想唯一性判断;等读取操作;
    [self.thinkingRule activityByShallow:data];
    
    //2. 主意识isBusy = false时,获取传给思维,作主意识传入;
    if (!self.mainThread.isBusy) {
        [self.thinkingRule activityByDeep:data];
    }
}

/**
 *  MARK:--------------------AIMainThreadDelegate--------------------
 */
-(void)aiMainThread_StateChanged{
    NSLog(@"主意识内心活动...");
    [self.thinkingRule activityByDeep:nil];
}

@end
