//
//  AIVisionAlgs.h
//  SMG_NothingIsAll
//
//  Created by jiaxiaogang on 2018/11/15.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  MARK:--------------------视觉算法--------------------
 *  1. 大小 : size
 *  2. 颜色 : color
 *  3. 形状(圆角) : radius
 *  4. 相对位置 : origin
 *  5. 相对速度 : speed
 */
@interface AIVisionAlgs : NSObject

+(void) commitView:(UIView*)selfView targetView:(UIView*)targetView rect:(CGRect)rect;

@end
