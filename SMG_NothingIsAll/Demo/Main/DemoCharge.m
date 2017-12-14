//
//  DemoCharge.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/12/14.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "DemoCharge.h"
#import "MindHeader.h"
#import "Input.h"
#import "AIIMVCharge.h"

@interface DemoCharge ()

@end

@implementation DemoCharge

-(id) init{
    self = [super init];
    if (self) {
        [self initRun];
    }
    return self;
}

-(void) initRun{
    [UIDevice currentDevice].batteryMonitoringEnabled = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(observerHungerStateChanged) name:UIDeviceBatteryStateDidChangeNotification object:nil];
}

/**
 *  MARK:--------------------method--------------------
 */
-(void) observerHungerStateChanged{
    //2,传给Input
    HungerState state;
    if ([UIDevice currentDevice].batteryState == UIDeviceBatteryStateUnplugged) {//未充电
        state = HungerState_Unplugged;
    }else if ([UIDevice currentDevice].batteryState == UIDeviceBatteryStateCharging) {//充电中
        state = HungerState_Charging;
    }
    
    AIIMVCharge *model = [[AIIMVCharge alloc] init];
    model.state = state;
    [theInput commitModel:model];
}

-(void) dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void) commit:(HungerState)state {
    AIIMVCharge *model = [[AIIMVCharge alloc] init];
    model.state = state;
    [theInput commitModel:model];
}

@end


