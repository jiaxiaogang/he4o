//
//  Mood.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/6/4.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "Mood.h"
#import "MindHeader.h"

@implementation Mood

-(void) setData:(int)value type:(MoodType)type rateBlock:(void(^)(Mood *mood))rateBlock {
    self.type = type;
    self.value = MAX(-10, MIN(value, 10));//值只能在-10到10之间;
    self.rateBlock = rateBlock;
    [self refreshRun];
}

-(void) refreshRun{
    //1,logThink
    [self saveLogThink];
    if (self.rateBlock) {
        self.rateBlock(self);
    }
    //2,心情持续
    [[MoodDurationManager sharedInstance] checkAddMood:self rateBlock:^(Mood *mood) {
        [self saveLogThink];
        if (self.rateBlock) {
            self.rateBlock(mood);
        }
    }];
}

-(void) saveLogThink{
    //1,存心情
    AIMoodModel *moodModel = [[AIMoodModel alloc] initWithType:self.type value:self.value];//logThink
    [SMGUtils store_Insert:moodModel];
}

-(MindStrategyModel*) getStrategyModel{
    return [MindStrategy getModelWithMin:-10 withMax:10 withOriValue:self.value withType:MindType_Mood];
}

@end
