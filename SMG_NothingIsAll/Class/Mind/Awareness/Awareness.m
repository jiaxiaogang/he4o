//
//  Awareness.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/7/22.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "Awareness.h"

@interface Awareness ()

@property (strong,nonatomic) Demand *demand;
@property (assign, nonatomic) NSInteger count;

@end

@implementation Awareness

-(void) run{
    //1,开始异步搜索IO任务;(xx秒一次的内省)
    __block Awareness *weakSelf;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(600.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        weakSelf.count ++;
        NSInteger analyzeCount = (weakSelf.count % 10 == 0) ? 200 : 50;//9短1长;
        [self.demand runAnalyze:analyzeCount];
        [self run];
    });
    
    //2,监听意识流的数据变化
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(runByAwarnessModelNotice:) name:ObsKey_AwarenessModelChanged object:nil];
    
}

/**
 *  MARK:--------------------property--------------------
 */
- (Demand *)demand{
    if (_demand == nil) {
        _demand = [[Demand alloc] init];
    }
    return _demand;
}


/**
 *  MARK:--------------------method--------------------
 */
-(void) runByAwarnessModelNotice:(NSNotification*)notification{
    [self.demand runAnalyze:1];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ObsKey_AwarenessModelChanged object:nil];
}
@end
