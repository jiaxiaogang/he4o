//
//  AITime.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/9/17.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  MARK:--------------------生物钟触发器--------------------
 *  @version
 *      2017.09.17: AI运行时间,和主观意识时间;
 *      2020.08.14: 支持预想fo和实际fo间的保留,用于反省类比;
 *      2020.08.23: 生物钟触发器-暂仅用于触发反省类比;
 */
@interface AITime : NSObject

//@property (assign, nonatomic) NSTimeInterval time;          //AI运行的时间
//@property (assign,nonatomic) NSTimeInterval *awarenessTime; //意识时间

/**
 *  MARK:--------------------生物钟触发器--------------------
 */
+(void) setTimeTrigger:(NSTimeInterval)deltaTime trigger:(void(^)())trigger;
+(void) setTimeTrigger:(NSTimeInterval)deltaTime canTrigger:(BOOL(^)())canTrigger trigger:(void(^)())trigger;

@end
