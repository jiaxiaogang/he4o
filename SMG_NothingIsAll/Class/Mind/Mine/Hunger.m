//
//  Hunger.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/6/7.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "Hunger.h"
#import "MindHeader.h"


@interface Hunger ()

@property (assign, nonatomic) CGFloat tmpLevel;
@property (assign, nonatomic) HungerState tmpState;

@end

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
    [self run];
}

/**
 *  MARK:--------------------method--------------------
 */
-(void) run {//饥饿感是种持续的神经感觉;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if ([self getState] == HungerState_Charging) {
            if (self.getLevel < 1.0f) {
                CGFloat value = self.tmpLevel + 0.003f;
                value = MIN(1, value);
                [self setLevel:value];
            }
        }else if([self getState] == HungerState_Unplugged){
            if (self.getLevel > 0) {
                CGFloat value = self.tmpLevel - 0.001f;
                value = MAX(0, value);
                [self setLevel:value];
            }
        }
        
        CGFloat level = [MathUtils getZero2TenWithOriRange:UIFloatRangeMake(0, 1) oriValue:[self getCurrentLevel]];
        
        //1,LogThink
        AIHungerLevelChangedModel *model = [[AIHungerLevelChangedModel alloc] init];//logThink
        model.level = level;
        model.state = self.tmpState;
        
        //2,回调
        if (self.delegate && [self.delegate respondsToSelector:@selector(hunger_LevelChanged:)]) {
            [self.delegate hunger_LevelChanged:model];
        }
        
        //3,循环
        [self run];
    });
}

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

-(void)setState:(HungerState)state{
    self.tmpState = state;
}

-(HungerState) getState{
    //return [[UIDevice currentDevice].batteryState == ing return hungerStateing;];
    return self.tmpState;
}

-(void) setLevel:(CGFloat)level{
    self.tmpLevel = level;
    [[NSNotificationCenter defaultCenter] postNotificationName:ObsKey_HungerLevelChanged object:nil];
}

-(CGFloat)getLevel{
    return self.tmpLevel;
}

/**
 *  MARK:--------------------tmpTest--------------------
 */
-(void) tmpTest_Add{
    [self setState:HungerState_Charging];
    CGFloat level = [MathUtils getZero2TenWithOriRange:UIFloatRangeMake(0, 1) oriValue:[self getCurrentLevel]];
    
    //1,LogThink
    AIHungerLevelChangedModel *model = [[AIHungerLevelChangedModel alloc] init];//logThink
    model.level = level;
    model.state = self.tmpState;
    
    //2,回调
    if (self.delegate && [self.delegate respondsToSelector:@selector(hunger_LevelChanged:)]) {
        [self.delegate hunger_LevelChanged:model];
    }
}

-(void) tmpTest_Sub {
    [self setState:HungerState_Unplugged];
    CGFloat level = [MathUtils getZero2TenWithOriRange:UIFloatRangeMake(0, 1) oriValue:[self getCurrentLevel]];
    
    //1,LogThink
    AIHungerLevelChangedModel *model = [[AIHungerLevelChangedModel alloc] init];//logThink
    model.level = level;
    model.state = self.tmpState;
    
    //2,回调
    if (self.delegate && [self.delegate respondsToSelector:@selector(hunger_LevelChanged:)]) {
        [self.delegate hunger_LevelChanged:model];
    }
    
    //重构掉电的流程;
    //1,掉电只是掉电;如果Awareness在忙;则不会意识到需求;(甚至有不会存到意识流)
    //2,生理饥饿状态与心理饥饿需求是作了先天绑定的;(或者直接就是生理需求,与心理不一致)
    //3,
}

-(void) tmpTest_Start{
    if (self.tmpState == HungerState_Charging) {
        return;
    }
    [self setState:HungerState_Charging];
    CGFloat level = [MathUtils getZero2TenWithOriRange:UIFloatRangeMake(0, 1) oriValue:[self getCurrentLevel]];
    
    //1,LogThink
    AIHungerStateChangedModel *model = [[AIHungerStateChangedModel alloc] init];//logThink
    model.level = level;
    model.state = self.tmpState;
    
    //2,回调
    if (self.delegate && [self.delegate respondsToSelector:@selector(hunger_StateChanged:)]) {
        [self.delegate hunger_StateChanged:model];
    }
}

-(void) tmpTest_Stop {
    if (self.tmpState == HungerState_Unplugged) {
        return;
    }
    [self setState:HungerState_Unplugged];
    CGFloat level = [MathUtils getZero2TenWithOriRange:UIFloatRangeMake(0, 1) oriValue:[self getCurrentLevel]];
    
    //1,LogThink
    AIHungerStateChangedModel *model = [[AIHungerStateChangedModel alloc] init];//logThink
    model.level = level;
    model.state = self.tmpState;
    
    //2,回调
    if (self.delegate && [self.delegate respondsToSelector:@selector(hunger_StateChanged:)]) {
        [self.delegate hunger_StateChanged:model];
    }
}


@end
