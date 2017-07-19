//
//  Hunger.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/6/7.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "Hunger.h"
#import "MindHeader.h"
#import "MathUtils.h"

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
    //1,取值
    HungerState state;
    if ([UIDevice currentDevice].batteryState == UIDeviceBatteryStateUnplugged) {//未充电
        state = HungerState_Unplugged;
    }else if ([UIDevice currentDevice].batteryState == UIDeviceBatteryStateCharging) {//充电中
        state = HungerState_Charging;
    }
    CGFloat level = [MathUtils getZero2TenWithOriRange:UIFloatRangeMake(0, 1) oriValue:[self getCurrentLevel]];
    
    //2,LogThink
    AIHungerLevelChangedModel *model = [[AIHungerLevelChangedModel alloc] init];//logThink
    model.level = level;
    model.state = state;
    [AIHungerLevelChangedStore insert:model awareness:true];
    
    //3,回调
    if (self.delegate && [self.delegate respondsToSelector:@selector(hunger_LevelChanged:)]) {
        [self.delegate hunger_LevelChanged:model];
    }
}

-(void) observerHungerStateChanged{
//    UIDeviceBatteryState state = [UIDevice currentDevice].batteryState;
//    CGFloat level = [self getCurrentLevel];
//    CGFloat mvD = 0;
//    if (state == UIDeviceBatteryStateUnplugged) {//未充电
//        if (level == 1.0f) {
//            mvD = 1;//mindValue += 1 (饱了停充)
//        }else if(level > 0.7f){
//            mvD = 0;//mindValue == (7成饱停充)
//        }else if(level < 0.7f){
//            mvD = (level - 1) * 10.0f;//mindValue -= x (没饱停充)
//        }
//    }else if (state == UIDeviceBatteryStateCharging) {//充电中
//        if (level == 1.0f) {
//            mvD = -1;//mindValue -= 1 (饱了)
//        }else if(level > 0.7f){
//            mvD = 0;//mindValue == (再充饱点)
//        }else if(level < 0.7f){
//            mvD = (1 - level) * 10.0f;//mindValue += x (未饱再吃点)
//        }
//    }else if (state == UIDeviceBatteryStateFull) {//满电
//        mvD = 1;//(充满了)
//    }
    
    
    //1,取值
    HungerState state;
    if ([UIDevice currentDevice].batteryState == UIDeviceBatteryStateUnplugged) {//未充电
        state = HungerState_Unplugged;
    }else if ([UIDevice currentDevice].batteryState == UIDeviceBatteryStateCharging) {//充电中
        state = HungerState_Charging;
    }
    CGFloat level = [MathUtils getZero2TenWithOriRange:UIFloatRangeMake(0, 1) oriValue:[self getCurrentLevel]];
    
    //2,LogThink
    AIHungerStateChangedModel *model = [[AIHungerStateChangedModel alloc] init];//logThink
    model.level = level;
    model.state = state;
    [AIHungerStateChangedStore insert:model awareness:true];
    
    //3,回调
    if (self.delegate && [self.delegate respondsToSelector:@selector(hunger_StateChanged:)]) {
        [self.delegate hunger_StateChanged:model];
    }
}

-(void) dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(CGFloat) getCurrentLevel{
    return self.tmpLevel;
    //return [UIDevice currentDevice].batteryLevel;
}

/**
 *  MARK:--------------------tmpTest--------------------
 */
-(void) tmpTest_Add{
    CGFloat level = [MathUtils getZero2TenWithOriRange:UIFloatRangeMake(0, 1) oriValue:[self getCurrentLevel]];
    
    //1,LogThink
    AIHungerLevelChangedModel *model = [[AIHungerLevelChangedModel alloc] init];//logThink
    model.level = level;
    model.state = HungerState_Charging;
    [AIHungerLevelChangedStore insert:model awareness:true];
    
    //2,回调
    if (self.delegate && [self.delegate respondsToSelector:@selector(hunger_LevelChanged:)]) {
        [self.delegate hunger_LevelChanged:model];
    }
}

-(void) tmpTest_Sub{
    CGFloat level = [MathUtils getZero2TenWithOriRange:UIFloatRangeMake(0, 1) oriValue:[self getCurrentLevel]];
    
    //1,LogThink
    AIHungerLevelChangedModel *model = [[AIHungerLevelChangedModel alloc] init];//logThink
    model.level = level;
    model.state = HungerState_Unplugged;
    [AIHungerLevelChangedStore insert:model awareness:true];
    
    //2,回调
    if (self.delegate && [self.delegate respondsToSelector:@selector(hunger_LevelChanged:)]) {
        [self.delegate hunger_LevelChanged:model];
    }
}

-(void) tmpTest_Start{
    CGFloat level = [MathUtils getZero2TenWithOriRange:UIFloatRangeMake(0, 1) oriValue:[self getCurrentLevel]];
    
    //1,LogThink
    AIHungerStateChangedModel *model = [[AIHungerStateChangedModel alloc] init];//logThink
    model.level = level;
    model.state = HungerState_Charging;
    [AIHungerStateChangedStore insert:model awareness:true];
    
    //2,回调
    if (self.delegate && [self.delegate respondsToSelector:@selector(hunger_StateChanged:)]) {
        [self.delegate hunger_StateChanged:model];
    }
}

-(void) tmpTest_Stop {
    CGFloat level = [MathUtils getZero2TenWithOriRange:UIFloatRangeMake(0, 1) oriValue:[self getCurrentLevel]];
    
    //1,LogThink
    AIHungerStateChangedModel *model = [[AIHungerStateChangedModel alloc] init];//logThink
    model.level = level;
    model.state = HungerState_Unplugged;
    [AIHungerStateChangedStore insert:model awareness:true];
    
    //2,回调
    if (self.delegate && [self.delegate respondsToSelector:@selector(hunger_StateChanged:)]) {
        [self.delegate hunger_StateChanged:model];
    }
}

@end
