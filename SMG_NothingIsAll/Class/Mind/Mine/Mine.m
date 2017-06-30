//
//  Mine.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/6/2.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "Mine.h"
#import "MindHeader.h"

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
    [mArr addObject:[self.hunger getStrategyModel]];
    [mArr addObject:[self.mood getStrategyModel]];
    return [MindStrategy getModelForDemandWithArr:mArr];
}

/**
 *  MARK:--------------------HungerDelegate--------------------
 */
-(void) hunger_HungerStateChanged:(HungerStatus)status{
    NSLog(@"Mine_自我产生饥饿意识");
    if (self.delegate && [self.delegate respondsToSelector:@selector(mine_HungerStateChanged:)]) {
        [self.delegate mine_HungerStateChanged:status];
    }
}

-(void) hunger_LevelChanged:(CGFloat)level State:(UIDeviceBatteryState)state mindValueDelta:(CGFloat)mVD{
    if (self.delegate && [self.delegate respondsToSelector:@selector(mine_HungerLevelChanged:State:mindValueDelta:)]) {
        [self.delegate mine_HungerLevelChanged:level State:state mindValueDelta:mVD];
    }
}

-(void) hunger_StateChanged:(UIDeviceBatteryState)state level:(CGFloat)level mindValueDelta:(CGFloat)mVD{
    if (self.delegate && [self.delegate respondsToSelector:@selector(hunger_StateChanged:level:mindValueDelta:)]) {
        [self.delegate mine_HungerStateChanged:state level:level mindValueDelta:mVD];
    }
}



@end
