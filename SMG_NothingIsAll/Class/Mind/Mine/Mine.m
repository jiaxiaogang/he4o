//
//  Mine.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/6/2.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "Mine.h"
#import "MindHeader.h"

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
    self.mood = [[Mood alloc] init];
    self.hobby = [[Hobby alloc] init];
}

-(void) initRun{

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

@end
