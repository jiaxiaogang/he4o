//
//  NVViewUtil.m
//  SMG_NothingIsAll
//
//  Created by jia on 2019/6/17.
//  Copyright © 2019年 XiaoGang. All rights reserved.
//

#import "NVViewUtil.h"

@implementation NVViewUtil

+(BOOL) containsLineData:(NSArray*)checkLineData fromLineDatas:(NSArray*)lineDatas{
    if (ARRISOK(checkLineData) && checkLineData.count == 2 && ARRISOK(lineDatas)) {
        for (NSArray *parentItem in lineDatas) {
            id checkA = ARR_INDEX(checkLineData, 0);
            id checkB = ARR_INDEX(checkLineData, 1);
            if ([parentItem containsObject:checkA] && [parentItem containsObject:checkB]) {
                return true;
            }
        }
    }
    return false;
}

+(CGFloat) distancePoint:(CGPoint)first second:(CGPoint)second {
    CGFloat deltaX = fabs(second.x - first.x);
    CGFloat deltaY = fabs(second.y - first.y);
    return sqrtf(deltaX * deltaX + deltaY * deltaY);
}

+(CGFloat) angleZero2OnePoint:(CGPoint)first second:(CGPoint)second {
    //1. 取PI角度;
    CGPoint distance = CGPointMake(second.x - first.x, second.y - first.y);
    CGFloat anglePI = atan2f(distance.y,distance.x);
    
    //2. 将(-PI到PI) 转换成 (0到1)
    float result = (anglePI / M_PI + 1) / 2;
    return result;
}

+(CGFloat) anglePIPoint:(CGPoint)first second:(CGPoint)second {
    CGFloat height = second.y - first.y;
    CGFloat width = first.x - second.x;
    CGFloat rads = atan(height/width);
    return -rads;
}

@end
