//
//  AIPointerStrong.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/6/29.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "AILineStrong.h"
#import "AILineDampingStrategy.h"

@interface AILineStrong ()

@property (assign, nonatomic) long long lastCountTime;  //最后计数器变化时间
@property (assign, nonatomic) NSInteger count;          //计数器(0-100)

@end

@implementation AILineStrong

+(AILineStrong*) newWithCount:(int)count{
    AILineStrong *strong = [[AILineStrong alloc] init];
    [strong setCountDelta:count];
    return strong;
}

-(CGFloat)value{
    return [AILineDampingStrategy getValue:self.count lastCountTime:self.lastCountTime];
}

-(void) setCountDelta:(int)delta{
    self.count += delta;
    self.count = MAX(0, MIN(100, self.count));//0-100
    self.lastCountTime = [[NSDate date] timeIntervalSince1970];
}

@end
