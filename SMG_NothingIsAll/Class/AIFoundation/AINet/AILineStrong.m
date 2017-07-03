//
//  AIPointerStrong.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/6/29.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "AILineStrong.h"
#import "AIHeader.h"

@interface AILineStrong ()

//@property (strong, nonatomic) AILineDampingStrategy *dampingStrategy;   //衰减策略
@property (assign, nonatomic) long long lastCountTime;  //最后计数器变化时间
@property (assign, nonatomic) NSInteger count;                          //计数器

@end

@implementation AILineStrong

-(CGFloat)value{
    return [AILineDampingStrategy getValue:self.count lastCountTime:self.lastCountTime];
}

-(void) setCountDelta:(int)delta{
    self.count += delta;
    self.count = MAX(0, self.count);
    self.lastCountTime = [[NSDate date] timeIntervalSince1970];
}

@end
