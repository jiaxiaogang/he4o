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
    return CGRectUnion(rectA, rectB);
}

/**
 *  MARK:--------------------取rect交集--------------------
 */
+(CGRect) filterRectA:(CGRect)rectA rectB:(CGRect)rectB {
    return CGRectIntersection(rectA, rectB);
}

/**
 *  MARK:--------------------取start到end之间百分比处的值--------------------
 */
+(CGRect) radioRect:(CGRect)startRect endRect:(CGRect)endRect radio:(CGFloat)radio{
    CGFloat x = [self radioFloat:CGRectGetMinX(startRect) endFloat:CGRectGetMinX(endRect) radio:radio];
    CGFloat y = [self radioFloat:CGRectGetMinY(startRect) endFloat:CGRectGetMinY(endRect) radio:radio];
    CGFloat w = [self radioFloat:CGRectGetWidth(startRect) endFloat:CGRectGetWidth(endRect) radio:radio];
    CGFloat h = [self radioFloat:CGRectGetHeight(startRect) endFloat:CGRectGetHeight(endRect) radio:radio];
    return CGRectMake(x, y, w, h);
}

//用radio取float从start到end之间的值;
+(CGFloat) radioFloat:(CGFloat)startFloat endFloat:(CGFloat)endFloat radio:(CGFloat)radio{
    return startFloat + (endFloat - startFloat) * radio;
}

@end
