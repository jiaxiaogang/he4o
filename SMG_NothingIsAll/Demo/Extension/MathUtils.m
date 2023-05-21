//
//  MathUtils.m
//  SMG_NothingIsAll
//
//  Created by jia on 2023/5/21.
//  Copyright © 2023年 XiaoGang. All rights reserved.
//

#import "MathUtils.h"

@implementation MathUtils

+(CGFloat) getNegativeTen2TenWithOriRange:(UIFloatRange)oriRange oriValue:(CGFloat)oriValue{
    return [self getValueWithOriRange:oriRange targetRange:UIFloatRangeMake(-10, 10) oriValue:oriValue];
}
+(CGFloat) getZero2TenWithOriRange:(UIFloatRange)oriRange oriValue:(CGFloat)oriValue{
    return [self getValueWithOriRange:oriRange targetRange:UIFloatRangeMake(0, 10) oriValue:oriValue];
}
+(CGFloat) getValueWithOriRange:(UIFloatRange)oriRange targetRange:(UIFloatRange)targetRange oriValue:(CGFloat)oriValue{
    //1,数据范围检查;
    oriValue = MAX(oriValue, MIN(oriValue, oriRange.maximum));
    //2,checkValue所在的值
    CGFloat percent = 0;
    if (oriRange.minimum != oriValue) {
        percent = (oriValue - oriRange.minimum) / (oriRange.maximum - oriRange.minimum);
    }
    //3,返回变换值
    return (targetRange.maximum - targetRange.minimum) * percent + targetRange.minimum;
}

//MARK:===============================================================
//MARK:                     < rect >
//MARK:===============================================================

/**
 *  MARK:--------------------取rect并集--------------------
 */
+(CGRect) collectRectA:(CGRect)rectA rectB:(CGRect)rectB {
    //CGFloat x = MIN(rectA.origin.x, rectB.origin.x);
    //CGFloat y = MIN(rectA.origin.y, rectB.origin.y);
    //CGFloat w = MAX(CGRectGetMaxX(rectA), CGRectGetMaxX(rectB)) - x;
    //CGFloat h = MAX(CGRectGetMaxY(rectA), CGRectGetMaxY(rectB)) - y;
    //return CGRectMake(x, y, w, h);
    return CGRectUnion(rectA, rectB);
}

/**
 *  MARK:--------------------取rect交集--------------------
 */
+(CGRect) filterRectA:(CGRect)rectA rectB:(CGRect)rectB {
    return CGRectIntersection(rectA, rectB);
}

@end
