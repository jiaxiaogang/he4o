//
//  DemoHunger.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/12/14.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "DemoHunger.h"

@interface DemoHunger ()

@end

@implementation DemoHunger

-(id) init{
    self = [super init];
    if (self) {
        [self initRun];
    }
    return self;
}

-(void) initRun{
    [UIDevice currentDevice].batteryMonitoringEnabled = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(observerHungerLevelChanged:) name:UIDeviceBatteryLevelDidChangeNotification object:nil];
}

/**
 *  MARK:--------------------method--------------------
 */
-(void) observerHungerLevelChanged:(NSNotification*)notification{
    [self commit:[UIDevice currentDevice].batteryLevel state:[UIDevice currentDevice].batteryState];
}

-(void) commit:(CGFloat)level state:(UIDeviceBatteryState)state{
    //1,电量取值
    CGFloat toLevel = MIN(1, MAX(0, level));
    CGFloat fromLevel = state == UIDeviceBatteryStateCharging ? toLevel - 0.1f : toLevel + 0.1f;
    
    //2. 转换为0-10的饥饿度;
    CGFloat from = [MathUtils getZero2TenWithOriRange:UIFloatRangeMake(0, 1) oriValue:1 - fromLevel];
    CGFloat to = [MathUtils getZero2TenWithOriRange:UIFloatRangeMake(0, 1) oriValue:1 - toLevel];
    
    //3. 传给Input
    [AIInput commitIMV:MVType_Hunger from:from to:to];
}

@end
