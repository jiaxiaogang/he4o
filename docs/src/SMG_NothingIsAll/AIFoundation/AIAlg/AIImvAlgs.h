//
//  AIImvAlgs.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/12/21.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AIImvAlgs : NSObject

/**
 *  MARK:--------------------输入mindValue--------------------
 *  所有值域,转换为0-10;(例如:hunger时0为不饿,10为非常饿)
 */
+(void) commitIMV:(MVType)type from:(CGFloat)from to:(CGFloat)to;

@end
