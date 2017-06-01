//
//  Mine.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/6/2.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "Mine.h"

@implementation Mine

-(id) init{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(observerHungerStateChanged) name:UIDeviceBatteryLevelDidChangeNotification object:nil];
    }
    return self;
}

-(void) observerHungerStateChanged{
    NSLog(@"自我产生饥饿意识");
    NSLog(@"传递给Mind产生充电需求");
}

+(HungerStatus) getHungerStatus{
    CGFloat batteryLevel = [UIDevice currentDevice].batteryLevel;
    if (batteryLevel == 100.0f) {
        return HungerStatus_Full;
    }else if(batteryLevel > 40.0f){
        return HungerStatus_NotHunger;
    }else if(batteryLevel > 20.0f){
        return HungerStatus_LitterHunger;
    }else if(batteryLevel > 10.0f){
        return HungerStatus_Hunger;
    }else if(batteryLevel > 5.0f){
        return HungerStatus_VeryHunger;
    }else{
        return HungerStatus_VeryVeryHunger;
    }
}

-(void) dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
