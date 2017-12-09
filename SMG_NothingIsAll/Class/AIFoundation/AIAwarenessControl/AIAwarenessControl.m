//
//  AIAwarenessControl.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/11/9.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "AIAwarenessControl.h"
#import "AIReactorControl.h"
#import "AIModel.h"

@interface AIAwarenessControl()<AIMainThreadDelegate>

@property (strong,nonatomic) AIMainThread *mainThread;      //主意识

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
    [[AIReactorControl shareInstance] commitInput:data];
}

-(void) commitModel:(AIModel*)model{
    [[AIReactorControl shareInstance] commitModel:model];
    //一个事务是否有意识要靠思维自行判断;
    //    //1. 潜意识isBusy = false时,执行联想唯一性判断;等读取操作;
    //    [[AIReactorControl shareInstance] activityByShallow:data];
    //
    //    //2. 主意识isBusy = false时,获取传给思维,作主意识传入;
    //    if (!self.mainThread.isBusy) {
    //        [[AIReactorControl shareInstance] activityByDeep:data];
    //    }
}

/**
 *  MARK:--------------------AIMainThreadDelegate--------------------
 */
-(void)aiMainThread_StateChanged{
    NSLog(@"主意识状态急通知...");
    //[[AIThinkingControl shareInstance] activityByDeep:nil];
}

@end
