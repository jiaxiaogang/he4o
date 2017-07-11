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
        _value = MAX(-10, MIN(value, 10));//值只能在-10到10之间;
        _type = type;
        
        [self initRun];
    }
    return self;
}

-(void) initRun{
    [[MoodDurationManager sharedInstance] checkAddMood:self];
}

-(MindStrategyModel*) getStrategyModel{
    return [MindStrategy getModelWithMin:-10 withMax:10 withOriValue:self.value withType:MindType_Mood];
}

@end
