//
//  AIHungerLevelChangedModel.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/7/14.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "AIHungerLevelChangedModel.h"

@implementation AIHungerLevelChangedModel

-(void)print{
    NSString *state;
    if (self.state == HungerState_Charging) {
        state = @"+++";
    }else if (self.state == HungerState_Unplugged) {
        state = @"---";
    }else if (self.state == HungerState_Unknown) {
        state = @"unknown";
    }
    
    NSLog(@"\n\
________________________________________\n\
                                       |\n\
<AIHungerLevelChangedModel> :          |\n\
state : %@\n\
level : %f\n\
_______________________________________|\n\n\n",state,_level);
}

@end
