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
        [UIDevice currentDevice].batteryMonitoringEnabled = YES;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(observerHungerLevelChanged:) name:UIDeviceBatteryLevelDidChangeNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(observerHungerStateChanged) name:UIDeviceBatteryStateDidChangeNotification object:nil];
        
    }
    return self;
}

/**
 *  MARK:--------------------method--------------------
 */
-(void) observerHungerLevelChanged:(id)i{
    NSLog(@"Hunger_自我产生饥饿意识");
    if (self.delegate && [self.delegate respondsToSelector:@selector(hunger_HungerStateChanged:)]) {
        [self.delegate hunger_HungerStateChanged:[Hunger getHungerStatus]];
    }
}

-(void) observerHungerStateChanged{
    UIDeviceBatteryState state = [UIDevice currentDevice].batteryState;
    CGFloat batteryLevel = [UIDevice currentDevice].batteryLevel;
    
    if (state == UIDeviceBatteryStateUnplugged) {//未充电
        if (batteryLevel == 1.0f) {
            NSLog(@"饱了...");
            //mindValue += 1
        }else if(batteryLevel > 0.7f){
            NSLog(@"好吧,下次再充...");
            //mindValue ==
        }else if(batteryLevel < 0.7f){
            NSLog(@"还没饱呢!");
            //mindValue -= x
        }
    }else if (state == UIDeviceBatteryStateCharging) {//充电中
        if (batteryLevel == 1.0f) {
            NSLog(@"饱了...");
            //mindValue -= 1
        }else if(batteryLevel > 0.7f){
            NSLog(@"好吧,再充些...");
            //mindValue ==
        }else if(batteryLevel < 0.7f){
            NSLog(@"谢谢呢!");
            //mindValue += x
        }
    }else if (state == UIDeviceBatteryStateFull) {//满电
        NSLog(@"满了,帮我拔下电线");
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
