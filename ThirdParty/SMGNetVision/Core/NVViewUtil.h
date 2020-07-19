//
//  NVViewUtil.h
//  SMG_NothingIsAll
//
//  Created by jia on 2019/6/17.
//  Copyright © 2019年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NVViewUtil : NSObject

/**
 *  MARK:--------------------lineDatas的收集防重--------------------
 */
+(BOOL) containsLineData:(NSArray*)checkLineData fromLineDatas:(NSArray*)lineDatas;

/**
 *  MARK:--------------------两点距离--------------------
 */
+(CGFloat) distancePoint:(CGPoint)first second:(CGPoint)second;


/**
 *  MARK:--------------------两点角度--------------------
 *  0 -> 1 (从左开始0顺时针,一圈为0到1)
 */
+(CGFloat) angleZero2OnePoint:(CGPoint)first second:(CGPoint)second;

/**
 *  MARK:--------------------两点角度--------------------
 *  -PI -> PI (从右至左,上面为-0 -> -3.14 / 从右至左,下面为0 -> 3.14)
 */
+(CGFloat) anglePIPoint:(CGPoint)first second:(CGPoint)second;


/**
 *  MARK:--------------------将angle转为方向值--------------------
 *  @param angle : angle为左向顺时针0-1 (含0,不含1);
 *  @param directionCount : 方向数 (一般为4或8向);
 */
+(CGFloat) convertAngle2Direction:(CGFloat)angle directionCount:(int)directionCount;
+(CGFloat) convertAngle2Direction_4:(CGFloat)angle;
+(CGFloat) convertAngle2Direction_8:(CGFloat)angle;

@end
