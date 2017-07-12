//
//  AIMoodModel.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/7/12.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "AIMoodModel.h"

@implementation AIMoodModel

-(id) initWithType:(MoodType)type value:(int)value{
    self = [super init];
    if (self) {
        self.value = value;
        self.type = type;
    }
    return self;
}

@end
