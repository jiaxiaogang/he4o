//
//  Mine.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/6/2.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "Mine.h"
#import "MindHeader.h"
#import "AIReactorControl.h"

@interface Mine ()<HungerDelegate>

@end

@implementation Mine

-(id) init{
    self = [super init];
    if (self) {
        [self initData];
        [self initRun];
    }
    return self;
}

-(void) initData{
    self.hunger = [[Hunger alloc] init];
    self.mood = [[Mood alloc] init];
    self.hobby = [[Hobby alloc] init];
}

-(void) initRun{
    self.hunger.delegate = self;
}

/**
 *  MARK:--------------------method--------------------
 */
-(MindStrategyModel*) getMindStrategyModelForDemand{
    NSMutableArray *mArr = [[NSMutableArray alloc] init];
    //[mArr addObject:[self.hunger getStrategyModel]];
    [mArr addObject:[self.mood getStrategyModel]];
    return [MindStrategy getModelForDemandWithArr:mArr];
}

/**
 *  MARK:--------------------HungerDelegate--------------------
 */
-(void) hunger_LevelChanged:(AIHungerLevelChangedModel*)model{
    if (self.delegate && [self.delegate respondsToSelector:@selector(mine_HungerLevelChanged:)]) {
        [self.delegate mine_HungerLevelChanged:model];
    }
    [[AIReactorControl shareInstance] commitInput:model];//传给新版AIAwareness
}

-(void) hunger_StateChanged:(AIHungerStateChangedModel*)model{
    if (self.delegate && [self.delegate respondsToSelector:@selector(mine_HungerStateChanged:)]) {
        [self.delegate mine_HungerStateChanged:model];
    }
    
    [[AIReactorControl shareInstance] commitModel:model];//传给新版AIAwareness
    //一个事务是否有意识要靠思维自行判断;
    //    //1. 潜意识isBusy = false时,执行联想唯一性判断;等读取操作;
    //    [[AIReactorControl shareInstance] activityByShallow:data];
    //
    //    //2. 主意识isBusy = false时,获取传给思维,作主意识传入;
    //    if (!self.mainThread.isBusy) {
    //        [[AIReactorControl shareInstance] activityByDeep:data];
    //    }
}

@end
