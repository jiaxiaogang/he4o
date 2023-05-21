//
//  MathUtils.h
//  SMG_NothingIsAll
//
//  Created by jia on 2023/5/21.
//  Copyright © 2023年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MathUtils : NSObject

//数据范围变换
+(CGFloat) getNegativeTen2TenWithOriRange:(UIFloatRange)oriRange oriValue:(CGFloat)oriValue;
+(CGFloat) getZero2TenWithOriRange:(UIFloatRange)oriRange oriValue:(CGFloat)oriValue;
+(CGFloat) getValueWithOriRange:(UIFloatRange)oriRange targetRange:(UIFloatRange)targetRange oriValue:(CGFloat)oriValue;

//MARK:===============================================================
//MARK:                     < rect >
//MARK:===============================================================

/**
 *  MARK:--------------------取rect并集--------------------
 */
+(CGRect) collectRectA:(CGRect)rectA rectB:(CGRect)rectB;

/**
 *  MARK:--------------------取rect交集--------------------
 */
+(CGRect) filterRectA:(CGRect)rectA rectB:(CGRect)rectB;

/**
 *  MARK:--------------------取start到end之间百分比处的值--------------------
 */
+(CGRect) radioRect:(CGRect)startRect endRect:(CGRect)endRect radio:(CGFloat)radio;

@end
