//
//  AILineDampingStrategy.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/6/29.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "AILineDampingStrategy.h"

@implementation AILineDampingStrategy

+(CGFloat) getValue:(NSInteger)count lastCountTime:(long long)lastCountTime{
    //目前先直接返回(一天忘掉);以后再根据不同情况写衰减策略;
    long long nowTime = [[NSDate date] timeIntervalSince1970];
    if (nowTime - lastCountTime > 86400) {
        return 0;
    }
    return (CGFloat)count;
}

@end
