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
    
    //1,存心情
    AIMoodModel *moodModel = [[AIMoodModel alloc] initWithType:self.type value:self.value];//logThink
    [AIMoodStore insert:moodModel];
    
    //2,存意识流
    AIAwarenessModel *awareness = [[AIAwarenessModel alloc] init];
    awareness.awarenessP = moodModel.pointer;
    [AIAwarenessStore insert:awareness];
    
    //3,心情持续
    [[MoodDurationManager sharedInstance] checkAddMood:self rateBlock:^(Mood *mood) {
        if (self.rateBlock) self.rateBlock(mood);
    }];
}

-(MindStrategyModel*) getStrategyModel{
    return [MindStrategy getModelWithMin:-10 withMax:10 withOriValue:self.value withType:MindType_Mood];
}

@end
