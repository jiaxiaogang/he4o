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

//开始异步搜索IO任务;
-(void) run{
    __block Awareness *weakSelf;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(6.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        weakSelf.count ++;
        NSInteger analyzeCount = (weakSelf.count % 10 == 0) ? 1000 : 100;//9短1长;
        [self.demand runAnalyze:analyzeCount];
        [self run];
    });
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

@end
