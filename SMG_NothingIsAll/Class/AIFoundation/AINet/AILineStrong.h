//
//  AIPointerStrong.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/6/29.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  MARK:--------------------网线强度--------------------
 */
@interface AILineStrong : NSObject

+(AILineStrong*) newWithCount:(int)count;

/**
 *  MARK:--------------------更新计数器--------------------
 */
-(void) setCountDelta:(int)delta;

/**
 *  MARK:--------------------当前强度值--------------------
 */
-(CGFloat)value;

@end
