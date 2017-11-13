//
//  AIAwareness.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/11/9.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "AIAwareness.h"
#import "AIThinkingRule.h"

@interface AIAwareness()<AIMainThreadDelegate>

@property (strong,nonatomic) AIMainThread *mainThread;      //主意识
@property (strong,nonatomic) AIThinkingRule *thinkingRule;  //思维

@end

@implementation AIAwareness

static AIAwareness *_instance;
+(AIAwareness*) shareInstance{
    if (_instance == nil) {
        _instance = [[AIAwareness alloc] init];
    }
    return _instance;
}

-(id) init{
    self = [super init];
    if (self) {
        [self initData];
    }
    return self;
}

-(void) initData{
    self.mainThread = [[AIMainThread alloc] init];
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
