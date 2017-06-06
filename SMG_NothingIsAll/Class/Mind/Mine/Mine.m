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
 *  MARK:--------------------HungerDelegate--------------------
 */
-(void) hunger_HungerStateChanged:(HungerStatus)status{
    NSLog(@"Mine_自我产生饥饿意识");
    if (self.delegate && [self.delegate respondsToSelector:@selector(mine_HungerStateChanged:)]) {
        [self.delegate mine_HungerStateChanged:status];
    }
}

@end
