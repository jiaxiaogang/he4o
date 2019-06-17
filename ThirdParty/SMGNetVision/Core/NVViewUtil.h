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
 */
+(CGFloat) anglePoint:(CGPoint)first second:(CGPoint)second;

@end
