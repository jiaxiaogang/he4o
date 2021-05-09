//
//  AINoRepeatRun.h
//  SMG_NothingIsAll
//
//  Created by jia on 2021/5/9.
//  Copyright © 2021年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  MARK:--------------------防重触发器--------------------
 *  @desc 每个登记后的key,仅执行一次;
 */
@interface AINoRepeatRun : NSObject

/**
 *  MARK:--------------------报名--------------------
 */
+(void) sign:(id)key;

/**
 *  MARK:--------------------执行--------------------
 */
+(void) run:(id)key block:(void(^)())block;

@end
