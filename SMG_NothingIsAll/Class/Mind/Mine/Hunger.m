//
//  Hunger.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/6/7.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "Hunger.h"
#import "MindHeader.h"


@implementation Hunger


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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(observerHungerStateChanged) name:UIDeviceBatteryStateDidChangeNotification object:nil];
}

/**
 *  MARK:--------------------method--------------------
 */
-(void) observerHungerLevelChanged:(NSNotification*)notification{
    UIDeviceBatteryState state = [UIDevice currentDevice].batteryState;
    CGFloat level = [UIDevice currentDevice].batteryLevel;
    CGFloat mVD = 0;
    if (state == UIDeviceBatteryStateUnplugged) {//未充电
        mVD = (level - 1) * 10.0f;//mindValue -= x (饿一滴血)
    }else if (state == UIDeviceBatteryStateCharging) {//充电中
        mVD = (1 - level) * 10.0f;//mindValue += x (饱一滴血)
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(hunger_LevelChanged:State:mindValueDelta:)]) {
        [self.delegate hunger_LevelChanged:level State:state mindValueDelta:mVD];
    }
}

-(void) observerHungerStateChanged{
    UIDeviceBatteryState state = [UIDevice currentDevice].batteryState;
    CGFloat level = [UIDevice currentDevice].batteryLevel;
    CGFloat mvD = 0;
    if (state == UIDeviceBatteryStateUnplugged) {//未充电
        if (level == 1.0f) {
            mvD = 1;//mindValue += 1 (饱了停充)
        }else if(level > 0.7f){
            mvD = 0;//mindValue == (7成饱停充)
        }else if(level < 0.7f){
            mvD = (level - 1) * 10.0f;//mindValue -= x (没饱停充)
        }
    }else if (state == UIDeviceBatteryStateCharging) {//充电中
        if (level == 1.0f) {
            mvD = -1;//mindValue -= 1 (饱了)
        }else if(level > 0.7f){
            mvD = 0;//mindValue == (再充饱点)
        }else if(level < 0.7f){
            mvD = (1 - level) * 10.0f;//mindValue += x (未饱再吃点)
        }
    }else if (state == UIDeviceBatteryStateFull) {//满电
        mvD = 1;//(充满了)
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(hunger_StateChanged:level:mindValueDelta:)]) {
        [self.delegate hunger_StateChanged:state level:level mindValueDelta:mvD];
    }
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

-(MindStrategyModel*) getStrategyModel{
    NSInteger curBatteryLevel = (NSInteger)[UIDevice currentDevice].batteryLevel;
    return [MindStrategy getModelWithMin:0 withMax:100 withOriValue:curBatteryLevel withType:MindType_Hunger];
}

-(void) dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
