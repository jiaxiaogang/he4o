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

/**
 *  MARK:--------------------将angle转为方向值--------------------
 *  @param angle : angle为左向顺时针0-1 (含0,不含1);
 *  @param directionCount : 方向数 (一般为4或8向);
 */
+(CGFloat) convertAngle2Direction:(CGFloat)angle directionCount:(int)directionCount{
    //1. 当8向时,x8x2=(0,1,2...15);
    int intAngle = (int)(angle * directionCount * 2);
    
    //2. 再+1=(15,0,1,2...14),此时0-1为左上,2-3为上...14-15为左;
    intAngle += 1;
    
    //3. 再/2=(0,1...7),此时0为左上,1为上...7为左;
    intAngle /= 2;
    
    //4. 将(0-7)除以8.0f,转换成0-1;
    CGFloat result = intAngle / (float)directionCount;
    result = result == 1.0f ? 0 : result;
    return result;
}
+(CGFloat) convertAngle2Direction_4:(CGFloat)angle{
    return [self convertAngle2Direction:angle directionCount:4];
}
+(CGFloat) convertAngle2Direction_8:(CGFloat)angle{
    return [self convertAngle2Direction:angle directionCount:8];
}

@end
