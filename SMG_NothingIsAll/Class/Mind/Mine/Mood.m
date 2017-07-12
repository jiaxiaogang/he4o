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

-(id) initWithType:(MoodType)type value:(int)value{
    self = [super init];
    if (self) {
        [self setData:value type:type];
    }
    return self;
}

-(void) setData:(int)value type:(MoodType)type {
    _type = type;
    _value = MAX(-10, MIN(value, 10));//值只能在-10到10之间;
    
    AIMoodModel *moodModel = [[AIMoodModel alloc] initWithType:self.type value:self.value];//logThink
    [AIMoodStore insert:moodModel];
    
    [self refreshRun];
}

-(void) refreshRun{
    //两种设计:
    //1,使用"心情持续"管理器;
    //2,使用"神经网络"AILine的类型;
    [[MoodDurationManager sharedInstance] checkAddMood:self];
}

-(MindStrategyModel*) getStrategyModel{
    return [MindStrategy getModelWithMin:-10 withMax:10 withOriValue:self.value withType:MindType_Mood];
}

@end
